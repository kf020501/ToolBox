#!/usr/bin/env bash
set -e

if [[ $EUID -ne 0 ]]; then
  echo "このスクリプトは root または sudo で実行してください。"
  exit 1
fi

# ===== 関数 =====
# パッケージがインストールされていなければAPTでインストールする
install_if_missing() {
    local pkg="$1"
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "[INFO] Installing $pkg..."
        sudo apt-get update -y
        sudo apt-get install -y "$pkg"
    else
        echo "[INFO] $pkg already installed. Skipping."
    fi
}

# systemdサービスを有効化し、起動する
enable_and_start_service() {
    local service="$1"
    # サービスが有効化されていなければ有効化
    if ! systemctl is-enabled "$service" >/dev/null 2>&1; then
        echo "[INFO] Enabling $service..."
        sudo systemctl enable "$service"
    fi
    # サービスが起動していなければ起動
    if ! systemctl is-active "$service" >/dev/null 2>&1; then
        echo "[INFO] Starting $service..."
        sudo systemctl start "$service"
    fi
}

# ===== UFW =====
install_if_missing ufw
sudo ufw --force enable
sudo ufw allow ssh
echo "[INFO] UFW status:"
sudo ufw status

# ===== SSHD =====
install_if_missing openssh-server
enable_and_start_service ssh


# ===== 日本語化パッケージ =====
# 日本語リポジトリの追加
if [ ! -f /etc/apt/sources.list.d/ubuntu-ja.sources ]; then
    echo "[INFO] Adding Japanese repository..."
    wget https://www.ubuntulinux.jp/sources.list.d/noble.sources -O /etc/apt/sources.list.d/ubuntu-ja.sources
    sudo apt-get update -y
fi

# 日本語パッケージのインストール
install_if_missing ubuntu-defaults-ja

# ===== VS Code =====
# VS Codeがインストールされていなければインストール
if ! command -v code >/dev/null 2>&1; then
    echo "[INFO] Installing VS Code..."
    # Microsoft GPGキーの追加
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    # VS Codeリポジトリの追加
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt-get update -y
    sudo apt-get install -y code
else
    echo "[INFO] VS Code already installed. Skipping."
fi

echo "[INFO] Setup completed successfully!"
