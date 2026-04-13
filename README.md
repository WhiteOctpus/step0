# WSL 環境セットアップスクリプト

WSL2 Ubuntu 環境を複製するためのスクリプト集。詳細な手順は [setup.md](setup.md) を参照。

## スクリプト一覧

### `step0.sh` — gh を apt で一時インストール

SSH 認証前にプライベートリポジトリを取得するため、`gh` を apt で一時的にインストールする。

```bash
bash step0.sh
```

### `step1.sh` — メインセットアップ

以下を順番に自動実行する：

1. zsh + 日本語ロケール
2. nix インストール（--no-daemon）
3. Nix Flakes 有効化
4. chezmoi で dotfiles を展開
5. Home Manager でパッケージ一式をインストール
6. mise インストール + ランタイム（node, python など）
7. uv インストール
8. Claude Code インストール
9. nb notebooks セットアップ

```bash
bash step1.sh
```

### `step9.sh` — apt 版 gh を削除

Home Manager 経由で `gh` が管理されるようになった後、apt 版を削除する。

```bash
bash step9.sh
```
