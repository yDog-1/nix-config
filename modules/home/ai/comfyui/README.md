# GTX 1080 向け ComfyUI

Home Manager が起動コマンドと Nix の Python 3.12 を提供し、`uv` がレビュー済みの
ハッシュ付き `requirements.lock` に従って、書き込み可能な専用環境へ依存関係を導入します。
CUDA と cuDNN は nixpkgs ではなく、固定した PyTorch wheel の依存関係から導入します。
初期の cu126 構成は[公式の環境定義](https://github.com/Comfy-Org/ComfyUI-Standalone-Environments/blob/main/requirements-nvidia-cu126.txt)に合わせています。
cuDNN 9.10.2 の指定は意図的です。9.11 以降では Pascal 対応が削除されています。

## 導入と起動

Home Manager の設定を適用してから、以下を実行します。

```sh
comfyui-setup
comfyui
```

ブラウザーで <http://127.0.0.1:8188> を開きます。モデル、入力、出力、ワークフロー、
カスタムノードは `${XDG_DATA_HOME:-$HOME/.local/share}/ComfyUI` 以下に保存します。
待受アドレスは `0.0.0.0` です。他の端末からは `http://<このマシンのIPアドレス>:8188` で接続します。
ファイアウォールは自動では開放しません。認証を設定せずに、インターネットへ直接公開しないでください。
セットアップではモデルをダウンロードしません。候補環境を有効化する前に、CUDA 演算、
cuDNN を明示的に使う畳み込み演算、ComfyUI の起動を検証します。
画像生成には、別途入手したチェックポイントとワークフローが必要です。

Attention や VRAM 関連の回避策は強制しません。必要な場合だけフラグを指定します。

```sh
comfyui --lowvram
comfyui --disable-dynamic-vram
comfyui-check
```

DynamicVRAM が有効な間、`--lowvram` は効果がありません。
上流では回避用の `--disable-dynamic-vram` も非推奨になっているため、
常に必要な設定として依存しないようにしてください。

## 安全なセットアップと修復

- 通常のセットアップでは、実行環境 ID が一致する場合、現在の環境を再利用します。
- `comfyui-repair` は新しい環境を作成して検証します。既存の環境は削除しません。
- ロックによりセットアップと修復の同時実行を防ぎます。有効化時には `current` を
  アトミックに置き換え、それまで使用していた管理対象の環境を `previous` に記録します。
- 失敗した場合は `current` を変更せず、調査用に候補環境を残します。
- 従来の `app`、`.venv`、`constraints.txt`、`requirements.lock` は置き換えません。
  新方式での最初のセットアップが成功するまでは、起動コマンドから従来の環境も使用できます。
- 各候補環境の `environments/<id>/runtime` には、間接的な Nix GC ルートを作成します。
  これにより、Home Manager の更新や Nix GC の後も、その環境に必要なソースと Python を保持します。
  古い候補環境は自動では削除しません。

前の管理対象環境へ戻す場合は、ComfyUI を停止してから以下を実行します。

```sh
data="${XDG_DATA_HOME:-$HOME/.local/share}/ComfyUI"
(
  flock -n 9 || exit 1
  test -f "$data/previous/ready" || exit 1
  ln -s "$(readlink -f "$data/previous")" "$data/.rollback.$$"
  mv -Tf "$data/.rollback.$$" "$data/current"
) 9>"$data/.setup.lock"
```

戻るのは**実行環境だけ**です。共有データやデータベースの移行は元に戻りません。
ComfyUI の更新前に `user/` をバックアップしてください。不要な環境を削除する場合は、
`current` と `previous` のどちらからも参照されていないことを先に確認してください。
環境のディレクトリを削除すると、その GC ルートも削除されます。
実行中の環境は削除しないでください。

## 依存関係の更新

1. 上流リリースのコミットと Nix ソースハッシュを確認して `source.nix` を更新します。
   GPU 関連の依存構成を意図的に変更する場合は、`constraints.txt` も更新します。
2. 新しい Home Manager パッケージをビルドし、その中の `comfyui-update-lock` を使います。

   ```sh
   comfyui-update-lock modules/home/ai/comfyui/requirements.lock
   ```

3. lock ファイルの差分をレビューしてコミットします。通常のセットアップでは、
   `--require-hashes --strict --only-binary :all:` を指定して固定済みの依存関係を同期するだけで、
   依存関係の解決は行いません。
4. 新しい lock で Home Manager を再ビルドし、まず隔離したデータディレクトリで
   セットアップを実行します。本番データへ切り替える前に、SD 1.5 で実際に画像を生成して確認します。

初期の lock は Python 3.12、Linux x86_64 manylinux 2.28 向けに、
`2026-10-28T00:00:00Z` より前に公開されたパッケージを対象として解決しています。
明示的な更新コマンドでは、意図的に新しい依存関係も許可します。
カスタムノードのインストーラーにも主要な GPU 関連パッケージのバージョン制約を適用しますが、
カスタムノード自体は本体用の lock に含めません。

## テスト

```sh
python3 modules/home/ai/comfyui/test_setup.py -v
nix build --no-link .#checks.x86_64-linux.comfyui-setup
```

環境の作成・切り替えに関するテストには模擬インストーラーを使うため、
ネットワーク接続も GPU も不要です。実 GPU の検証は、別途 `comfyui-check` で行います。
