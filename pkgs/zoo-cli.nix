{ fetchFromGitHub, lib, rustPlatform, pkg-config, openssl, cmake, perl, cacert, ... }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zoo";
  version = "0.2.204";

  src = fetchFromGitHub {
    owner = "rockboynton";
    repo = "cli";
    rev = "ef059083f4376a12aa8410764d7f32ca0968ce65";
    hash = "sha256-HhCbb+5AZ2QMyaiqI8IY0zGZWsBKiyfc+a7PZoF8zPM=";
  };

  cargoLock = {
    lockFile = "${finalAttrs.src}/Cargo.lock";
    outputHashes = {
      "kcl-api-0.2.192" = "sha256-amnKWthxdCg7PR0JjMbMknmBYsFRJZayzo1UUlKwGxA=";
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
