import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

const XTypeGroup typeGroup = XTypeGroup(
  label: 'images',
  extensions: <String>['jpg', 'png'],
);

typedef OnSubmit = void Function(TableItemModel model);

class TableItemModel {
  String content;
  String type;
  OnSubmit? onSubmit;

  TableItemModel({required this.content, required this.type, this.onSubmit});

  Map<String, String> toJson() {
    Map<String, String> result = {};
    result["content"] = content;
    result["type"] = type;
    return result;
  }

  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: type == "image"
                ? Image(image: FileImage(File(content)))
                : Text(content)),
        Column(
          children: [
            IconButton(
                onPressed: () async {
                  final XFile? file = await openFile(
                      acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                  if (file != null) {
                    content = file.path;
                    type = "image";

                    if (onSubmit != null) {
                      onSubmit!(this);
                    }
                  }
                },
                icon: const Icon(Icons.insert_photo)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.input))
          ],
        )
      ],
    );
  }
}
