#!/usr/bin/env bash
set -e

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

echo "[INFO] Setup completed successfully!"
