{ stdenv, lib, fetchurl, zlib, glib, libxi, libxcb, libxrender, libx11, libsm, libice, libxext, dbus, fontconfig, freetype, libGL, juliaVersion }:

let
  # To find the sha256 for a new version instead of guessing and rebuilding,
  # save the following as get-julia-hash.sh and run e.g. `./get-julia-hash.sh v1.13.0`:
  #
  #   #!/usr/bin/env bash
  #   # Usage: ./get-julia-hash.sh vX.Y.Z
  #   set -euo pipefail
  #   version="${1#v}"
  #   majorMinor="${version%.*}"
  #   url="https://julialang-s3.julialang.org/bin/linux/x64/${majorMinor}/julia-${version}-linux-x86_64.tar.gz"
  #   hash=$(nix-prefetch-url --type sha256 "$url")
  #   nix hash to-sri --type sha256 "$hash"
  versionShas = {
    "1.13.0" = "sha256-iXXaYcEopeXe0+cZ6GjajIeB3reteRPTf7mb4CqBkEs=";
    "1.12.7" = "sha256-Tn6ed2Y00kg1JQ3mfN45sNSvFbxDLrIGl+a+bCjqaeg=";
    "1.12.6" = "sha256-u6vzvvGUIanb0kp2fYB2BquF5EQyO1occ//ik/o9B5o=";
    "1.12.5" = "sha256-QbhNcn5Olvvz7Z6S+hlddz0ke5CX9z+taI+LaZdYuuc=";
    "1.12.2" = "sha256-ptDDnqVzA+vP+nqNRTQpuG6yceFQx8sPWVj+ZZCbSTo=";
    "1.12.1" = "sha256-fSrdnudO4vErXCaLwZR5TMUupED4aH+6sp22r++/abc=";
    "1.11.5" = "sha256-cj6HjGQiIMwCUaDhN1jAWaOJytx/ATdv6vHqc4j+j5w=";
    "1.11.1" = "sha256-zKjRPcRQfk9ioSkyIpMxPuV08wDU3559swt7QcX4qPM=";
    "1.11.6" = "sha256-6Z5S4gKdhFCXxo8jctg2GG8Os/uJep3eC9+e6SUNA9U=";
    "1.11.0" = "sha256-vPgVVT/aLteRBSTIyqGJyOgZGkCnmd2LX77Q2d1riCw=";
    "1.11.0-rc1" = "sha256-2dfKgQhxhau7ijdcQfc03upuomrvLcQNmUZ/jFx8yNY=";
    "1.10.12" = "sha256-sMUN/jSddv/IWA0k4MC+YjmIptke1XrYtzwBN/0nvA0=";
    "1.10.10" = "sha256-anigOnHHq3kuhnPcXO25GOA38IHOtYtQlx37fGTFv4E=";
    "1.10.9" = "sha256-Wi0sUiRZS2g8l+cwTLckB/vPC+SgGHeJy6Gi9z8Mvwk=";
    "1.10.4" = "sha256-B59hdXw7W0DSreBSs8xIFvUPfvbfZogldyVis3Rq3/E=";
    "1.10.1" = "sha256-/pJCWOVdB0QQsTQZXPa4XL6PMH/NBaT90j+JRMWUGnA=";
    "1.10.0" = "sha256-pymCB/cvKyeyqxzjkqbqN6+9H77g8fjRkLBU3KuoeP4=";
    "1.10.0-beta2" = "sha256-8aF/WlKYDBZ0Fsvk7aFEGdgY87dphUARVKOlZ4edZHc=";
    "1.10.0-beta1" = "sha256-zaOKLdWw7GBcwH/6RO/T6f4QctsmUllT0eJPtDLgv08=";
    "1.9.4" = "sha256-B9IMTCUYgz4iZcoKzuFbNVRjNhqk79q4WNrYJs+UMlw=";
    "1.9.3" = "sha256-12ZwzJuj4P1MFUXdPQAmnAaUl2oRdjEnlevOFpLTI9E=";
    "1.9.2" = "sha256-TC15n0Qtf+cYgnsZ2iusty6gQbnOVfJO7nsTE/V8Q4M=";
    "1.9.0" = "sha256-AMYURm75gJwusjSA440ZaixXf/8nMMT4PRNbkT1HM1k=";
    "1.8.3" = "sha256-M8Owk1b/qiXTMxw2RrHy1LCZROj5P8uZSVeAG4u/WKk=";
    "1.7.2" = "sha256-p1JEck87LeDnJJyGH79kB4JXwW+0IDvnjxz03VlzupU=";
    "1.6.7" = "sha256-bEUi1ZXky80AFXrEWKcviuwBdXBT0gc/mdqjnkQrKjY=";
  };
  makeStdJulia = version: let
    url = "https://julialang-s3.julialang.org/bin/linux/x64/${
      lib.versions.majorMinor version
    }/julia-${version}-linux-x86_64.tar.gz";
    src = fetchurl {
      inherit url;  sha256=versionShas.${version};
    };
  in makeJulia version src;
  makeJulia = version: src:
    stdenv.mkDerivation {
      name = "julia-${version}";
      src = src;
      installPhase = ''
        mkdir $out
        cp -R * $out/

        # Patch for https://github.com/JuliaInterop/RCall.jl/issues/339.

        echo "patching $out"
        cp -L ${stdenv.cc.cc.lib}/lib/libstdc++.so.6 $out/lib/julia/
      '';
      dontStrip = true;
      ldLibraryPath = lib.makeLibraryPath [
        stdenv.cc.cc
        zlib
        glib
        libxi
        libxcb
        libxrender
        libx11
        libsm
        libice
        libxext
        dbus
        fontconfig
        freetype
        libGL
      ];
    };
  julia = (makeStdJulia juliaVersion);
in
julia
