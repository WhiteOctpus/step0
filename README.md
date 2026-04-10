# today_work

作業用スクリプト置き場。

## スクリプト

### `install_gh_apt.sh`

GitHub CLI (`gh`) を apt で一時的にインストールする。

```bash
bash install_gh_apt.sh
```

### `migrate_gh_to_nix.sh`

apt 版の `gh` を削除し、nix でインストールし直す。

```bash
bash migrate_gh_to_nix.sh
```

> home-manager を使っている場合は `nix profile install` の代わりに `home.packages = [ pkgs.gh ];` を追加する。
