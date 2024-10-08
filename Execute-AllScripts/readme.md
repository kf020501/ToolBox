# Execute-AllScripts

## 概要
`Execute-AllScripts.ps1` は、指定したディレクトリ内に存在するすべての PowerShell スクリプト (`.ps1` ファイル) を再帰的に実行し、それぞれの実行結果をログファイルに保存するスクリプトです。ログファイルは指定したディレクトリにタイムスタンプ付きで保存されます。

## 特徴
- 指定ディレクトリ配下のすべての `.ps1` ファイルを再帰的に実行。
- 各スクリプトの出力とエラーを個別のログファイルに記録。
- ログファイルはタイムスタンプとスクリプト名に基づいて命名。

## 使用方法

### 前提条件
- PowerShell 5.0 以降が必要です。
- スクリプト実行のための適切な実行ポリシーを設定してください (`Set-ExecutionPolicy`)。

### スクリプトの実行
スクリプトを以下のように実行します:

```powershell
.\Execute-AllScripts.ps1 -ScriptDir "C:\Path\To\Scripts" -LogDir "C:\Path\To\Logs"
```

### パラメータ
- `-ScriptDir`: スクリプトファイルが格納されているディレクトリを指定します。
- `-LogDir`: ログファイルを保存するディレクトリを指定します。

### ログファイル
各スクリプトの実行結果は、次の形式のログファイルに保存されます:

```
YYYY-MM-DD_HHmmss_ScriptName.log
```

### 使用例
例えば、`sample01.ps1` スクリプトが `2024-08-27 14:35:00` に実行された場合、生成されるログファイルの名前は次のようになります:

```
2024-08-27_143500_sample01.log
```

### グローバル変数について
スクリプトは、指定された `ScriptDir` と `LogDir` をグローバル変数として定義します (`$global:ScriptDir`, `$global:LogDir`)。これにより、子スクリプトや他の関数からもこれらの変数を参照することが可能です。
