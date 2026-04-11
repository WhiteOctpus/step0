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

### 1. リポジトリ取得

リポジトリは private のため、gh CLI 経由で取得する。

```bash
# 最低限のツールをインストール
sudo apt install -y git gh curl

# GitHub 認証（ブラウザが開くので指示に従う）
gh auth login

# リポジトリを取得
gh repo clone WhiteOctpus/dotfiles-mini
```

### 2. スクリプト実行

```bash
bash dotfiles-mini/setup.sh
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
