#!/bin/sh
set -x # debug
set -e
set -u
set -o pipefail

SWIFT_PACKAGE_DIR="${BUILD_DIR%Build/*}SourcePackages/artifacts"
SWIFTLINT_CMD=$(ls "$SWIFT_PACKAGE_DIR"/swiftlintplugins/SwiftLintBinary/SwiftLintBinary.artifactbundle/swiftlint-*-macos/bin/swiftlint | head -n 1)

if test -f "$SWIFTLINT_CMD" 2>&1
then
    "$SWIFTLINT_CMD" --config ${SOURCE_ROOT}/Tools/Scripts/SwiftLint/swiftlint.yml --quiet
else
    echo "warning: `swiftlint` command not found - See https://github.com/realm/SwiftLint#installation for installation instructions."
fi
