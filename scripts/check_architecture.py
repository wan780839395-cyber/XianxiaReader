"""Static dependency guard. Does not type-check Swift or isolate same-target types."""
import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
LOCAL_DEPS = ROOT / ".cache/check-deps"
if LOCAL_DEPS.is_dir():
    sys.path.insert(0, str(LOCAL_DEPS))
import yaml
from tree_sitter import Language, Parser
import tree_sitter_swift


class BoundaryError(ValueError):
    pass


def require(value, message):
    if not value:
        raise BoundaryError(message)


def walk(node):
    yield node
    for child in node.named_children:
        yield from walk(child)


def parse(parser, source, label):
    tree = parser.parse(source)
    require(not tree.root_node.has_error, f"{label}: unparsed Swift syntax; dependency scan cannot be trusted")
    return tree.root_node


def literal(node, label):
    require(node is not None and node.type == "line_string_literal", f"{label}: expected a literal string")
    try:
        value = json.loads(node.text.decode("utf-8"))
    except (ValueError, UnicodeError) as error:
        raise BoundaryError(f"{label}: unsupported Swift string") from error
    require(isinstance(value, str), f"{label}: expected a string")
    return value


def array(node, label):
    require(node is not None and node.type == "array_literal", f"{label}: expected a literal array; review new manifest syntax")
    return [child for child in node.named_children if child.type not in {"comment", "multiline_comment"}]


def call(node, label):
    require(node.type == "call_expression" and len(node.named_children) == 2, f"{label}: unsupported dependency declaration")
    function, suffix = node.named_children
    require(suffix.type == "call_suffix" and len(suffix.named_children) == 1, f"{label}: unsupported call suffix")
    arguments = suffix.named_children[0]
    require(arguments.type == "value_arguments", f"{label}: unsupported call arguments")
    values = {}
    for argument in arguments.named_children:
        if argument.type in {"comment", "multiline_comment"}:
            continue
        name = argument.child_by_field_name("name")
        value = argument.child_by_field_name("value")
        require(name is not None and value is not None, f"{label}: expected named arguments")
        key = name.text.decode("utf-8")
        require(key not in values, f"{label}: duplicate argument {key}")
        values[key] = value
    return function.text.decode("utf-8"), values


def unique_map(items, label):
    result = {}
    for key, value in items:
        require(key not in result, f"{label}: duplicate {key}")
        result[key] = value
    return result


def package_graph(root, parser, name, specification, products):
    path = root / specification["path"] / "Package.swift"
    label = path.relative_to(root).as_posix()
    tree = parse(parser, path.read_bytes(), label)
    statements = [node for node in tree.named_children if node.type not in {"comment", "multiline_comment", "import_declaration"}]
    require(len(statements) == 1 and statements[0].type == "property_declaration", f"{label}: dynamic manifest statements require review")
    calls = [node for node in statements[0].named_children if node.type == "call_expression"]
    require(len(calls) == 1, f"{label}: expected one Package initializer")
    function, values = call(calls[0], label)
    require(function == "Package" and literal(values.get("name"), label) == name, f"{label}: package identity drift")
    require(set(values) <= {"name", "platforms", "products", "dependencies", "targets"}, f"{label}: new Package inputs require review")
    paths = []
    for dependency in array(values["dependencies"], label) if "dependencies" in values else []:
        kind, args = call(dependency, label)
        require(kind == ".package" and set(args) == {"path"}, f"{label}: new package form requires registration")
        paths.append(literal(args["path"], label))
    require(sorted(paths) == sorted(specification["packagePaths"]), f"{label}: package dependencies changed; register allowed direction")
    actual_products = []
    for product in array(values.get("products"), label):
        kind, args = call(product, label)
        require(kind in {".library", ".executable"}, f"{label}: unsupported product kind {kind}")
        actual_products.append((literal(args.get("name"), label), [literal(target, label) for target in array(args.get("targets"), label)]))
    require(unique_map(actual_products, label) == specification["products"], f"{label}: products changed; register their targets")
    graph = {}
    actual = {}
    for target in array(values.get("targets"), label):
        kind, args = call(target, label)
        target_name = literal(args.get("name"), label)
        require(target_name not in actual, f"{label}: duplicate target {target_name}")
        require(kind in {".target", ".testTarget", ".systemLibrary", ".executableTarget"}, f"{label}: unsupported target kind {kind}")
        require(set(args) <= {"name", "dependencies", "path", "resources", "publicHeadersPath", "linkerSettings", "providers"}, f"{label}: new target inputs require review")
        dependencies = []
        for dependency in array(args["dependencies"], label) if "dependencies" in args else []:
            if dependency.type == "line_string_literal":
                destination = literal(dependency, label)
                require(destination in specification["targets"], f"{label}: unknown local dependency {destination}")
            else:
                dependency_kind, fields = call(dependency, label)
                require(dependency_kind == ".product" and set(fields) == {"name", "package"}, f"{label}: unsupported target dependency")
                destination = literal(fields["name"], label)
                owner = literal(fields["package"], label)
                require(products.get(destination) == owner, f"{label}: unregistered product {owner}/{destination}")
            dependencies.append(destination)
        require(len(dependencies) == len(set(dependencies)), f"{label}: duplicate target dependency")
        default = "Tests" if kind == ".testTarget" else "Sources"
        target_path = literal(args["path"], label) if "path" in args else f"{default}/{target_name}"
        actual[target_name] = {"kind": kind[1:], "path": target_path, "dependencies": dependencies}
        graph[target_name] = dependencies
    return graph, actual


def reject_cycles(graph):
    active, done = [], set()

    def visit(name):
        require(name in graph, f"Unknown dependency target: {name}")
        if name in done:
            return
        require(name not in active, "Dependency cycle: " + " -> ".join(active + [name]))
        active.append(name)
        for dependency in graph[name]:
            visit(dependency)
        active.pop()
        done.add(name)

    for name in graph:
        visit(name)


def imported_modules(tree):
    result = []
    for node in walk(tree):
        if node.type != "import_declaration":
            continue
        identifiers = [child for child in node.named_children if child.type == "identifier"]
        require(len(identifiers) == 1 and identifiers[0].named_children, "Unsupported import syntax")
        result.append((identifiers[0].named_children[0].text.decode("utf-8"), node.start_point.row + 1))
    return result


def check_architecture(root=ROOT):
    root = Path(root).resolve()
    policy = json.loads((root / "Documentation/architecture-boundaries.json").read_text(encoding="utf-8"))
    require(policy["version"] == 1, "Unsupported architecture policy version")
    parser = Parser(Language(tree_sitter_swift.language()))
    packages = policy["packages"]
    manifests = {path.relative_to(root).as_posix() for path in (root / "Packages").rglob("Package.swift") if ".build" not in path.parts and ".swiftpm" not in path.parts}
    require(manifests == {value["path"] + "/Package.swift" for value in packages.values()}, "Unregistered or missing first-party Package.swift")
    products = dict(policy["vendorProducts"])
    for name, specification in packages.items():
        for product, targets in specification["products"].items():
            require(product not in products and targets == [product], "I0 supports unique single-target products; review new product shape")
            products[product] = name
    graph = {product: [] for product in policy["vendorProducts"]}
    expected = {}
    actual = {}
    source_paths = {}
    source_entries = {}
    for name, specification in packages.items():
        edges, declarations = package_graph(root, parser, name, specification, products)
        require(not (set(graph) & set(edges)), "Target names must be unique across registered packages")
        graph.update(edges)
        actual.update(declarations)
        expected.update(specification["targets"])
        for target, declaration in declarations.items():
            source_paths[target] = [specification["path"] + "/" + declaration["path"]]
            source_entries[target] = [{"path": source_paths[target][0]}]
    package_paths = {(root / value["path"]).resolve(): name for name, value in packages.items()}
    package_paths.update({(root / "Vendor" / name).resolve(): name for name in set(policy["vendorProducts"].values())})
    package_dependencies = {name: [] for name in package_paths.values()}
    for name, specification in packages.items():
        for relative in specification["packagePaths"]:
            destination = (root / specification["path"] / relative).resolve()
            require(destination in package_paths, f"{name}: unregistered local package path {relative}")
            package_dependencies[name].append(package_paths[destination])
    reject_cycles(package_dependencies)
    project = yaml.load((root / "project.yml").read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
    require(project["packages"] == {name: {"path": path} for name, path in policy["projectPackages"].items()}, "XcodeGen packages changed; review registration")
    require(set(project["targets"]) == set(policy["projectTargets"]), "Unregistered or missing XcodeGen target")
    for name, target in project["targets"].items():
        require(name not in graph, f"Duplicate target name: {name}")
        dependencies = []
        for dependency in target.get("dependencies", []):
            if set(dependency) == {"target"}:
                dependencies.append(dependency["target"])
            else:
                require(set(dependency) == {"package", "product"}, f"{name}: unsupported XcodeGen dependency")
                product, package = dependency["product"], dependency["package"]
                require(products.get(product) == package, f"{name}: unregistered product {package}/{product}")
                dependencies.append(product)
        source_entries[name] = [entry for entry in target["sources"] if entry.get("buildPhase") != "resources"]
        for entry in source_entries[name]:
            require(set(entry) <= {"path", "excludes", "buildPhase"}, f"{name}: new source selection syntax requires review")
            require(all(not any(character in value for character in "*?[]{}") for value in entry.get("excludes", [])), f"{name}: source exclusion glob requires review")
        sources = [entry["path"] for entry in source_entries[name]]
        actual[name] = {"kind": target["type"], "sources": sources, "dependencies": dependencies}
        expected[name] = policy["projectTargets"][name]
        source_paths[name] = sources
        graph[name] = dependencies
    reject_cycles(graph)
    require(actual == expected, "Target dependencies/type/source paths changed; review architecture-boundaries.json")
    exceptions = unique_map([((item["file"], item["import"]), item) for item in policy["exceptions"]], "exceptions")
    for item in exceptions.values():
        require(item.get("reason") and item.get("removeIn"), "Every exception needs a reason and removal stage")
    shared_tests = policy.get("sharedTestSources", {})
    for file, item in shared_tests.items():
        owners = item.get("targets", [])
        require(item.get("reason") and len(owners) >= 2 and len(set(owners)) == len(owners), f"{file}: shared test source needs exact owners and a reason")
        require(all(actual.get(owner, {}).get("kind") in {"testTarget", "bundle.unit-test"} for owner in owners), f"{file}: shared source allowance is test-only; production remains single-owner")
    seen_exceptions, seen_rules, seen_areas = set(), set(), set()
    seen_shared = set()
    counts, source_inventory = {}, []
    scan_roots = {root / base for base in policy["sourceRoots"]}
    scan_roots.update(root / entry["path"] for entries in source_entries.values() for entry in entries)
    seen_sources = set()
    for base in sorted(scan_roots):
        require(base.resolve().is_relative_to(root) and not any(part in {".build", ".swiftpm"} for part in base.parts), f"Compile source root must stay in maintained repository sources: {base}")
        require(base.exists(), f"Missing architecture source root: {base}")
        candidates = [base] if base.is_file() else sorted(base.rglob("*.swift"))
        for path in candidates:
            if path.name == "Package.swift" or ".build" in path.parts or ".swiftpm" in path.parts:
                continue
            require(path.suffix == ".swift", f"Unsupported compile source file: {path}")
            if path in seen_sources:
                continue
            seen_sources.add(path)
            relative = path.relative_to(root).as_posix()
            areas = [area for area in policy["areas"] if relative in area.get("files", []) or ("path" in area and relative.startswith(area["path"] + "/"))]
            require(len(areas) == 1, f"{relative}: unregistered or overlapping source area; new features need an owner")
            area = areas[0]
            require(area["target"] in source_paths, f"{relative}: area has an unknown target")
            owners = set()
            for target, entries in source_entries.items():
                for entry in entries:
                    prefix = entry["path"]
                    if relative != prefix and not relative.startswith(prefix + "/"):
                        continue
                    local = relative[len(prefix):].lstrip("/")
                    if not any(local == excluded or local.startswith(excluded.rstrip("/") + "/") for excluded in entry.get("excludes", [])):
                        owners.add(target)
            expected_owners = set(shared_tests[relative]["targets"]) if relative in shared_tests else {area["target"]}
            require(area["target"] in expected_owners and owners == expected_owners, f"{relative}: compile source ownership mismatch: {sorted(owners)}; expected {sorted(expected_owners)}")
            if relative in shared_tests:
                seen_shared.add(relative)
            allowed = set(area["imports"])
            rule = policy["fileRules"].get(relative)
            if rule:
                require(rule.get("reason"), f"{relative}: file rule needs a reason")
                allowed = set(rule["imports"])
                seen_rules.add(relative)
            tree = parse(parser, path.read_bytes(), relative)
            imports = imported_modules(tree)
            for module, line in imports:
                if module in allowed:
                    continue
                key = (relative, module)
                require(key in exceptions, f"{relative}:{line}: {area['name']} must not import {module}")
                seen_exceptions.add(key)
            counts[area["name"]] = counts.get(area["name"], 0) + 1
            seen_areas.add(area["name"])
            source_inventory.append({"file": relative, "area": area["name"], "target": area["target"], "compiledTargets": sorted(owners), "imports": sorted({module for module, _ in imports})})
    require(seen_exceptions == set(exceptions), "Stale architecture exception; remove entries whose imports no longer exist")
    require(seen_rules == set(policy["fileRules"]), "Stale architecture file rule")
    require(seen_areas == {area["name"] for area in policy["areas"]}, "An architecture area has no Swift source")
    require(seen_shared == set(shared_tests), "Stale shared test source allowance")
    return {"validationKind": "static_dependency_only", "swiftFiles": sum(counts.values()), "areas": counts, "packages": package_dependencies, "targets": graph, "sources": source_inventory, "exceptions": list(exceptions.values()), "swiftCompiled": False, "sameTargetTypeAccessIsolated": False}


def main():
    argument_parser = argparse.ArgumentParser(description=__doc__)
    argument_parser.add_argument("--root", type=Path, default=ROOT)
    argument_parser.add_argument("--report", type=Path)
    args = argument_parser.parse_args()
    report = check_architecture(args.root)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"PASS architecture: {report['swiftFiles']} Swift files, {len(report['areas'])} areas, {len(report['targets'])} graph nodes, {len(report['exceptions'])} explicit exceptions (static only)")


if __name__ == "__main__":
    main()
