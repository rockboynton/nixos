{ autoPatchelfHook, fetchurl, gzip, lib, stdenv, stdenvNoCC, ... }:

stdenvNoCC.mkDerivation {
  pname = "kcl-language-server";
  version = "0.2.188";

  src = fetchurl {
    url = "https://github.com/KittyCAD/modeling-app/releases/download/kcl-188/kcl-language-server-x86_64-unknown-linux-gnu.gz";
    hash = "sha256-yWVQuFqR+/sMc3QsYPR07P9yxsSk/jznlrrjWZTwHAQ=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook gzip ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    gzip -dc $src > $out/bin/kcl-language-server
    chmod +x $out/bin/kcl-language-server

    runHook postInstall
  '';

  meta = {
    description = "Language server for Zoo's KCL modeling language";
    homepage = "https://github.com/KittyCAD/modeling-app";
    license = lib.licenses.mit;
    mainProgram = "kcl-language-server";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
