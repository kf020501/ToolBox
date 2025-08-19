# WindowsFileManager

## 概要
このディレクトリには、Windowsファイル管理用のツールが含まれています。

## ツール一覧

### compress_folders_to_zip.py
指定されたフォルダをzip形式で圧縮します。フォルダごとに圧縮され、圧縮されたzipファイルは元のフォルダと同じ場所に保存されます。

### backup_file.py
ファイルのバックアップを作成します。ファイルを同じディレクトリ内の`bk`フォルダに日付付きでバックアップコピーを作成します。

## 必要環境
- Python 3.x
- 標準ライブラリのみ使用（外部ライブラリ不要）

## 使い方

### compress_folders_to_zip.py（フォルダ圧縮）

**ドラッグ&ドロップ方式:**
1. `compress_folders_to_zip.bat`にフォルダをドラッグ&ドロップ
2. 各フォルダがzip形式で圧縮されます

**コマンドライン方式:**
```bash
python compress_folders_to_zip.py <フォルダパス1> <フォルダパス2> ...
```

### backup_file.py（ファイルバックアップ）

**ドラッグ&ドロップ方式:**
1. `backup_file.bat`にファイルをドラッグ&ドロップ
2. 各ファイルが同じディレクトリの`bk`フォルダ内に`ファイル名.20250819_143052bk.拡張子`形式でバックアップされます

**コマンドライン方式:**
```bash
python backup_file.py <ファイルパス1> <ファイルパス2> ...
```

### 使用例

**フォルダ圧縮の例:**
```bash
python compress_folders_to_zip.py a b c
```
実行後、以下のようにそれぞれのフォルダが圧縮されます：
- `a.zip`
- `b.zip`
- `c.zip`

**ファイルバックアップの例:**
```bash
python backup_file.py document.txt config.json
```
実行後、以下のようにバックアップファイルが作成されます：
- `bk/document.20250819_143052bk.txt`
- `bk/config.20250819_143052bk.json`

### 注意点

1. **フォルダが存在することを確認してください**
   - 指定したフォルダが存在しない場合、エラーメッセージが表示されます。

2. **スペースを含むフォルダ名**
   - フォルダパスにスペースが含まれる場合は、ダブルクォート `"` で囲む必要があります。

例:
```bash
python compress_folders_to_zip.py "folder with space"
```

3. **実行場所**
   - スクリプトはどのディレクトリからでも実行可能ですが、出力先は指定したフォルダと同じディレクトリになります。
