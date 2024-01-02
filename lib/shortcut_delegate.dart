class ShortcutDelegate {
  final String insertImage;
  int get imageShortCutLength => insertImage.length;

  final String insertEmoji;
  int get emojiShortCutLength => insertEmoji.length;

  final String insertTable;
  int get tableShortCutLength => insertTable.length;

  const ShortcutDelegate(
      {this.insertImage = "/image",
      this.insertEmoji = "/emoji",
      this.insertTable = "/table"});
}
