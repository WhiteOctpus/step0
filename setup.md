# WSL 環境セットアップ手順

## 前提

- Windows に WSL2 がインストール済み
- Ubuntu ディストリビューションを新規作成した直後の状態

## ツール役割分担

| ツール | 担当 |
|---|---|
| nix / Home Manager | CLIツール・nvim本体のパッケージ管理 |
| mise | 言語ランタイム（node, python, ...） |
| uv | Python パッケージ管理 |
| claude-code | Anthropic 公式インストーラーで管理（自己更新のため） |
| chezmoi | dotfiles（~/.config/nvim/ など） |

## 手順

### 0. gh を一時インストール（step0.sh）

リポジトリは private のため、まず `gh` を apt で一時的にインストールして認証する。

```bash
# step0.sh を直接実行するか、手動で同等の操作を行う
sudo apt install -y git curl
bash step0.sh

# GitHub 認証（ブラウザが開くので指示に従う）
gh auth login

# リポジトリを取得
gh repo clone WhiteOctpus/dotfiles-mini
```

> `step0.sh` は apt で `gh` をインストールするだけのスクリプト。
> Home Manager が `gh` を管理するようになった後は `step9.sh` で削除する。

### 1. リポジトリ取得後、スクリプト実行（step1.sh）

```bash
bash dotfiles-mini/step1.sh
```

スクリプトが自動で以下を順番に実行する：

1. zsh + 日本語ロケールのインストール
2. nix インストール（--no-daemon）
3. Nix Flakes 有効化
4. chezmoi をブートストラップして dotfiles を展開
5. Home Manager で全パッケージをインストール
6. mise インストール + ランタイム（node, python）のインストール
7. uv インストール
8. Claude Code インストール

### 2. apt 版 gh を削除（step9.sh）

`step1.sh` 完了後、Home Manager が `gh` を管理するようになっているため apt 版を削除する。

```bash
bash step9.sh
```

### 3. ターミナル再起動

```bash
exec zsh
```

### 4. 確認

```bash
# 各ツールの動作確認
zsh --version
nix --version
home-manager --version
mise --version
uv --version
claude --version
nvim --version
```

## 事後作業

### SSH 鍵の設定（GitHub 連携が必要な場合）

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
# GitHub に公開鍵を登録
```

### atuin の同期設定

```bash
atuin login
atuin sync
```

### mise ランタイムの確認

```bash
mise list
```

## dotfiles の更新方法

```bash
# 変更を反映
chezmoi apply

# パッケージの追加・変更後
home-manager switch --flake ~/.config/home-manager#nari
```

## トラブルシューティング

**`nix: command not found` と出る場合**
```bash
. ~/.nix-profile/etc/profile.d/nix.sh
```

**`home-manager switch` が失敗する場合**

`~/.config/home-manager/home.nix` が chezmoi によって配置されているか確認する。
```bash
ls ~/.config/home-manager/
```

**mise のランタイムが入らない場合**
```bash
export PATH="$HOME/.local/bin:$PATH"
mise install
```
