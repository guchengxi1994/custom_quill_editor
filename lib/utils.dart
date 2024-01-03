Map<String, List<String>> tableToJson(int rows, List<List<String>> data) {
  assert(rows == data.length);

  final Map<String, List<String>> result = {};
  for (int i = 0; i < rows; i++) {
    result[i.toString()] = data[i];
  }

  return result;
}

List<List<String>> jsonToTable(Map<int, List<String>> data) {
  List<List<String>> result = [];
  for (final i in data.values) {
    result.add(i);
  }
  return result;
}

Map<String, List<String>> emptyTableToJson(int rows, int columns) {
  List<List<String>> data = [];
  for (int i = 0; i < rows; i++) {
    data.add(List.filled(columns, ""));
  }
  return tableToJson(rows, data);
}
