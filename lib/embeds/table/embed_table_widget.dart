import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

import 'custom_table_widget.dart';

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
                  children: (e as List).map((e1) {
                // final ej = jsonDecode(e1);
                if (e1['type'] == "image") {
                  return Image.file(File(e1['content']));
                }
                return Text(e1['content'].toString());
              }).toList()))
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

  final GlobalKey<CustomTableWidgetState> globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width * .95,
        height: MediaQuery.of(context).size.height * .95,
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
                    onChanged: (value) {
                      if (value != "" && value != "0") {
                        globalKey.currentState!.refresh(
                            int.parse(rowController.text),
                            int.parse(columnController.text));
                      }
                    },
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
                    onChanged: (value) {
                      if (value != "" && value != "0") {
                        globalKey.currentState!.refresh(
                            int.parse(rowController.text),
                            int.parse(columnController.text));
                      }
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                  ),
                )
              ],
            ),
            Expanded(
                child: CustomTableWidget(
              key: globalKey,
              rows: int.parse(rowController.text),
              columns: int.parse(columnController.text),
            )),
            Row(
              children: [
                const Spacer(),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(jsonEncode(null));
                    },
                    child: const Text("取消")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(jsonEncode(globalKey.currentState!.data));
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
