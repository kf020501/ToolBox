# セットアップスクリプト

このリポジトリには開発環境のセットアップスクリプトが含まれています。

## ファイル

- `setup-ubuntu24.04.sh` - Ubuntu 24.04用のDockerとGit環境セットアップスクリプト
- `setup-windows10-swl2.ps1` - Windows 10/11でWSL2 + Ubuntu 24.04を自動セットアップするPowerShellスクリプト

## 使用方法

### Ubuntu 24.04

```bash
sudo ./setup-ubuntu24.04.sh
```

Docker、Git、Makeがインストールされ、現在のユーザーがdockerグループに追加されます。

### Windows 10/11

管理者権限でPowerShellを開き：

```powershell
.\setup-windows10-swl2.ps1
```

WSL2機能を有効化し、Ubuntu 24.04ディストリビューションをインストールします。初回実行時は再起動が必要です。