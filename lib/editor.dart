// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:custom_quill_editor/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

import 'shortcut_delegate.dart';
import 'embed_table_widget.dart';

typedef OnQuillSave = void Function(String, String, String);
typedef OnQuillPreviewImageSave = void Function(Uint8List);
typedef OnSelectImage = Future<void> Function();

class Editor extends StatefulWidget {
  const Editor(
      {super.key,
      this.saveToJson,
      this.savedData = "",
      this.savePreview,
      this.onSelectImage,
      this.shortcutDelegate = const ShortcutDelegate()});
  final OnQuillSave? saveToJson;
  final String savedData;
  final OnQuillPreviewImageSave? savePreview;
  final ShortcutDelegate shortcutDelegate;
  final OnSelectImage? onSelectImage;

  @override
  State<Editor> createState() => EditorState();
}

class EditorState extends State<Editor> {
  final FocusNode _focusNode = FocusNode();

  late final QuillController _controller;

  bool isDialogShow = false;

  @override
  void dispose() {
    _controller.dispose();
    quillScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Document doc;
    try {
      doc = Document.fromJson(jsonDecode(widget.savedData));
    } catch (_) {
      doc = Document()..insert(0, '');
    }

    _controller = QuillController(
      onSelectionChanged: (textSelection) async {
        try {
          if (_controller.document
                  .queryChild(_controller.index)
                  .node
                  ?.toPlainText()
                  .replaceAll("\n", "") ==
              widget.shortcutDelegate.insertImage) {
            final index = _controller.index;
            final length = _controller.length;
            await Future.delayed(const Duration(milliseconds: 1500))
                .then((value) async {
              final index0 = _controller.index;
              final length0 = _controller.length;
              if (index == index0 && length0 == length && !isDialogShow) {
                isDialogShow = true;
                if (widget.onSelectImage != null) {
                  await widget.onSelectImage!();
                }
                isDialogShow = false;
                // // SmartDialog.showToast("OK");
              }
            });
          } else if (_controller.document
                  .queryChild(_controller.index)
                  .node
                  ?.toPlainText()
                  .replaceAll("\n", "") ==
              widget.shortcutDelegate.insertEmoji) {
            final index = _controller.index;
            final length = _controller.length;
            await Future.delayed(const Duration(milliseconds: 1500))
                .then((value) {
              final index0 = _controller.index;
              final length0 = _controller.length;
              if (index == index0 && length0 == length && !isDialogShow) {}
            });
          } else if (_controller.document
                  .queryChild(_controller.index)
                  .node
                  ?.toPlainText()
                  .replaceAll("\n", "") ==
              widget.shortcutDelegate.insertTable) {
            final index = _controller.index;
            final length = _controller.length;
            await Future.delayed(const Duration(milliseconds: 1500))
                .then((value) async {
              final index0 = _controller.index;
              final length0 = _controller.length;
              if (index == index0 && length0 == length && !isDialogShow) {
                isDialogShow = true;
                final (int, int)? r = await showGeneralDialog(
                    context: context,
                    pageBuilder: (c, _, __) {
                      return Center(
                        child: InsertTableDialog(),
                      );
                    });

                isDialogShow = false;

                insertTable(rows: r!.$1, columns: r.$2);
                // if (widget.onInsertTable != null) {
                //   widget.onInsertTable!();
                // }
              }
            });
          }
        } catch (_) {}
      },
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildEditor(context);
  }

  final ScrollController quillScrollController = ScrollController();

  QuillEditor get quillEditor {
    return QuillEditor(
      configurations: QuillEditorConfigurations(
        builder: (context, rawEditor) {
          return rawEditor;
        },
        placeholder: "",
        readOnly: false,
        autoFocus: false,
        enableSelectionToolbar: isMobile(supportWeb: false),
        expands: false,
        padding: EdgeInsets.zero,
        onImagePaste: _onImagePaste,
        // onTapUp: (details, p1) {
        //   return _onTripleClickSelection();
        // },
        customStyles: const DefaultStyles(
          h1: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 32,
              height: 1.15,
              fontWeight: FontWeight.w300,
            ),
            VerticalSpacing(16, 0),
            VerticalSpacing(0, 0),
            null,
          ),
          sizeSmall: TextStyle(fontSize: 9),
          subscript: TextStyle(
            fontFamily: 'SF-UI-Display',
            fontFeatures: [FontFeature.subscripts()],
          ),
          superscript: TextStyle(
            fontFamily: 'SF-UI-Display',
            fontFeatures: [FontFeature.superscripts()],
          ),
        ),
        embedBuilders: [
          TableEmbedBuilder(),
          ...FlutterQuillEmbeds.editorBuilders(
            imageEmbedConfigurations:
                const QuillEditorImageEmbedConfigurations(),
          ),
          // TimeStampEmbedBuilderWidget()
        ],
        controller: _controller,
      ),
      scrollController: quillScrollController,
      focusNode: _focusNode,
    );
  }

  insertImage(String p) {
    _controller.replaceText(
        _controller.index - widget.shortcutDelegate.imageShortCutLength,
        widget.shortcutDelegate.imageShortCutLength,
        "",
        TextSelection(
            baseOffset:
                _controller.index - widget.shortcutDelegate.imageShortCutLength,
            extentOffset: _controller.index -
                widget.shortcutDelegate.imageShortCutLength));

    // print(d.toString());
    _controller.insertImageBlock(imageSource: p);
    _controller.moveCursorToPosition(_controller.index + p.length);
  }

  insertTable({int rows = 2, int columns = 2}) {
    try {
      final m = emptyTableToJson(rows, columns);
      // print(m);

      final block = BlockEmbed.custom(
        TableBlockEmbed.fromDocument(Document()..insert(0, jsonEncode(m))),
      );

      _controller.replaceText(
          _controller.index - widget.shortcutDelegate.tableShortCutLength,
          widget.shortcutDelegate.tableShortCutLength,
          block,
          TextSelection(
              baseOffset: _controller.index -
                  widget.shortcutDelegate.tableShortCutLength,
              extentOffset: _controller.index -
                  widget.shortcutDelegate.tableShortCutLength));

      _controller.moveCursorToPosition(
          _controller.index + block.data.toString().length);
    } catch (e, s) {
      if (kDebugMode) {
        print(s);
      }
    }
  }

  /// When inserting an image
  OnImageInsertCallback get onImageInsert {
    return (image, controller) async {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      final newImage = croppedFile?.path;
      if (newImage == null) {
        return;
      }
      controller.insertImageBlock(imageSource: newImage);
    };
  }

  Widget get quillToolbar {
    final customButtons = [
      QuillToolbarCustomButtonOptions(
        tooltip: "Save as json",
        icon: const Icon(Icons.save),
        onPressed: () {
          if (widget.saveToJson != null) {
            final j = jsonEncode(_controller.document.toDelta().toJson());
            final t = _controller.document.toPlainText();
            // ignore: no_leading_underscores_for_local_identifiers
            String _abstract;
            if (t.length > 20) {
              _abstract = t.substring(0, 20);
            } else {
              _abstract = t;
            }
            _abstract = "${_abstract.replaceAll("\n", "")} ...";
            widget.saveToJson!(j, t, _abstract);
          }
          Navigator.of(context).pop();
        },
      ),
      QuillToolbarCustomButtonOptions(
        tooltip: "Save preview",
        icon: const Icon(Icons.save_as),
        onPressed: () async {
          if (widget.savePreview != null) {
            try {
              RenderRepaintBoundary repaintBoundary = _shotKey.currentContext!
                  .findRenderObject() as RenderRepaintBoundary;
              var resultImage = await repaintBoundary.toImage();
              ByteData? byteData =
                  await resultImage.toByteData(format: ImageByteFormat.png);
              if (byteData != null) {
                Uint8List pngBytes = byteData.buffer.asUint8List();
                widget.savePreview!(pngBytes);
              }
            } catch (_) {}
          }
        },
      ),
      QuillToolbarCustomButtonOptions(
        tooltip: "Exit",
        icon: const Icon(Icons.exit_to_app),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ];
    return QuillToolbar.simple(
      configurations: QuillSimpleToolbarConfigurations(
        customButtons: customButtons,
        embedButtons: FlutterQuillEmbeds.toolbarButtons(
          cameraButtonOptions: const QuillToolbarCameraButtonOptions(),
          imageButtonOptions: QuillToolbarImageButtonOptions(
            imageButtonConfigurations: QuillToolbarImageConfigurations(
              onImageInsertedCallback: (image) async {
                _onImagePickCallback(File(image));
              },
            ),
          ),
        ),
        showAlignmentButtons: true,
        buttonOptions: QuillSimpleToolbarButtonOptions(
          base: QuillToolbarBaseButtonOptions(
            afterButtonPressed: _focusNode.requestFocus,
          ),
        ),
        controller: _controller,
      ),
    );
  }

  final GlobalKey _shotKey = GlobalKey();

  Widget _buildEditor(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 15,
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: RepaintBoundary(
                key: _shotKey,
                child: quillEditor,
              ),
            ),
          ),
          Container(
            child: quillToolbar,
          )
        ],
      ),
    );
  }

  // Future<String?> _openFileSystemPickerForDesktop(BuildContext context)
  // async {
  //   return await FilesystemPicker.open(
  //     context: context,
  //     rootDirectory: await getApplicationDocumentsDirectory(),
  //     fsType: FilesystemType.file,
  //     fileTileSelectMode: FileTileSelectMode.wholeTile,
  //   );
  // }

  // Renders the image picked by imagePicker from local file storage
  // You can also upload the picked image to any server (eg : AWS s3
  // or Firebase) and then return the uploaded image URL.
  Future<String> _onImagePickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final copiedFile =
        await file.copy('${appDocDir.path}/${path.basename(file.path)}');
    return copiedFile.path.toString();
  }

  // Future<String?> _webImagePickImpl(
  //     OnImagePickCallback onImagePickCallback) async {
  //   final result = await FilePicker.platform.pickFiles();
  //   if (result == null) {
  //     return null;
  //   }

  //   // Take first, because we don't allow picking multiple files.
  //   final fileName = result.files.first.name;
  //   final file = File(fileName);

  //   return onImagePickCallback(file);
  // }

  // Renders the video picked by imagePicker from local file storage
  // You can also upload the picked video to any server (eg : AWS s3
  // or Firebase) and then return the uploaded video URL.
  Future<String> _onVideoPickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final copiedFile =
        await file.copy('${appDocDir.path}/${path.basename(file.path)}');
    return copiedFile.path.toString();
  }

  // // ignore: unused_element
  // Future<MediaPickSetting?> _selectMediaPickSetting(BuildContext context) =>
  //     showDialog<MediaPickSetting>(
  //       context: context,
  //       builder: (ctx) => AlertDialog(
  //         contentPadding: EdgeInsets.zero,
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextButton.icon(
  //               icon: const Icon(Icons.collections),
  //               label: const Text('Gallery'),
  //               onPressed: () => Navigator.pop(ctx,
  // MediaPickSetting.gallery),
  //             ),
  //             TextButton.icon(
  //               icon: const Icon(Icons.link),
  //               label: const Text('Link'),
  //               onPressed: () => Navigator.pop(ctx, MediaPickSetting.link),
  //             )
  //           ],
  //         ),
  //       ),
  //     );

  // // ignore: unused_element
  // Future<MediaPickSetting?> _selectCameraPickSetting(BuildContext context) =>
  //     showDialog<MediaPickSetting>(
  //       context: context,
  //       builder: (ctx) => AlertDialog(
  //         contentPadding: EdgeInsets.zero,
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextButton.icon(
  //               icon: const Icon(Icons.camera),
  //               label: const Text('Capture a photo'),
  //               onPressed: () => Navigator.pop(ctx, MediaPickSetting.camera),
  //             ),
  //             TextButton.icon(
  //               icon: const Icon(Icons.video_call),
  //               label: const Text('Capture a video'),
  //               onPressed: () => Navigator.pop(ctx, MediaPickSetting.video),
  //             )
  //           ],
  //         ),
  //       ),
  //     );

  Widget _buildMenuBar(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Divider(
          thickness: 2,
          indent: size.width * 0.1,
          endIndent: size.width * 0.1,
        ),
        ListTile(
          title: const Center(
              child: Text(
            'Read only demo',
          )),
          dense: true,
          visualDensity: VisualDensity.compact,
          onTap: _openReadOnlyPage,
        ),
        Divider(
          thickness: 2,
          indent: size.width * 0.1,
          endIndent: size.width * 0.1,
        ),
      ],
    );
  }

  void _openReadOnlyPage() {
    Navigator.pop(super.context);
    Navigator.push(
      super.context,
      MaterialPageRoute(
        builder: (context) => Container(),
      ),
    );
  }

  Future<String> _onImagePaste(Uint8List imageBytes) async {
    // Saves the image to applications directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = await File(
      '${appDocDir.path}/${path.basename('${DateTime.now().millisecondsSinceEpoch}.png')}',
    ).writeAsBytes(imageBytes, flush: true);
    return file.path.toString();
  }

  static void _insertTimeStamp(QuillController controller, String string) {
    controller.document.insert(controller.selection.extentOffset, '\n');
    controller.updateSelection(
      TextSelection.collapsed(
        offset: controller.selection.extentOffset + 1,
      ),
      ChangeSource.local,
    );

    controller.document.insert(
      controller.selection.extentOffset,
      string,
    );

    controller.updateSelection(
      TextSelection.collapsed(
        offset: controller.selection.extentOffset + 1,
      ),
      ChangeSource.local,
    );

    controller.document.insert(controller.selection.extentOffset, ' ');
    controller.updateSelection(
      TextSelection.collapsed(
        offset: controller.selection.extentOffset + 1,
      ),
      ChangeSource.local,
    );

    controller.document.insert(controller.selection.extentOffset, '\n');
    controller.updateSelection(
      TextSelection.collapsed(
        offset: controller.selection.extentOffset + 1,
      ),
      ChangeSource.local,
    );
  }
}
