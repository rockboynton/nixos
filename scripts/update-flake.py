#!/usr/bin/env python3
"""Update the flake and verify the Cargo vendor hashes before rebuilding."""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys


TARGETS = {
    "niri-src": "hosts/nixos/default.nix",
    "zellij-src": "home/common.nix",
}
FAKE_HASH = "sha256-" + "A" * 43 + "="


def vendor_hash(nix, root, source):
    # Use the same fetchCargoVendor arguments as the local package overrides.
    def build(hash_value):
        expression = f'''
          let
            flake = builtins.getFlake {json.dumps("path:" + str(root))};
            pkgs = flake.inputs.nixpkgs.legacyPackages.x86_64-linux;
          in pkgs.rustPlatform.fetchCargoVendor {{
            src = flake.inputs.{source};
            hash = {json.dumps(hash_value)};
          }}
        '''
        return subprocess.run(
            [nix, "build", "--impure", "--no-link", "--no-write-lock-file",
             "--log-format", "raw", "--expr", expression],
            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            env={**os.environ, "NO_COLOR": "1"},
        )

    probe = build(FAKE_HASH)
    hashes = re.findall(r"^\s*got:\s+(sha256-[A-Za-z0-9+/]{43}=)\s*$",
                        probe.stdout, re.MULTILINE)
    if probe.returncode == 0 or len(hashes) != 1:
        raise RuntimeError(f"Cannot determine {source} Cargo hash:\n{probe.stdout}")
    verified = build(hashes[0])
    if verified.returncode:
        raise RuntimeError(f"Cannot verify {source} Cargo hash:\n{verified.stdout}")
    return hashes[0]


def update(root, nix, hashes_only=False):
    paths = [root / "flake.lock", *(root / name for name in TARGETS.values())]
    originals = {path: path.read_bytes() for path in paths}
    replacements = {}
    try:
        if not hashes_only:
            subprocess.run([nix, "flake", "update", "--flake", f"path:{root}"],
                           check=True)
        for source, name in TARGETS.items():
            path = root / name
            text = originals[path].decode()
            # Refuse to edit if the vendor definition changes shape or is ambiguous.
            pattern = (r"(cargoDeps = pkgs\.rustPlatform\.fetchCargoVendor \{\s*"
                       r"src = inputs\." + re.escape(source) + r";\s*hash = \")"
                       r"sha256-[A-Za-z0-9+/]{43}=(\";\s*\};)")
            if len(re.findall(pattern, text)) != 1:
                raise RuntimeError(f"Expected one simple Cargo vendor definition in {path}")
            print(f"Refreshing {source} Cargo hash…", flush=True)
            hash_value = vendor_hash(nix, root, source)
            replacements[path] = re.sub(
                pattern, lambda match: match[1] + hash_value + match[2], text,
            ).encode()
            print(f"Verified {source}: {hash_value}", flush=True)
        for path, content in replacements.items():
            if content != originals[path]:
                path.write_bytes(content)
    except BaseException:
        # Keep the previous lock/hash pair, including any pre-existing local edits.
        for path, content in originals.items():
            if path.read_bytes() != content:
                path.write_bytes(content)
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--flake", type=Path, required=True)
    parser.add_argument("--nix", default="nix")
    parser.add_argument("--hashes-only", action="store_true",
                        help="Refresh hashes for the existing lockfile without bumping inputs")
    args = parser.parse_args()
    try:
        update(args.flake.resolve(), args.nix, args.hashes_only)
    except (OSError, RuntimeError, subprocess.CalledProcessError) as error:
        print(error, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
