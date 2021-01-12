class TextTransformer {

  static String processBibleVerseText(String verseText) {
    // Remove white spaces at both ends.
    verseText = verseText.trim();
    // Remove all html tags if present.
    if (RegExp("<.*?>").hasMatch(verseText))
      verseText = verseText.replaceAll(RegExp("<.*?>"), "");
    return verseText;
  }

  static String removeFullWidthPunctuation(String input) {
    List<List<String>> searchReplaces = [
      ["，", ","],
      ["：", ":"],
      ["；", ";"],
      ["－", "-"],
      ["─", "-"],
    ];
    for (List<String> searchReplace in searchReplaces) {
      input = input.replaceAll(searchReplace.first, searchReplace.last);
    }
    return input;
  }

}