#!/bin/zsh
set -euo pipefail

project_dir="${0:A:h}"
output_dir="${1:-${project_dir}/build}"
stage_dir="$(mktemp -d "${TMPDIR:-/tmp}/quit-all-build.XXXXXX")"
trap 'rm -rf "${stage_dir}"' EXIT
app_dir="${stage_dir}/Quit All.app"
archive_path="${output_dir}/Quit-All-Apple-Silicon.zip"

mkdir -p "${output_dir}" "${app_dir}/Contents/MacOS" "${app_dir}/Contents/Resources"

xcrun clang \
    -O \
    -fobjc-arc \
    -arch arm64 \
    -mmacosx-version-min=13.0 \
    -framework AppKit \
    "${project_dir}/Source/main.m" \
    -o "${app_dir}/Contents/MacOS/Quit All"

cp "${project_dir}/Resources/Info.plist" "${app_dir}/Contents/Info.plist"
cp "${project_dir}/Resources/AppIcon.icns" "${app_dir}/Contents/Resources/AppIcon.icns"
chmod 755 "${app_dir}/Contents/MacOS/Quit All"

# Ad-hoc signing gives the bundle a valid local signature without requiring the
# user to have an Apple Developer account.
xattr -cr "${app_dir}"
codesign --force --deep --sign - "${app_dir}"
codesign --verify --deep --strict "${app_dir}"

ditto -c -k --norsrc --keepParent "${app_dir}" "${archive_path}"

echo "Built ${archive_path}"
