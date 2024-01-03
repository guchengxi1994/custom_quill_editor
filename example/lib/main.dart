import 'package:custom_quill_editor/editor.dart';
import 'package:custom_quill_editor/editor_insert_listview.dart';
import 'package:custom_quill_editor/image_provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<EditorState> globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Editor(
        key: globalKey,
        onSelectImage: () async {
          await showGeneralDialog(
              barrierDismissible: true,
              barrierColor: Colors.transparent,
              barrierLabel: "editor",
              context: context,
              pageBuilder: (c, _, __) {
                return Center(
                  child: EditorImageInsertListview(
                    editorImageProvider: EditorImageProvider(
                      images: [
                        EditorImage(
                            name: "1.png",
                            path:
                                r"D:\github_repo\custom_quill_editor\example\images\1.png")
                      ],
                      onSelect: (e) {
                        // print(e.name);

                        globalKey.currentState!.insertImage(e.path!);
                      },
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
