{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm,
  nodejs,
  npmHooks,
  nix-update-script,
  makeBinaryWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vue-language-server";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "vuejs";
    repo = "language-tools";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HsTcA52ZJ/2XpRhG/veD7QQKicwV3LY/AMWkLMoFc+o=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-VPCtEYloSFCOCVwggZjMM7XETpCvQXpvoGFSDjL+xbo=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
    npmHooks.npmBuildHook
    makeBinaryWrapper
  ];

  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/language-tools
    cp -r node_modules $out/lib/language-tools
    cp -r packages $out/lib/language-tools

    makeWrapper ${lib.getExe nodejs} $out/bin/vue-language-server \
      --inherit-argv0 \
      --add-flags $out/lib/language-tools/packages/language-server/bin/vue-language-server.js

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Official Vue.js language server";
    homepage = "https://github.com/vuejs/language-tools#readme";
    changelog = "https://github.com/vuejs/language-tools/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ friedow ];
    mainProgram = "vue-language-server";
  };
})
