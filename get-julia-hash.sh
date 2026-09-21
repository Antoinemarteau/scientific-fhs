  # Usage: ./get-julia-hash.sh vX.Y.Z
  set -euo pipefail
  version="${1#v}"
  majorMinor="${version%.*}"
  url="https://julialang-s3.julialang.org/bin/linux/x64/${majorMinor}/julia-${version}-linux-x86_64.tar.gz"
  hash=$(nix-prefetch-url --type sha256 "$url")
  nix hash to-sri --type sha256 "$hash"
