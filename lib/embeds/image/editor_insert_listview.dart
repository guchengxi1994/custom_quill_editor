import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'image_provider.dart';

class EditorImageInsertListview extends StatefulWidget {
  const EditorImageInsertListview(
      {super.key, required this.editorImageProvider});
  final EditorImageProvider editorImageProvider;

  @override
  State<EditorImageInsertListview> createState() =>
      _EditorImageInsertListviewState();
}

class _EditorImageInsertListviewState extends State<EditorImageInsertListview> {
  late FocusNode focusNode;
  int focusedIndex = 0;
  final ScrollController controller = ScrollController();
  late ListObserverController observerController =
      ListObserverController(controller: controller);

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    focusNode.requestFocus();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        observerController.animateTo(
          index: focusedIndex,
          curve: Curves.ease,
          duration: const Duration(milliseconds: 100),
        );
      },
    );

    return Material(
      child: RawKeyboardListener(
          focusNode: focusNode,
          onKey: (event) {
            // print(event);
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                setState(() {
                  focusedIndex = (focusedIndex + 1) % 10; // Assuming 10 items
                });
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                setState(() {
                  focusedIndex = (focusedIndex - 1) % 10; // Assuming 10 items
                });
              } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                Navigator.of(context).pop();
                if (widget.editorImageProvider.onSelect != null) {
                  widget.editorImageProvider.onSelect!(
                      widget.editorImageProvider.images[focusedIndex]);
                }
              }
            }
          },
          child: Container(
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
            width: 300,
            height: 300,
            child: ListViewObserver(
              controller: observerController,
              child: ListView.builder(
                  controller: controller,
                  itemCount: widget.editorImageProvider.images.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        widget.editorImageProvider.images[index].name,
                        style: TextStyle(
                            color: index == focusedIndex ? Colors.blue : null),
                      ),
                    );
                  }),
            ),
          )),
    );
  }
}
