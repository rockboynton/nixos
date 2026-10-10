{ appimageTools, fetchurl, lib, imagemagick, ... }:
let
  pname = "zoo-design-studio";
  version = "1.4.11";

  src = fetchurl {
    url = "https://github.com/KittyCAD/modeling-app/releases/download/v${version}/Zoo.Design.Studio-${version}-x86_64-linux.AppImage";
    hash = "sha256-rAk+zUtw53Z00m9Tw5qh7TXkE4WUrI+enUuSG5qypQI=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = let legacyName = "zoo-modeling-app"; in /* bash */ ''
    install -m 444 -D ${appimageContents}/${legacyName}.desktop $out/share/applications/${legacyName}.desktop
    ${imagemagick}/bin/magick ${appimageContents}/${legacyName}.png -resize 512x512 ${legacyName}_512.png
    install -m 444 -D ${legacyName}_512.png $out/share/icons/hicolor/512x512/apps/${legacyName}.png
    substituteInPlace $out/share/applications/${legacyName}.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' "Exec=$out/bin/${pname}"
  '';

  meta = with lib; {
    description = "Zoo Design Studio – 3D modeling app";
    homepage = "https://zoo.dev/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
