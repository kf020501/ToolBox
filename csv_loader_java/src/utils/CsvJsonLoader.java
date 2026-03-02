package utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.Reader;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * CSVの各セルをJSONリテラルとして解釈し、Java型に変換するユーティリティ。
 * <p>
 * ルール:
 * 値なしセル(,,)はnull、""は空文字、true/false/nullは小文字のみ。
 * </p>
 */
public final class CsvJsonLoader {
    private CsvJsonLoader() {}

    /**
     * UTF-8でCSVを読み込み、ヘッダと行データを返す。
     * @param path CSVファイルのパス
     * @return CsvMatrix(ヘッダと行データ)
     * @throws IOException 読み込み失敗時
     */
    public static CsvMatrix csvToMatrix(Path path) throws IOException {
        return csvToMatrix(path, StandardCharsets.UTF_8);
    }

    /**
     * 指定エンコーディングでCSVを読み込み、ヘッダと行データを返す。
     * @param path CSVファイルのパス
     * @param encoding 文字エンコーディング
     * @return CsvMatrix(ヘッダと行データ)
     * @throws IOException 読み込み失敗時
     */
    public static CsvMatrix csvToMatrix(Path path, Charset encoding) throws IOException {
        // ファイルを指定エンコーディングで開き、CSVを読み込んで行列に変換する。
        try (BufferedReader reader = Files.newBufferedReader(path, encoding)) {
            return loadCsvMatrix(reader);
        }
    }

    /**
     * ReaderからCSVを読み込み、ヘッダと行データを返す。
     * @param reader CSVを読み込むReader
     * @return CsvMatrix(ヘッダと行データ)
     * @throws IOException 読み込み失敗時
     */
    public static CsvMatrix loadCsvMatrix(Reader reader) throws IOException {
        // Reader から全行を読み取り、1行目をヘッダ、以降をデータ行として扱う。
        BufferedReader br = reader instanceof BufferedReader ? (BufferedReader) reader : new BufferedReader(reader);
        List<String> lines = new ArrayList<>();
        for (String line = br.readLine(); line != null; line = br.readLine()) {
            lines.add(line);
        }
        if (lines.isEmpty()) {
            return new CsvMatrix(List.of(), List.of());
        }

        // ヘッダは必ずダブルクォートで囲まれた文字列とする。
        List<String> rawHeaders = parseCsvLine(lines.get(0));
        List<String> headers = new ArrayList<>(rawHeaders.size());
        for (String raw : rawHeaders) {
            if (!(raw.startsWith("\"") && raw.endsWith("\"") && raw.length() >= 2)) {
                throw new IllegalArgumentException("header must be double-quoted: " + raw);
            }
            Object parsed = parseCell(raw);
            if (!(parsed instanceof String)) {
                throw new IllegalArgumentException("header must be string literal: " + raw);
            }
            headers.add((String) parsed);
        }

        List<List<Object>> rows = new ArrayList<>();
        for (int i = 1; i < lines.size(); i++) {
            int rowNum = i; // header行を除いた1始まり
            List<String> row = parseCsvLine(lines.get(i));
            List<Object> parsedRow = new ArrayList<>(headers.size());
            for (int colIdx = 0; colIdx < headers.size(); colIdx++) {
                String colName = headers.get(colIdx);
                // 行の列数が不足している場合は空セル扱いにする。
                String raw = colIdx < row.size() ? row.get(colIdx) : "";
                try {
                    parsedRow.add(parseCell(raw));
                } catch (IllegalArgumentException e) {
                    // 行番号・列名・値を含む例外に統一する。
                    throw new CsvJsonParseException(rowNum, colName, raw, e);
                }
            }
            rows.add(parsedRow);
        }

        return new CsvMatrix(headers, rows);
    }

    public static List<Map<String, Object>> matrixToListMap(List<String> headers, List<List<Object>> rows) {
        // ヘッダと行を対応付け、List<Map> に変換する。
        List<Map<String, Object>> list = new ArrayList<>();
        for (List<Object> row : rows) {
            // 行が短い場合は不足分を null で埋める。
            List<Object> padded = new ArrayList<>(row);
            while (padded.size() < headers.size()) {
                padded.add(null);
            }
            Map<String, Object> map = new HashMap<>();
            for (int i = 0; i < headers.size(); i++) {
                map.put(headers.get(i), padded.get(i));
            }
            list.add(map);
        }
        return list;
    }

    private static List<String> parseCsvLine(String line) {
        // 最小限のCSVパーサ。ダブルクォート内のカンマは区切りとして扱わない。
        // ダブルクォートの二重化エスケープは非対応。
        if (line.isEmpty()) {
            return List.of("");
        }
        List<String> cells = new ArrayList<>();
        int i = 0;
        int n = line.length();
        while (i < n) {
            if (line.charAt(i) == '"') {
                // クォートセルは外側の " を保持する。
                int end = line.indexOf('"', i + 1);
                if (end == -1) {
                    cells.add(line.substring(i));
                    break;
                }
                cells.add(line.substring(i, end + 1));
                i = end + 1;
            } else {
                // 非クォートセルは次のカンマまでを1セルとする。
                int end = line.indexOf(',', i);
                if (end == -1) {
                    cells.add(line.substring(i));
                    break;
                }
                cells.add(line.substring(i, end));
                i = end;
            }

            if (i < n && line.charAt(i) == ',') {
                i += 1;
                if (i == n) {
                    // 行末カンマは空セルとして扱う。
                    cells.add("");
                    break;
                }
            }
        }
        return cells;
    }

    private static Object parseCell(String raw) {
        // 空セルは null。
        if (raw.equals("")) {
            return null;
        }
        // ダブルクォートで囲まれた値は文字列として扱う。
        if (raw.startsWith("\"") && raw.endsWith("\"") && raw.length() >= 2) {
            return raw.substring(1, raw.length() - 1);
        }
        // true / false / null は JSON リテラルとして扱う。
        if (raw.equals("true")) {
            return Boolean.TRUE;
        }
        if (raw.equals("false")) {
            return Boolean.FALSE;
        }
        if (raw.equals("null")) {
            return null;
        }

        try {
            // 小数点や指数表記があれば double として解釈する。
            if (raw.contains(".") || raw.contains("e") || raw.contains("E")) {
                return Double.parseDouble(raw);
            }
            // それ以外は整数として解釈し、範囲で int / long に振り分ける。
            long value = Long.parseLong(raw);
            if (value >= Integer.MIN_VALUE && value <= Integer.MAX_VALUE) {
                return (int) value;
            }
            return value;
        } catch (NumberFormatException e) {
            // どのリテラルにも当てはまらない場合はエラー。
            throw new IllegalArgumentException("invalid JSON literal: " + raw, e);
        }
    }

    /**
     * ヘッダと行データを保持するコンテナ。
     */
    public static final class CsvMatrix {
        private final List<String> headers;
        private final List<List<Object>> rows;

        /**
         * @param headers ヘッダ配列
         * @param rows 行データ
         */
        public CsvMatrix(List<String> headers, List<List<Object>> rows) {
            this.headers = headers;
            this.rows = rows;
        }

        /**
         * @return ヘッダ配列
         */
        public List<String> headers() {
            return headers;
        }

        /**
         * @return 行データ
         */
        public List<List<Object>> rows() {
            return rows;
        }
    }

    /**
     * JSONリテラルとして解釈できないセルがあった場合の例外。
     */
    public static final class CsvJsonParseException extends IllegalArgumentException {
        /**
         * @param row データ行の行番号(ヘッダ除外、1始まり)
         * @param column 列名
         * @param raw 元のセル文字列
         * @param cause 元例外
         */
        public CsvJsonParseException(int row, String column, String raw, Throwable cause) {
            super("invalid JSON literal at row " + row + ", column " + column + ": " + raw, cause);
        }
    }
}
