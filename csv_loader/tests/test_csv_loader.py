from pathlib import Path

import pytest

from src.csv_loader import csv_to_matrix, matrix_to_list_dict


def test_basic_types():
    path = Path(__file__).resolve().parent / "csv" / "basic.csv"
    # CSV -> 2次元配列 -> List[Dict] の流れを確認する。
    headers, rows = csv_to_matrix(str(path))
    list_dict = matrix_to_list_dict(headers, rows)
    print(list_dict)
    assert rows == [
        [1, 123, True, None],
        [2, "123", False, "hello,world"],
        [3, 3.14, True, "pi"],
    ]
    assert list_dict == [
        {"id": 1, "value": 123, "flag": True, "comment": None},
        {"id": 2, "value": "123", "flag": False, "comment": "hello,world"},
        {"id": 3, "value": 3.14, "flag": True, "comment": "pi"},
    ]


def test_empty_cells_are_null():
    path = Path(__file__).resolve().parent / "csv" / "empty.csv"
    headers, rows = csv_to_matrix(str(path))
    list_dict = matrix_to_list_dict(headers, rows)
    print(list_dict)
    assert rows == [
        [1, None, True, "empty-cell-is-null"],
        [2, None, False, "also-null"],
    ]
    assert list_dict == [
        {"id": 1, "value": None, "flag": True, "comment": "empty-cell-is-null"},
        {"id": 2, "value": None, "flag": False, "comment": "also-null"},
    ]


@pytest.mark.parametrize(
    "bad_value",
    ["None", "TRUE", "'abc'"],
)
def test_invalid_values_raise(bad_value):
    filename = {
        "None": "invalid_none.csv",
        "TRUE": "invalid_TRUE.csv",
        "'abc'": "invalid_single_quote.csv",
    }[bad_value]
    path = Path(__file__).resolve().parent / "csv" / filename
    with pytest.raises(ValueError) as excinfo:
        csv_to_matrix(str(path))
    msg = str(excinfo.value)
    print(msg)
    assert "row 1" in msg
    assert "column value" in msg
    assert bad_value in msg
