{ fetchFromGitHub, lib, rustPlatform, pkg-config, openssl, cmake, perl, cacert, ... }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kcl-language-server";
  version = "0.2.192";

  src = fetchFromGitHub {
    owner = "rockboynton";
    repo = "modeling-app";
    rev = "eb9ca6006d36ecd5ab9a4d15c2be722010746047";
    hash = "sha256-1UQf3bI+9caK/fciR6t4OUqfW8ep86jgR4iGJVkmxHI=";
  };
  sourceRoot = "source/rust";

  cargoLock = {
    lockFile = "${finalAttrs.src}/rust/Cargo.lock";
    outputHashes."gltf-1.3.0" = "sha256-5S5M2LiWSiHBcVhX83hcsH1+XDry/snN9mRA8kKsqrs=";
  };
  cargoBuildFlags = [ "-p" "kcl-language-server" "--bin" "kcl-language-server" ];
  cargoTestFlags = [ "-p" "kcl-language-server" "--bin" "kcl-language-server" "standalone_execution_diagnostics" ];

  nativeBuildInputs = [ pkg-config cmake perl ];
  buildInputs = [ openssl ];
  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  meta = {
    description = "Language server for Zoo's KCL modeling language";
    homepage = "https://github.com/KittyCAD/modeling-app";
    license = lib.licenses.mit;
    mainProgram = "kcl-language-server";
    platforms = [ "x86_64-linux" ];
  };
})
