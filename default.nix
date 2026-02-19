{ stdenvNoCC, lib, makeWrapper, bash, bubblewrap, coreutils, findutils, gawk, nix }:

let
  runtimeDependencies = [
    bash
    bubblewrap
    coreutils
    findutils
    gawk
    nix
  ];
in
stdenvNoCC.mkDerivation {
  pname = "nix-sandbox";
  version = "0.1.0";
  src = ./.;

  meta.mainProgram = "nix-sandbox";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/nix-sandbox
    cp $src/nix-sandbox $out/bin/
    cp $src/shell.nix $out/share/nix-sandbox/shell.nix
    chmod +x $out/bin/nix-sandbox
  '';

  postFixup = ''
    wrapProgram $out/bin/nix-sandbox \
      --set PATH ${lib.makeBinPath runtimeDependencies}
  '';

  passthru.runtimeDependencies = runtimeDependencies;
}
