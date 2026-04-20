# WSL 環境セットアップスクリプト — step0

WSL2 Ubuntu 環境を複製するためのスクリプト集。詳細な手順は [setup.md](setup.md) を参照。

## スクリプト一覧

### `step0.sh` — gh を apt で一時インストール

SSH 認証前にプライベートリポジトリを取得するため、`gh` を apt で一時的にインストールする。

```bash
bash step0.sh
```

### `step9.sh` — apt 版 gh を削除

Home Manager 経由で `gh` が管理されるようになった後、apt 版を削除する。

```bash
bash step9.sh
```

## 次のステップ

メインセットアップは [WhiteOctpus/step1](https://github.com/WhiteOctpus/step1) を参照。
