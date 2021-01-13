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

  // This workaround functions is applicable in Android devices only.
  static String workaroundHebrewTTSinAndroid(String text) {
    final List<List<String>> searchReplace = [
      ['w', 'v'],
      ['ō|ō|Ō|ô|ŏ', 'ο'],
      ['ê|ē|ĕ', 'e'],
      ['î|ī', 'i'],
      ['û', 'u'],
      //['š', 'sh'],
      ['ś', 's'],
      ['ă|ā|â', 'a'],
      ['[ʿʾ]', ''],
    ];
    for (List<String> i in searchReplace) {
      final String search = i.first;
      final String replace = i.last;
      text = text.replaceAll(RegExp(search), replace);
    }
    return text;
  }

  static String removeGreekAccents(String text) {
    final List<List<String>> searchReplace = [
      ['[ἀἄᾄἂἆἁἅᾅἃάᾴὰᾶᾷᾳᾆᾀ]', 'α'],
      ['[ἈἌἎἉἍἋ]', 'Α'],
      ['[ἐἔἑἕἓέὲ]', 'ε'],
      ['[ἘἜἙἝἛ]', 'Ε'],
      ['[ἠἤᾔἢἦᾖᾐἡἥἣἧᾗᾑήῄὴῆῇῃ]', 'η'],
      ['[ἨἬἪἮἩἭἫ]', 'Η'],
      ['[ἰἴἶἱἵἳἷίὶῖϊΐῒ]', 'ι'],
      ['[ἸἼἹἽ]', 'Ι'],
      ['[ὀὄὂὁὅὃόὸ]', 'ο'],
      ['[ὈὌὉὍὋ]', 'Ο'],
      ['[ῥ]', 'ρ'],
      ['[Ῥ]', 'Ρ'],
      ['[ὐὔὒὖὑὕὓὗύὺῦϋΰῢ]', 'υ'],
      ['[ὙὝὟ]', 'Υ'],
      ['[ὠὤὢὦᾠὡὥὧᾧώῴὼῶῷῳᾤὣ]', 'ω'],
      ['[ὨὬὪὮὩὭὯ]', 'Ω'],
      [
        "[\-\—\,\;\:\\\?\.\·\·\'\‘\’\᾿\‹\›\“\”\«\»\(\)\[\]\{\}\⧼\⧽\〈\〉\*\‿\᾽\⇔\¦]",
        ""
      ],
    ];
    for (List<String> i in searchReplace) {
      final String search = i.first;
      final String replace = i.last;
      text = text.replaceAll(RegExp(search), replace);
    }
    return text;
  }

}