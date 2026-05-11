{
  inputs,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "moralerspace-hw";
  version = "2.0.0";

  src = inputs.moralerspace-hw;

  installPhase = ''
    runHook preInstall

    install -dm755 "$out/share/fonts/truetype"
    find . -type f \( -name "*.ttf" -o -name "*.otf" \) \
      -exec install -Dm644 -t "$out/share/fonts/truetype" {} +

    runHook postInstall
  '';
}
