import 'package:flutter/material.dart';

import 'custom_table_item.dart';

class CustomTableWidget extends StatefulWidget {
  const CustomTableWidget({
    super.key,
    required this.rows,
    required this.columns,
  });
  final int rows;
  final int columns;

  @override
  State<CustomTableWidget> createState() => CustomTableWidgetState();
}

class CustomTableWidgetState extends State<CustomTableWidget> {
  late Map<String, List<TableItemModel>> data = {};
  late Map<int, TableColumnWidth> columnWidth = {};

  refresh(int rows, int columns) {
    for (int i = 0; i < rows; i++) {
      List<TableItemModel> models = [];
      for (int j = 0; j < columns; j++) {
        try {
          models.add(data[i.toString()]![j]);
        } catch (_) {
          models.add(TableItemModel(
            content: '',
            type: '',
            onSubmit: (model) {
              setState(() {
                data[i.toString()]![j] = model;
              });
            },
          ));
        }
      }
      data[i.toString()] = models;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.rows; i++) {
      List<TableItemModel> models = [];
      for (int j = 0; j < widget.columns; j++) {
        models.add(TableItemModel(
          content: '',
          type: '',
          onSubmit: (model) {
            setState(() {
              data[i.toString()]![j] = model;
            });
          },
        ));
      }
      data[i.toString()] = models;
    }

    for (int i = 0; i < widget.columns; i++) {
      columnWidth[i] = const FlexColumnWidth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      columnWidths: columnWidth,
      // children: [],
      children: data.values
          .map((e) =>
              TableRow(children: e.map((e1) => e1.build(context)).toList()))
          .toList(),
    );
  }
}
