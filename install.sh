#!/bin/sh
set -eu

repository="Nabwinsaud/mantra"

case "$(uname -s)" in
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew is required on macOS: https://brew.sh" >&2
      exit 1
    fi
    exec brew install Nabwinsaud/tap/mantra
    ;;
  Linux) ;;
  *)
    echo "Unsupported operating system: $(uname -s)" >&2
    exit 1
    ;;
esac

if ! command -v dpkg >/dev/null 2>&1 || ! command -v apt-get >/dev/null 2>&1; then
  echo "This installer currently supports Debian/Ubuntu Linux and macOS." >&2
  echo "Arch Linux support will use the upcoming mantra AUR package." >&2
  exit 1
fi

architecture="$(dpkg --print-architecture)"
case "$architecture" in
  amd64 | arm64) ;;
  *)
    echo "Unsupported Debian architecture: $architecture" >&2
    exit 1
    ;;
esac

latest_url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$repository/releases/latest")"
tag="${latest_url##*/}"
version="${tag#v}"
package="mantra_${version}-1_${architecture}.deb"
base_url="https://github.com/$repository/releases/download/$tag"
temporary_directory="$(mktemp -d)"
trap 'rm -rf "$temporary_directory"' EXIT HUP INT TERM

curl -fsSL "$base_url/$package" -o "$temporary_directory/$package"
curl -fsSL "$base_url/SHA256SUMS" -o "$temporary_directory/SHA256SUMS"
(
  cd "$temporary_directory"
  expected="$(grep "  $package\$" SHA256SUMS)"
  test -n "$expected"
  printf '%s\n' "$expected" | sha256sum --check -
)

if [ "$(id -u)" -eq 0 ]; then
  apt-get install --yes "$temporary_directory/$package"
elif command -v sudo >/dev/null 2>&1; then
  sudo apt-get install --yes "$temporary_directory/$package"
else
  echo "Installing Mantra requires root privileges or sudo." >&2
  exit 1
fi
mantra --version
