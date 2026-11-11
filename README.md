# nix-config

NixOSとHome Managerがインストール済みの環境を、このリポジトリから復旧する手順です。

## リポジトリ

```bash
git clone https://github.com/yDog-1/nix-config.git "$HOME/nix-config"
cd "$HOME/nix-config"
```

リポジトリは必ず`$HOME/nix-config`へ配置します。

## ディレクトリ構成

| パス                       | 役割                                                          |
| -------------------------- | ------------------------------------------------------------- |
| `flake.nix`                | inputsと独立した各出力の組み立て                              |
| `nix/`                     | チェック・開発シェルの定義                                    |
| `hosts/ydog-1/`            | NixOSの入口とホスト固有のハードウェア・マウント・ユーザー設定 |
| `home/ydog-1/`             | standalone Home Managerの入口                                 |
| `modules/nixos/`           | NixOSの機能別設定                                             |
| `modules/home/`            | 用途別のHome Manager設定                                      |
| `layat/ydog-1/default.nix` | dotfilesの配布定義                                            |
| `layat/ydog-1/files/`      | ホームディレクトリと同じ構造のdotfiles                        |
| `lib/`                     | 共通のNix関数・テーマデータ                                   |
| `secrets/`                 | SOPSで暗号化したデータ                                        |

Home Managerの設定は`ai`、`development`、`editors`、`terminal`、`tools`、`shell`、`desktop`、`input`、`secrets`に分類します。カテゴリの`default.nix`から各機能を明示的にimportします。スクリプトなどの関連ファイルがある機能は、`waybar/default.nix`のように同じディレクトリへまとめます。

## NixOS

同じPCへNixOS設定を復旧します。別のPCではハードウェア構成とディスクUUIDを変更する必要があります。

```bash
nix build .#nixosConfigurations.ydog-1.config.system.build.toplevel
sudo nixos-rebuild switch --flake .#ydog-1
```

以降は次のコマンドで更新できます。

```bash
nh os switch
```

## Home Manager

別のユーザーで使う場合は、先に`flake.nix`の`userName`と`homeDirectory`を変更します。

age秘密鍵を配置します。

```bash
install -d -m 700 "$HOME/.config/sops/age"
install -m 600 "/path/to/keys.txt" "$HOME/.config/sops/age/keys.txt"
```

Home Managerを適用します。

```bash
home-manager switch --flake ".#${USER}"
```

## dotfiles

既存の設定ファイルがある場合は、先にバックアップしてからlayatを適用します。

```bash
nix develop --command layat apply ydog-1
```

`layat/ydog-1/files/`以下の通常ファイルを、ホームディレクトリと同じ相対パスへ自動配置します（`default.nix`とシンボリックリンクは対象外）。新しいファイルは`git add`で追跡対象に加え、上記のコマンドを再実行してください。配布定義への個別追加は不要です。

旧構成から更新する場合も、マージ後に`$HOME/nix-config`からこのコマンドを再実行し、リンク先を`layat/ydog-1/files/`へ更新します。worktreeでのレビュー中は適用せず、ビルドによる確認に留めます。

GTKブックマーク（`~/.config/gtk-3.0/bookmarks`）は`method = "copy"`で初回のみ配置し、以後の編集は保持します。既存ファイルは上書きせずスキップするため、読み取り専用の場合は`chmod u+w ~/.config/gtk-3.0/bookmarks`で書き込みを許可してください。`--recopy`は編集内容を上書きし、`layat reset`はコピー先も削除するため注意してください。

これでNixOS、Home Manager、dotfilesの復旧は完了です。これらは独立しているため、必要なものをそれぞれ適用します。

## Zshプラグインの更新

補完初期化はHome Manager側だけで行うため、変更時はNixOSとHome Managerの両方を適用します。

Sheldonの設定はHome Manager管理の`modules/home/shell/sheldon/plugins.toml`で編集します。`home-manager switch`で設定を配置した後、プラグインの同期とzenoのDeno依存キャッシュ準備を自動実行するため、設定変更後の手動同期は不要です。layatではこのファイルを管理しません。

既存構成からの移行も`home-manager switch`で行います。移行前のlayat管理リンクは置き換えられます。リポジトリ更新後は旧リンクが一時的に切れるため、Home Managerも続けて適用してください。

`home-manager switch`ではプラグインを最新版へ一括更新せず、既存のロックを尊重します。プラグイン自体を最新版へ更新するときだけ、次を使います。

```bash
sheldon-sync --update
```

このコマンドはプラグインの更新後にzenoのDeno依存キャッシュを準備し、失敗時にはエラーを返します。依存キャッシュの再準備は`sheldon-sync`、再インストールは`sheldon-sync --reinstall`で行います。

初回の依存取得や更新にはネットワーク接続が必要です。同期やキャッシュ準備に失敗した場合はHome Managerの適用もエラーになります。通常のシェル起動ではキャッシュ準備を実行しません。Enter時の展開・履歴機能は維持します。

## 確認

```bash
nix flake check --print-build-logs
nix build --no-link .#layat.x86_64-linux.ydog-1
```
