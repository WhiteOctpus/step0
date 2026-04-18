#!/bin/bash
set -e

# ============================================================
# 役割分担
#   nix / Home Manager : CLIツール・nvim本体
#   mise               : 言語ランタイム (node, python, ...)
#   uv                 : Pythonパッケージ管理
#   claude-code        : Anthropic 公式インストーラー（自己更新のため）
#   chezmoi            : ~/.config/nvim/ など残りのdotfiles
#
# セットアップ順序
#   1. zsh + ロケール
#   2. nix インストール (--no-daemon)
#   3. flakes 有効化
#   4. nix で chezmoi をブートストラップ
#   5. リポジトリを chezmoi 標準ディレクトリへ移動して apply
#   6. home-manager switch   (パッケージ一式インストール)
#   7. mise インストール
#   8. uv インストール
#   9. claude-code インストール
# ============================================================

# スクリプト自身があるディレクトリ（= クローン済みのリポジトリ）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHEZMOI_DIR="$HOME/.local/share/chezmoi"

echo "=== zsh セットアップ ==="
if ! getent passwd "$USER" | grep -q zsh; then
    sudo apt install -y zsh
    chsh -s "$(which zsh)"
fi
if ! dpkg -l language-pack-ja 2>/dev/null | grep -q "^ii"; then
    sudo apt install -y language-pack-ja
    sudo update-locale LANG=ja_JP.UTF-8
fi

echo "=== Nix セットアップ ==="
if ! command -v nix &>/dev/null; then
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
fi

# nix を現シェルで使えるようにする
# shellcheck disable=SC1090
[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && . "$HOME/.nix-profile/etc/profile.d/nix.sh"

# === Nix プロファイル互換性チェック ===
# 前回の失敗で nix profile install による v2 形式プロファイルが残っていると
# home-manager が内部で使う nix-env と競合する。検出したら v1 にリセットする。
if ! nix-env --query --installed > /dev/null 2>&1; then
    echo "v2 形式のプロファイルを検出。v1 形式にリセットします..."
    rm -f "$HOME/.local/state/nix/profiles/profile"* 2>/dev/null || true
    rm -f "$HOME/.nix-profile" 2>/dev/null || true
fi

echo "=== Nix Flakes 有効化 ==="
mkdir -p "$HOME/.config/nix"
if ! grep -q "experimental-features" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
fi

echo "=== chezmoi ブートストラップ ==="
export PATH="$HOME/.local/bin:$PATH"
if ! command -v chezmoi &>/dev/null; then
    # nix プロファイル形式に依存しない公式インストーラーを使用
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

# クローン済みリポジトリを chezmoi 標準ディレクトリへ移動
if [ "$SCRIPT_DIR" = "$CHEZMOI_DIR" ]; then
    : # 既に正しい場所で実行されている
elif [[ "$SCRIPT_DIR" == "$CHEZMOI_DIR"/* ]]; then
    # CHEZMOI_DIR の中でクローンして実行してしまったケース
    echo "警告: $CHEZMOI_DIR の内側で実行されています。ネストされたディレクトリを削除します..."
    rm -rf "$SCRIPT_DIR"
elif [ ! -d "$CHEZMOI_DIR" ]; then
    mkdir -p "$(dirname "$CHEZMOI_DIR")"
    mv "$SCRIPT_DIR" "$CHEZMOI_DIR"
fi
# ~/.config/chezmoi/chezmoi.toml が存在すれば init スキップ（再実行時はそのまま apply）
if [ -f "$HOME/.config/chezmoi/chezmoi.toml" ]; then
    chezmoi apply --force
else
    chezmoi init --apply --force
fi

echo "=== GitHub 認証セットアップ ==="
if command -v gh &>/dev/null; then
    if ! gh auth status &>/dev/null; then
        echo "GitHub 未認証。gh auth login を実行してください（HTTPS での git 操作に必要）"
        gh auth login
    fi
    gh auth setup-git
fi

echo "=== Home Manager セットアップ ==="
if ! command -v home-manager &>/dev/null; then
    nix run github:nix-community/home-manager/release-25.11 -- switch --flake "$HOME/.config/home-manager#nari"
fi

echo "=== mise セットアップ ==="
if ! command -v mise &>/dev/null; then
    curl https://mise.run | sh
fi
mise install  # 既インストール済みランタイムはスキップされる

echo "=== uv セットアップ ==="
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

echo "=== Claude Code セットアップ ==="
if ! command -v claude &>/dev/null; then
    curl -fsSL https://claude.ai/install.sh | sh
fi

echo "=== TPM (tmux plugin manager) セットアップ ==="
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "=== zenhan.exe セットアップ (WSL IME制御) ==="
if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
    if ! command -v zenhan.exe &>/dev/null; then
        curl -fLO https://github.com/iuchim/zenhan/releases/download/v0.0.1/zenhan.zip
        unzip -q zenhan.zip
        sudo mv zenhan/bin64/zenhan.exe /usr/local/bin/zenhan.exe
        rm -rf zenhan zenhan.zip
    fi
fi

echo "=== nb notebooks セットアップ ==="
if command -v nb &>/dev/null; then
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        if [ ! -d "$HOME/.nb/nb-home" ]; then
            nb notebooks add git@github.com:WhiteOctpus/nb-home.git
        fi
        if [ ! -d "$HOME/.nb/nb-arunas" ]; then
            nb notebooks add git@github.com:WhiteOctpus/nb-arunas.git
        fi
    else
        echo "SSH 未設定のため nb notebooks はスキップ。SSH 鍵設定後に手動で実行してください。"
        echo "  nb notebooks add git@github.com:WhiteOctpus/nb-home.git"
        echo "  nb notebooks add git@github.com:WhiteOctpus/nb-arunas.git"
    fi
fi

echo ""
echo "=== 完了 ==="
echo "ターミナルを再起動してください"
