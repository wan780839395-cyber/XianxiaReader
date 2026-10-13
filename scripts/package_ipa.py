"""Package an unsigned *device* .app into Payload, preserving permissions and symlinks."""
import os
from pathlib import Path
import plistlib
import stat
import sys
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED


def package(app: Path, output: Path) -> None:
    if not app.is_dir() or app.suffix != ".app":
        raise ValueError(f"Missing application bundle: {app}")
    with (app / "Info.plist").open("rb") as file:
        info = plistlib.load(file)
    if "iPhoneOS" not in info.get("CFBundleSupportedPlatforms", []):
        raise ValueError("Refusing to package a simulator app as a device IPA")
    executable_name = info["CFBundleExecutable"]
    if not executable_name or Path(executable_name).name != executable_name or "\\" in executable_name:
        raise ValueError("Application executable must be a bundle-local filename")
    executable = app / executable_name
    if not executable.is_file():
        raise ValueError("Application executable is missing")
    output.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(output, "w", compression=ZIP_DEFLATED) as archive:
        for parent, directories, files in os.walk(app, followlinks=False):
            for name in sorted(directories + files):
                path = Path(parent) / name
                entry_name = "Payload/" + app.name + "/" + path.relative_to(app).as_posix()
                mode = path.lstat().st_mode
                is_directory = stat.S_ISDIR(mode)
                entry = ZipInfo(entry_name + ("/" if is_directory else ""))
                entry.create_system = 3
                entry.external_attr = (mode & 0xFFFF) << 16
                entry.compress_type = ZIP_DEFLATED
                if path.is_symlink():
                    archive.writestr(entry, os.readlink(path).encode("utf-8"))
                elif is_directory:
                    archive.writestr(entry, b"")
                else:
                    with path.open("rb") as source, archive.open(entry, "w") as target:
                        # Stream file bytes, including the executable; no whole-app memory buffer.
                        while chunk := source.read(1024 * 1024):
                            target.write(chunk)
    with ZipFile(output) as archive:
        assert f"Payload/{app.name}/Info.plist" in archive.namelist()
        assert f"Payload/{app.name}/{info['CFBundleExecutable']}" in archive.namelist()
    print(f"Packaged unsigned device IPA: {output}")


if __name__ == "__main__":
    package(Path(sys.argv[1]), Path(sys.argv[2]))
