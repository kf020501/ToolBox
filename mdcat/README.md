# mdcat

指定ディレクトリ配下の特定拡張子ファイルを再帰的に読み取り、Markdown形式で標準出力に表示します。

## 使い方

```bash
python3 mdcat.py /path/to/dir
```

引数がない場合は対話式でディレクトリを入力します。

## 設定

対象ディレクトリ直下の `settings.json` で拡張子とコードフェンスを指定できます。

例:

```json
{
  "extensions": [".py", ".txt"],
  "code_fence": "```"
}
```
