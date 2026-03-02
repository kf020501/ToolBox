import java.nio.file.Path;
import java.util.List;
import java.util.Map;

import utils.CsvJsonLoader;

public class ExampleMain {
    public static void main(String[] args) throws Exception {
        Path path = Path.of("csv_loader_java/examples/data/basic.csv");
        CsvJsonLoader.CsvMatrix matrix = CsvJsonLoader.csvToMatrix(path);
        List<Map<String, Object>> list = CsvJsonLoader.matrixToListMap(matrix.headers(), matrix.rows());
        System.out.println(list);
    }
}
