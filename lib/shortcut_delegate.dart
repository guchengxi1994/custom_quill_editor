class ShortcutDelegate {
  final String insertImage;
  int get imageShortCutLength => insertImage.length;

  final String insertEmoji;
  int get emojiShortCutLength => insertEmoji.length;

  const ShortcutDelegate({
    this.insertImage = "/image",
    this.insertEmoji = "/emoji",
  });

  int get maxLen => [insertImage, insertEmoji]
      .reduce((a, b) => a.length > b.length ? a : b)
      .length;
}
