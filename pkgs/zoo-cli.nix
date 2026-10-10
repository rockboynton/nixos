{ fetchurl, lib, stdenvNoCC, ... }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zoo";
  version = "0.2.203";

  src = fetchurl {
    url = "https://github.com/KittyCAD/cli/releases/download/v${finalAttrs.version}/zoo-x86_64-unknown-linux-musl";
    hash = "sha256-hqculBNs8PwKyq7zCbq3n5yUDYnCeGibad/MRCMd9Dw=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/zoo

    runHook postInstall
  '';

  meta = {
    description = "Command-line interface for Zoo";
    homepage = "https://github.com/KittyCAD/cli";
    license = lib.licenses.mit;
    mainProgram = "zoo";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
