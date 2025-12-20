# CSVフォーマット仕様（JSONリテラル）

CSVの各セルは JSON リテラルとして記載します（`json.loads()` で解釈できること）。
例外として、CSV上で空セル（値なし、または `""`）となる場合は `null` とみなします（Pythonでは `None`）。

## ルール

- 文字列は必ずダブルクォートで囲む
- `true / false / null` は小文字のみ
- 禁止例：`'abc'`, `None`, `TRUE`, `FALSE`, `NaN`, `Infinity`

## 記載例

```csv
id,value,flag,comment
1,123,true,null
2,"123",false,"hello,world"
3,,true,"empty-cell-is-null"
4,"",false,"also-null"
```

## メソッド呼び出し関係（CSV → 2次元配列 → List[Dict]）

```mermaid
sequenceDiagram
    participant User as User
    participant Matrix as load_csv_matrix <br/>CSV -> (headers, rows)
    participant ToDict as matrix_to_list_dict <br/>(headers, rows) -> List[Dict]
    participant FP as _load_csv_matrix_text_io <br/>text_io -> (headers, rows)
    participant Parser as _parse_csv_line <br/>CSV 行 -> セル配列
    participant Cell as _parse_cell <br/>セル -> Python 型

    User->>Matrix: load_csv_matrix(path) <br/>CSV を 2次元配列に変換
    Matrix->>FP: open(path, newline="", encoding) <br/>csv 用に newline="" を指定
    Matrix-->>FP: text_io <br/>テキストI/Oを受け取る
    Matrix->>FP: _load_csv_matrix_text_io(text_io) <br/>text_io から読み込み
    loop each line
        FP->>Parser: _parse_csv_line(line) <br/>CSV 行をセル配列に分解
        Parser-->>FP: cells <br/>分解済みセル配列
        FP->>Cell: _parse_cell(raw) <br/>セルの型変換
        Cell-->>FP: Python 型の値 <br/>変換済みセルを返す
    end
    FP-->>Matrix: headers, rows <br/>ヘッダ配列と 2次元配列を返す
    Matrix-->>User: headers, rows <br/>戻り値を受け取る
    User->>ToDict: matrix_to_list_dict(headers, rows) <br/>List[Dict] に変換
    ToDict-->>User: list[dict[str, object]] <br/>最終結果を返す
```
