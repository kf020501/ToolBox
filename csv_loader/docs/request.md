# Codex CLI 指示書：CSV（JSONリテラル）ローダ実装（空セル= null 特例あり）

## 目的

CSVを読み込み、**各セルを JSON リテラルとして解釈して Python 型に変換**するローダを実装する。
ただし **CSV上で空セル（値なし / ""）となる場合は特例として `null` 扱い（Pythonでは `None`）**にする。

### 変換ルール（保証対象）

* `"111"` → `str("111")`
* `111` → `int(111)`
* `3.14` → `float(3.14)`
* `true / false` → `bool`
* `null` → `None`
* **空セル（`,,` または `""`）→ `None`（特例）**

※ JSON 配列 `[...]` やオブジェクト `{...}` は
動作してもよいが **保証対象外**（READMEでも言及しない／テストもしない）


## 入力CSV仕様（READMEに追記する文言）

* 原則：各セルは **JSON リテラル**として記載する（`json.loads()` で解釈できること）
* 例外：CSV上で空セル（値なし、または `""`）となる場合は **`null` とみなす**（Pythonでは `None`）
* 文字列は必ず **ダブルクォート**で囲む
* `true / false / null` は小文字のみ
* 禁止例：`'abc'`, `None`, `TRUE`, `FALSE`, `NaN`, `Infinity`

### 記載例

```csv
id,value,flag,comment
1,123,true,null
2,"123",false,"hello,world"
3,,true,"empty-cell-is-null"
4,"",false,"also-null"
```


## 実装要件

### 1) モジュール構成

* 例：`src/csvjson.py`
* 公開関数（最低限これ）

```python
def load_csv_json(
    path: str,
    *,
    encoding: str = "utf-8",
    dialect: str = "excel",
) -> list[dict[str, object]]:
    ...
```

* 内部で `csv.DictReader` を使い、1行目をヘッダとして扱う
* 各セルは下記 `parse_cell()` を通して変換する

### 2) セル変換ロジック（必須）

* 型推定ロジックは自前で書かない。**基本は `json.loads()` のみ**
* ただし空セル特例を入れる

擬似コード：

```python
def parse_cell(raw: str) -> object:
    # 空セル特例：CSVでは "" と 値なし(,,) はどちらも raw=="" になる
    if raw == "":
        return None

    try:
        return json.loads(raw)
    except json.JSONDecodeError as e:
        raise ValueError(f"...行/列/値...") from e
```

### 3) エラー要件

* `json.loads()` に失敗した場合は握りつぶさず例外にする
* 例外メッセージに以下を含めること：

  * 行番号（ヘッダ行を除いたデータ行の1始まり、またはファイル行番号でも良いが仕様として統一）
  * 列名
  * 元のセル文字列（raw）

### 4) CSVパース要件

* 標準 `csv` モジュール使用
* `open(..., newline="")` を守る
* セル内に `,` が含まれてもCSVが正しくクォートされていれば破綻しないこと

### 5) 依存関係

* 標準ライブラリのみ（外部パッケージ追加禁止）


## テスト要件（pytest）

* `tests/test_csvjson.py` を追加
* `io.StringIO` でCSV文字列を渡せるように、必要なら file-like 対応関数も用意して良い

  * 例：`load_csv_json_fp(fp: TextIO, ...)`

### 保証対象テスト

1. 基本型

   * `123` → `int`
   * `"123"` → `str`
   * `3.14` → `float`
   * `true/false` → `bool`
   * `null` → `None`

2. 空セル特例（重要）

   * `, ,`（値なし）→ `None`
   * `""` → `None`
     ※ `" "`（スペース入り）などは **空セルではない**ので `json.loads()` に任せる（＝ `" "` は文字列）

3. カンマ入り文字列

   * `"hello,world"` が `str` として読める

4. 不正値はエラー

   * `None`, `TRUE`, `'abc'` がエラーになる
   * エラー文に行・列・値が含まれる

※ 配列/オブジェクトのテストは不要


## 成果物

* `src/csvjson.py`
* `tests/test_csvjson.py`
* README の「CSVフォーマット仕様（JSONリテラル）」追記


## 実装方針（重要）

* 「CSVは入れ物、値の意味は JSON 仕様に委ねる」
* ただし運用性のため、**空セルのみ null 相当として扱う**
* 変換は原則 `json.loads()` に一本化し、独自推定はしない
* エラー時の原因究明（行・列・値）が最優先
