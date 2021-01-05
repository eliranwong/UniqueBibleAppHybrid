class TextTransformer {

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