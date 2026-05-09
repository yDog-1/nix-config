{
  config,
  pkgs,
  lib,
  ...
}: let
  dictionaries = {
    "L" = pkgs.skkDictionaries.l;
    # "JIS2" = pkgs.skkDictionaries.jis2;
    # "JIS3_4" = pkgs.skkDictionaries.jis3_4;
    # "geo" = pkgs.skkDictionaries.geo;
    # "jinmei" = pkgs.skkDictionaries.jinmei;
    # "lisp" = pkgs.skkDictionaries.lisp;
    # "propernoun" = pkgs.skkDictionaries.propernoun;
    # "station" = pkgs.skkDictionaries.station;
  };

  # XDGデータディレクトリのSKKパス
  skkDataDir = "${config.xdg.dataHome}/skk";

  # 辞書ファイルのフルパスリスト
  dictPaths =
    lib.mapAttrsToList (
      suffix: _: "${skkDataDir}/SKK-JISYO.${suffix}"
    )
    dictionaries;
in {
  xdg.dataFile =
    lib.mapAttrs' (
      suffix: pkg:
        lib.nameValuePair "skk/SKK-JISYO.${suffix}" {
          source = "${pkg}/share/skk/SKK-JISYO.${suffix}";
        }
    )
    dictionaries;

  # 環境変数設定
  home.sessionVariables = {
    # 辞書ディレクトリパス
    SKK_DICT_PATH = skkDataDir;

    # フルパスの辞書ファイル一覧（コンマ区切り）
    SKK_DICT_PATHS = lib.concatStringsSep "," dictPaths;
  };
}
