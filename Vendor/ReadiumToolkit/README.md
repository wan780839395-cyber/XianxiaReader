# Maintained Readium integration

Upstream: Readium Swift Toolkit 3.11.0, revision d82f44f4f05d87add9e22a8b75abbd61dce745dd, BSD-3-Clause (LICENSE).
This is XianxiaReader's explicitly maintained local extension, NOT an official merged release.

Only Shared, Streamer, Navigator and Internal sources/resources are included. The manifest retains upstream remote dependency constraints but excludes unused products/test publications. Navigator preference integration is adapted from Eugene Martinson / emartinson's PR811 (https://github.com/readium/swift-toolkit/pull/811); the whole-book placeholder implementation is replaced by XianxiaReader's bounded fixed-viewport resource window.

UPSTREAM.json records original Git blob hashes and explicitly changed files. Validate with scripts/check_repository.py. Source modifications require a reviewed provenance update and full iOS CI; never patch SourcePackages caches. Original binary assets and DOM scripts remain unchanged. Copyright notices and binary ThirdPartyNotices are retained.

Continuous mode currently targets horizontal LTR reflowable EPUB. Fixed layout, RTL and vertical writing retain the original paths. The stable paginated/chapter-scrolling implementations and SearchService API remain available. Verify real two-resource boundaries, reverse movement, DOM locator restoration, reflow anchor stability and resource bounds before shipping.
