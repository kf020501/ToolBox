#!/usr/bin/env bash
set -e

if [[ $EUID -ne 0 ]]; then
  echo "このスクリプトは root または sudo で実行してください。"
  exit 1
fi

echo "=== 古い Docker パッケージのアンインストール ==="
# 何もインストールされていなくてもエラーにしない
apt-get remove -y docker docker-engine docker.io containerd runc || true

echo
echo "=== パッケージインデックスの更新 ==="
apt-get update

echo
echo "=== 必要パッケージのインストール（ca-certificates, curl, gnupg, lsb-release, git, make）=== "
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    make

echo
# GPG 鍵の保存場所
KEYRING=/usr/share/keyrings/docker-archive-keyring.gpg

if [ ! -f "${KEYRING}" ]; then
  echo "=== Docker 公式 GPG 鍵の追加 ==="
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o "${KEYRING}"
else
  echo "（スキップ）Docker GPG 鍵は既に存在します: ${KEYRING}"
fi

echo
DOCKER_LIST=/etc/apt/sources.list.d/docker.list
REPO="deb [arch=$(dpkg --print-architecture) signed-by=${KEYRING}] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

if ! grep -Fxq "${REPO}" "${DOCKER_LIST}" 2>/dev/null; then
  echo "=== Docker リポジトリのセットアップ ==="
  printf "%s\n" "${REPO}" > "${DOCKER_LIST}"
else
  echo "（スキップ）Docker リポジトリは既に設定済み: ${DOCKER_LIST}"
fi

echo
echo "=== パッケージインデックスの再更新 ==="
apt-get update

echo
echo "=== Docker Engine 等のインストール ==="
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin

# スクリプトを sudo で実行した元のユーザーを Docker グループに追加
if [ -n "$SUDO_USER" ]; then
  usermod -aG docker "$SUDO_USER"
  echo "ユーザー '$SUDO_USER' を docker グループに追加しました。"
fi

echo
echo "=== インストール完了 ==="
docker --version
make --version
git --version

