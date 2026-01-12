#!/usr/bin/env bash
set -euo pipefail

# Installs a local Dart SDK into the repository under .dart-sdk.
# Usage: DART_CHANNEL=stable DART_PLATFORM=linux-x64 DART_VERSION=latest ./scripts/install_dart.sh

CHANNEL=${DART_CHANNEL:-stable}
PLATFORM=${DART_PLATFORM:-linux-x64}
VERSION=${DART_VERSION:-latest}
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)/.dart-sdk"
ARCHIVE="dartsdk-${PLATFORM}-release.zip"
BASE_URL="https://storage.googleapis.com/dart-archive/channels/${CHANNEL}/release/${VERSION}/sdk"
DOWNLOAD_URL="${BASE_URL}/${ARCHIVE}"

cleanup() {
  [[ -n "${TMPDIR:-}" && -d "$TMPDIR" ]] && rm -rf "$TMPDIR"
}
trap cleanup EXIT

TMPDIR=$(mktemp -d)

echo "Downloading Dart SDK from ${DOWNLOAD_URL}..."
curl -fL "$DOWNLOAD_URL" -o "$TMPDIR/${ARCHIVE}"

echo "Extracting Dart SDK to ${INSTALL_DIR}..."
rm -rf "$INSTALL_DIR"
unzip -q "$TMPDIR/${ARCHIVE}" -d "$TMPDIR"
mv "$TMPDIR/dart-sdk" "$INSTALL_DIR"

BIN_PATH="$INSTALL_DIR/bin"
cat <<EONOTE

Dart SDK installed locally at: $INSTALL_DIR
Add it to your PATH for this shell session with:
  export PATH="$BIN_PATH:$PATH"

Then verify installation using:
  dart --version
EONOTE
