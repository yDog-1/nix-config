# nix-config

NixOSとHome Managerがインストール済みの環境を、このリポジトリから復旧する手順です。

## リポジトリ

```bash
git clone https://github.com/yDog-1/nix-config.git "$HOME/nix-config"
cd "$HOME/nix-config"
```

リポジトリは必ず`$HOME/nix-config`へ配置します。

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

既存の設定ファイルがある場合は、先にバックアップしてからnputを適用します。

```bash
nix develop --command nput apply ydog-1
```

これでNixOS、Home Manager、dotfilesの復旧は完了です。これらは独立しているため、必要なものをそれぞれ適用します。

## 確認

```bash
nix flake check --print-build-logs
nix build --no-link .#nput.x86_64-linux.ydog-1
```
