import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TableBlockEmbed extends CustomBlockEmbed {
  TableBlockEmbed(super.type, super.data);

  static const String tableType = "table";

  static TableBlockEmbed fromDocument(Document document) {
    return TableBlockEmbed("table", jsonEncode(document.toDelta().toJson()));
  }

  Document get document => Document.fromJson(jsonDecode(data));
}

class TableEmbedBuilder extends EmbedBuilder {
  @override
  Widget build(BuildContext context, QuillController controller, Embed node,
      bool readOnly, bool inline, TextStyle textStyle) {
    // final table = TableBlockEmbed("table", node.value.data).document;

    print(jsonDecode(node.value.data));

    return Material(
      child: Table(
        border: TableBorder.all(),
        columnWidths: const {
          1: FlexColumnWidth(),
          2: FlexColumnWidth(),
        },
        children: const [
          TableRow(children: [Text("1"), Text("2")]),
          TableRow(children: [Text("3"), Text("4")])
        ],
      ),
    );
  }

  @override
  String get key => "table";
}
