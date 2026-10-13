{ fetchFromGitHub, lib, rustPlatform, pkg-config, openssl, cmake, perl, cacert, ... }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zoo";
  version = "0.2.203";

  src = fetchFromGitHub {
    owner = "rockboynton";
    repo = "cli";
    rev = "af0d34e69067c8713d6f5b07529d8dec55445d16";
    hash = "sha256-uzwQcQTlvSqGA3XWRHPs70P+Q9NxuLm3N8UdseUh73E=";
  };

  cargoLock = {
    lockFile = "${finalAttrs.src}/Cargo.lock";
    outputHashes = {
      "kcl-api-0.2.191" = "sha256-nYRSbM/sFdWqO6AwSIq/Xkxg+Gn0ymwken+KARVTqu4=";
      "openapitor-0.0.9" = "sha256-oVKzUdYDyGn8/wtJJTwaWjMMhfZJ6i+T7+17tJAgdlk=";
    };
  };
  cargoBuildFlags = [ "--bin" "zoo" ];
  cargoTestFlags = [ "--test" "kcl_check" ];

  nativeBuildInputs = [ pkg-config cmake perl ];
  buildInputs = [ openssl ];
  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  meta = {
    description = "Command-line interface for Zoo with offline KCL checking";
    homepage = "https://github.com/KittyCAD/cli";
    license = lib.licenses.mit;
    mainProgram = "zoo";
    platforms = [ "x86_64-linux" ];
  };
})
