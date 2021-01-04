import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'config.dart';

class BiblesScrollCoordinator {

  final BuildContext context;
  final Function callBack;
  int bible1Index, bible2Index, bibleToBeScrolled = 0;

  BiblesScrollCoordinator(this.context, this.callBack);

  void updateBible1Index(int index) {
    if (index != bible1Index) {
      bible1Index = index;

      if (bibleToBeScrolled != 1) {
        bibleToBeScrolled = 2;
        checkScrolling();
      } else if (bibleToBeScrolled == 1) {
        bibleToBeScrolled = 0;
      }
    }
  }

  void updateBible2Index(int index) {
    if (index != bible2Index) {
      bible2Index = index;

      if (bibleToBeScrolled != 2) {
        bibleToBeScrolled = 1;
        checkScrolling();
      } else if (bibleToBeScrolled == 2) {
        bibleToBeScrolled = 0;
      }
    }
  }

  void checkScrolling() {
    final List<List<dynamic>> chapterData1 = context.read(chapterData1P).state;
    final List<List<dynamic>> chapterData2 = context.read(chapterData2P).state;
    switch (bibleToBeScrolled) {
      case 1:
        final String verseBCV = chapterData2[bible2Index].first.join(".");
        final int correspondingIndex = chapterData1.indexWhere((data) => data.first.join(".") == verseBCV);
        if ((correspondingIndex != -1) && (correspondingIndex != bible1Index)) callBack([1, correspondingIndex]);
        break;
      case 2:
        final String verseBCV = chapterData1[bible1Index].first.join(".");
        final int correspondingIndex = chapterData2.indexWhere((data) => data.first.join(".") == verseBCV);
        if ((correspondingIndex != -1) && (correspondingIndex != bible2Index)) callBack([2, correspondingIndex]);
        break;
      default:
        break;
    }
  }

}
