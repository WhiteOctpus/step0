# WSL 環境セットアップ手順

## 前提

- Windows に WSL2 がインストール済み
- Ubuntu ディストリビューションを新規作成した直後の状態

## 手順

### 0. gh を一時インストール（step0.sh）

リポジトリは private のため、まず `gh` を apt で一時的にインストールして認証する。

```bash
sudo apt install -y git curl
bash step0.sh

# GitHub 認証（ブラウザが開くので指示に従う）
gh auth login

# リポジトリを取得
gh repo clone WhiteOctpus/step1
```

> `step0.sh` は apt で `gh` をインストールするだけのスクリプト。
> Home Manager が `gh` を管理するようになった後は `step9.sh` で削除する。

### 1. メインセットアップ（step1）

[WhiteOctpus/step1](https://github.com/WhiteOctpus/step1) の手順に従って実行する。

### 2. apt 版 gh を削除（step9.sh）

step1 完了後、Home Manager が `gh` を管理するようになっているため apt 版を削除する。

```bash
bash step9.sh
```

### 3. ターミナル再起動

```bash
exec zsh
```
