# YouTube 視聴制限ツール

## 機能概要

Windows の hosts ファイルを自動制御し、**普段は YouTube をブロックしつつ、必要なときだけ 30 分間だけ視聴可能にする仕組み**です。

PowerShell スクリプトとタスクスケジューラを組み合わせることで、
**コンソールを閉じても 30 分後に自動で再ブロックされる**ようになっています。

## 主な機能

* ホストファイルを編集して YouTube ドメインをブロック
* 一時解除スクリプト実行で 30 分間だけ視聴可能にする
* 30 分後に自動で再ブロックするタスクをタスクスケジューラへ登録
* タスクは 1 回限りの実行で自動的に消える（※同名タスクは都度削除）
* スクリプトはすべて管理者権限が必須

## ファイル構成

```
YouTubeControl/
├── Block-YouTube.ps1
└── Allow-YouTube.ps1
```

---

## アーキテクチャ概要

```mermaid
sequenceDiagram
    autonumber

    participant User as ユーザー
    participant AllowScript as Allow-YouTube.ps1
    participant BlockScript as Block-YouTube.ps1
    participant Hosts as hostsファイル
    participant Scheduler as タスクスケジューラ

    User ->> AllowScript: 実行（管理者権限）
    AllowScript ->> Hosts: ブロックセクション削除（視聴可能に）
    AllowScript ->> Scheduler: 30分後に Block-YouTube.ps1 を実行するタスクを登録
    Scheduler ->> User: コンソールを閉じても動作継続
    Scheduler ->> BlockScript: 30 分後に実行
    BlockScript ->> Hosts: ブロックセクション追加
    BlockScript ->> User: YouTube を再ブロック（視聴不可）
```
