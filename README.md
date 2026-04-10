# ssh認証前のgitアクセス

## スクリプト2つ

### `install_gh_apt.sh`

GitHub CLI (`gh`) を apt で一時的にインストールする。

```bash
bash install_gh_apt.sh
```

### `migrate_gh_to_nix.sh`

apt 版の `gh` を削除する。

```bash
bash migrate_gh_to_nix.sh
```

