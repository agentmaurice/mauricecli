#!/usr/bin/env bash
set -euo pipefail

BIN_NAME="maurice"
LEGACY_BIN_NAME="mauricecli"
ENDPOINT="${MAURICECLI_UPDATE_ENDPOINT:-https://get.agentmaurice.ai/products/mauricecli/latest.json}"
CHANNEL="${MAURICECLI_UPDATE_CHANNEL:-stable}"
PUBLIC_KEY="${MAURICECLI_MINISIGN_PUBLIC_KEY:-RWT2dtVKMzMezZOuTS4bQoM1kEix9oTYEq5j5mIOYJaskfsvHC+qNBVp}"
INSTALL_DIR=""
VERSION=""

usage() {
  cat <<EOF
Install or update ${BIN_NAME} from the AgentMaurice update gateway.

Usage:
  curl -fsSL https://raw.githubusercontent.com/agentmaurice/mauricecli/main/scripts/install_mauricecli.sh | bash

Options:
  -v, --version <tag>   Require a specific latest manifest version. Default: latest
  -b, --bin-dir <dir>   Install directory. Default: /usr/local/bin or ~/.local/bin
  -c, --channel <name>  Update channel. Default: stable
  -h, --help            Show help
EOF
}

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: $1 is required" >&2
    exit 1
  fi
}

dl() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -A "mauricecli-installer" "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then
    wget --user-agent="mauricecli-installer" -O "$2" "$1"
  else
    echo "Error: curl or wget is required" >&2
    exit 1
  fi
}

manifest_url() {
  case "$ENDPOINT" in
    *\?*) printf '%s&channel=%s' "$ENDPOINT" "$CHANNEL" ;;
    *) printf '%s?channel=%s' "$ENDPOINT" "$CHANNEL" ;;
  esac
}

detect_os_arch() {
  uname_s=$(uname -s | tr '[:upper:]' '[:lower:]')
  case "$uname_s" in
    linux) os=linux ;;
    darwin) os=darwin ;;
    *) echo "Unsupported OS: $uname_s" >&2; exit 1 ;;
  esac
  uname_m=$(uname -m)
  case "$uname_m" in
    x86_64|amd64) arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) echo "Unsupported arch: $uname_m" >&2; exit 1 ;;
  esac
  echo "$os" "$arch"
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      -v|--version) VERSION="$2"; shift 2 ;;
      -b|--bin-dir) INSTALL_DIR="$2"; shift 2 ;;
      -c|--channel) CHANNEL="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
    esac
  done
}

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

main() {
  parse_args "$@"
  need jq
  need minisign

  if [ -z "$PUBLIC_KEY" ]; then
    echo "Error: MAURICECLI_MINISIGN_PUBLIC_KEY must be configured in this installer." >&2
    exit 1
  fi

  read -r os arch < <(detect_os_arch)
  key="${os}/${arch}"

  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT

  manifest="$tmpdir/latest.json"
  url="$(manifest_url)"
  echo "Fetching manifest ${url}"
  dl "$url" "$manifest"

  latest_version=$(jq -r '.version // empty' "$manifest")
  if [ -z "$latest_version" ]; then
    echo "Error: manifest missing version" >&2
    exit 1
  fi
  if [ -n "$VERSION" ] && [ "$VERSION" != "$latest_version" ]; then
    echo "Error: manifest latest is ${latest_version}, requested ${VERSION}" >&2
    exit 1
  fi

  archive_url=$(jq -r --arg key "$key" '.assets[$key].download_url // empty' "$manifest")
  signature_url=$(jq -r --arg key "$key" '.assets[$key].signature_url // empty' "$manifest")
  expected_sha=$(jq -r --arg key "$key" '.assets[$key].sha256 // empty' "$manifest")
  binary_name=$(jq -r --arg key "$key" '.assets[$key].binary_name // empty' "$manifest")
  format=$(jq -r --arg key "$key" '.assets[$key].format // empty' "$manifest")

  if [ -z "$archive_url" ] || [ -z "$signature_url" ] || [ -z "$expected_sha" ] || [ -z "$binary_name" ]; then
    echo "Error: manifest has no complete asset for ${key}" >&2
    exit 1
  fi

  archive="$tmpdir/package"
  sig="$archive.minisig"
  echo "Downloading ${archive_url}"
  dl "$archive_url" "$archive"
  dl "$signature_url" "$sig"

  actual_sha="$(sha256_file "$archive")"
  if [ "$actual_sha" != "$expected_sha" ]; then
    echo "Error: checksum mismatch" >&2
    exit 1
  fi
  minisign -Vm "$archive" -x "$sig" -P "$PUBLIC_KEY" >/dev/null

  extract="$tmpdir/extract"
  mkdir -p "$extract"
  case "$format" in
    tar.gz|tgz) tar -xzf "$archive" -C "$extract" ;;
    zip) unzip -q "$archive" -d "$extract" ;;
    *) echo "Error: unsupported format ${format}" >&2; exit 1 ;;
  esac

  src="$(find "$extract" -type f -name "$binary_name" -print -quit)"
  if [ -z "$src" ]; then
    echo "Error: binary ${binary_name} not found in archive" >&2
    exit 1
  fi
  chmod 0755 "$src"

  version_json="$("$src" --json version)"
  printf '%s\n' "$version_json" | jq -e '.obfuscated == "true" and .build_profile == "release"' >/dev/null

  if [ -z "$INSTALL_DIR" ]; then
    if [ -w /usr/local/bin ]; then
      INSTALL_DIR="/usr/local/bin"
    else
      INSTALL_DIR="$HOME/.local/bin"
    fi
  fi
  mkdir -p "$INSTALL_DIR"

  install -m 0755 "$src" "$INSTALL_DIR/${BIN_NAME}"
  if [ ! -e "$INSTALL_DIR/${LEGACY_BIN_NAME}" ] || [ -L "$INSTALL_DIR/${LEGACY_BIN_NAME}" ]; then
    ln -sf "$BIN_NAME" "$INSTALL_DIR/${LEGACY_BIN_NAME}" 2>/dev/null || true
  else
    echo "Warning: legacy binary exists and was not replaced: $INSTALL_DIR/${LEGACY_BIN_NAME}" >&2
  fi

  echo "Installed ${BIN_NAME} ${latest_version} to $INSTALL_DIR/${BIN_NAME}"
  echo "Ensure $INSTALL_DIR is in your PATH."
}

main "$@"
