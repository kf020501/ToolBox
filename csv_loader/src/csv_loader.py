import json
from typing import TextIO

def _parse_csv_line(line: str) -> list[str]:
    """
    CSV の1行をセル配列に分割する。
    Args:
        line: CSV の1行
    Returns:
        セル文字列の配列（クォートは保持）
    """
    # 行末の改行を取り除く。
    line = line.rstrip("\r\n")
    # 空行は空セル1つとして扱う。
    if line == "":
        return [""]

    cells: list[str] = []
    i = 0
    n = len(line)
    while i < n:
        # 先頭が " の場合はクォートセルとして扱う（エスケープは非対応）。
        if line[i] == '"':
            # クォートセルは外側の " を保持する。
            end = line.find('"', i + 1)
            if end == -1:
                # 閉じクォートが無い場合は残り全体をセルとして扱う。
                cells.append(line[i:])
                break
            # 開始〜終了の " を含めたセルを追加する。
            cells.append(line[i : end + 1])
            i = end + 1
        else:
            # 非クォートセルは次のカンマまでをセルとする。
            end = line.find(",", i)
            if end == -1:
                # カンマが無い場合は行末までをセルとする。
                cells.append(line[i:])
                break
            cells.append(line[i:end])
            i = end

        # セル区切りのカンマを消費する。
        if i < n and line[i] == ",":
            i += 1
            if i == n:
                # 行末カンマは空セルとして扱う。
                cells.append("")
                break

    return cells


def _parse_cell(raw: str) -> object:
    """
    セルの文字列を JSON リテラルとして解釈し、Python 型に変換する。
    Args:
        raw: セルの生文字列（クォートは保持）
    Returns:
        JSON 解釈後の Python 型の値
    """
    # 空セル特例: , , または "" は None として扱う。
    if raw == "" or raw == '""':
        return None

    if raw.startswith('"') and raw.endswith('"') and len(raw) >= 2:
        inner = raw[1:-1]
        return inner

    try:
        # 型推定は自前で行わず、json.loads() に委ねる。
        return json.loads(raw)
    except json.JSONDecodeError as e:
        raise ValueError(f"invalid JSON literal: {raw}") from e


def _load_csv_matrix_text_io(
    text_io: TextIO,
) -> tuple[list[str], list[list[object]]]:
    """
    text_io から CSV を読み込み、ヘッダ配列と2次元配列に変換する。
    Args:
        text_io: CSV を読み込むI/Oオブジェクト
    Returns:
        ヘッダ配列とデータ行の2次元配列
    """
    # 行単位に分割 0行ならヘッダもデータも空
    lines = text_io.read().splitlines()
    if not lines:
        return [], []

    # ヘッダの作成
    raw_headers = _parse_csv_line(lines[0])
    headers: list[str] = []
    for raw in raw_headers:
        if not (raw.startswith('"') and raw.endswith('"') and len(raw) >= 2):
            raise ValueError(f"header must be double-quoted: {raw}")
        parsed = _parse_cell(raw)
        if not isinstance(parsed, str):
            raise ValueError(f"header must be string literal: {raw}")
        headers.append(parsed)

    # データ行の作成
    rows: list[list[object]] = []
    for row_num, line in enumerate(lines[1:], start=1):
        # 1行分のデータを変換する。(ヘッダ数を超える列は無視)
        row = _parse_csv_line(line)
        parsed_row: list[object] = []
        for col_idx, col_name in enumerate(headers):
            # 行の列数がヘッダより少ないときに、欠けているセルを空セルとして扱う
            raw = row[col_idx] if col_idx < len(row) else ""
            try:
                parsed_row.append(_parse_cell(raw))
            except ValueError as e:
                raise ValueError(
                    f"invalid JSON literal at row {row_num}, column {col_name}: {raw}"
                ) from e
        rows.append(parsed_row)
    return headers, rows


def csv_to_matrix(
    path: str,
    *,
    encoding: str = "utf-8"
) -> tuple[list[str], list[list[object]]]:
    """
    CSV ファイルを読み込み、ヘッダ配列と2次元配列に変換する。
    Args:
        path: CSV ファイルパス
        encoding: ファイルの文字エンコーディング(任意、デフォルトは "utf-8")
        dialect: csv モジュールの方言(任意、デフォルトは "excel")
    Returns:
        ヘッダ配列とデータ行の2次元配列
    """
    # csvを読み込む。
    with open(path, newline="", encoding=encoding) as text_io:
        headers, rows = _load_csv_matrix_text_io(text_io)
        return headers, rows

def matrix_to_list_dict(
    headers: list[str],
    rows: list[list[object]],
) -> list[dict[str, object]]:
    """
    ヘッダ配列と2次元配列から List[Dict] を生成する。
    Args:
        headers: ヘッダ配列
        rows: データ行の2次元配列
    Returns:
        ヘッダに対応づけた List[Dict]
    """
    list_dict: list[dict[str, object]] = []
    for row in rows:
        # 行が短い場合は欠損列を None にする。
        padded = row + [None] * max(0, len(headers) - len(row))
        list_dict.append(dict(zip(headers, padded)))
    return list_dict
