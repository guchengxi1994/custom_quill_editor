import 'dart:typed_data';

typedef OnSelect = void Function(EditorImage e);

class EditorImageProvider {
  final List<EditorImage> images;
  final OnSelect? onSelect;

  EditorImageProvider({required this.images, this.onSelect});
}

class EditorImage {
  final String name;
  final String? path;
  final Uint8List? data;

  EditorImage({required this.name, this.data, this.path}) {
    assert(path != null || path != null);
  }

  @override
  bool operator ==(Object other) {
    if (other is! EditorImage) {
      return false;
    }
    return other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
