import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class TableBlockEmbed extends CustomBlockEmbed {
  TableBlockEmbed(super.type, super.data);

  static const String tableType = "table";

  static TableBlockEmbed fromDocument(Document document) {
    return TableBlockEmbed("table", jsonEncode(document.toDelta().toJson()));
  }

  Document get document => Document.fromJson(jsonDecode(data));
}

class TableEmbedBuilder extends EmbedBuilder {
  Widget _jsonToTableWidget(Map<String, dynamic> data) {
    int columns = data.values.firstOrNull?.length ?? 0;

    Map<int, TableColumnWidth> columnWidth = {};
    for (int i = 0; i < columns; i++) {
      columnWidth[i] = const FlexColumnWidth();
    }
    return Table(
      border: TableBorder.all(),
      columnWidths: columnWidth,
      // children: [],
      children: data.values
          .map((e) => TableRow(
              children: (e as List).map((e1) => Text(e1.toString())).toList()))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context, QuillController controller, Embed node,
      bool readOnly, bool inline, TextStyle textStyle) {
    final table = TableBlockEmbed("table", node.value.data).document;

    return Material(
      child: _jsonToTableWidget(jsonDecode(table.toPlainText())),
    );
  }

  @override
  String get key => "table";
}

class InsertTableDialog extends StatelessWidget {
  InsertTableDialog({super.key});

  final TextEditingController rowController = TextEditingController()
    ..text = "2";
  final TextEditingController columnController = TextEditingController()
    ..text = "2";

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.inversePrimary,
            blurRadius: 10,
            spreadRadius: 2.5,
          ),
          const BoxShadow(
            color: Color(0xFFE8E8E8),
            blurRadius: 10,
            spreadRadius: 2.5,
          )
        ], color: Colors.white, borderRadius: BorderRadius.circular(4)),
        child: Column(
          children: [
            Row(
              children: [
                const Text("行"),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: rowController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                  ),
                ),
                const Text("列"),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: columnController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: [
                const Spacer(),
                TextButton(
                    onPressed: () {
                      int rows = int.parse(rowController.text);
                      int columns = int.parse(columnController.text);
                      Navigator.of(context).pop((rows, columns));
                    },
                    child: const Text("确定"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
