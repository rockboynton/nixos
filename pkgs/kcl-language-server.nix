{ fetchFromGitHub, lib, rustPlatform, pkg-config, openssl, cmake, perl, cacert, ... }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kcl-language-server";
  version = "0.2.191";

  src = fetchFromGitHub {
    owner = "rockboynton";
    repo = "modeling-app";
    rev = "966542dc32be77dfc40ae57b573720d2fb5f1abf";
    hash = "sha256-nYRSbM/sFdWqO6AwSIq/Xkxg+Gn0ymwken+KARVTqu4=";
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
