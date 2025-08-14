# セットアップスクリプト

このリポジトリには開発環境のセットアップスクリプトが含まれています。

## ファイル

- `setup-ubuntu24.04.sh` - Ubuntu 24.04用のDockerとGit環境セットアップスクリプト
- `setup-windows10-swl2.ps1` - Windows 10/11でWSL2 + Ubuntu 24.04を自動セットアップするPowerShellスクリプト

## 使用方法

### Ubuntu 24.04

```bash
# ufwとsshdが必要な場合
curl -fsSL https://raw.github.com/kf020501/ToolBox/main/setup-ubuntu24.04/setup-ubuntu24.04-desktop.sh | sudp bash

curl -fsSL https://raw.github.com/kf020501/ToolBox/main/setup-ubuntu24.04/setup-ubuntu24.04.sh | sudp bash
```

Docker、Git、Makeがインストールされ、現在のユーザーがdockerグループに追加されます。

### Windows 10/11

管理者権限でPowerShellを開き：

```powershell
.\setup-windows10-swl2.ps1
```

WSL2機能を有効化し、Ubuntu 24.04ディストリビューションをインストールします。初回実行時は再起動が必要です。

## 課題

WSL2環境で下記エラーが発生。
```text
docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

こちらのページ記載の対応をしたところ解決した。  
[[対処法 WSL2] Docker エラー：Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running #Ubuntu - Qiita](https://qiita.com/Yuto-24/items/b52efb6da9e9f5905a51)

> sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
> sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
> sudo service docker restart
