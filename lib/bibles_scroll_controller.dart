class BiblesScrollCoordinator {

  final Function onCallBack;
  int bible1Index, bible2Index, bibleToBeScrolled = 0;
  int lastScrolledIndex;

  BiblesScrollCoordinator(this.onCallBack);

  void updateBible1Index(int index) {
    if (index != bible1Index) {
      bible1Index = index;

      if (bibleToBeScrolled != 1) {
        bibleToBeScrolled = 2;
        checkScrolling(bible1Index);
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
        checkScrolling(bible2Index);
      } else if (bibleToBeScrolled == 2) {
        bibleToBeScrolled = 0;
      }
    }
  }

  void checkScrolling(int index) {
    if (lastScrolledIndex != index) {
      lastScrolledIndex = index;
      onCallBack([bibleToBeScrolled, index]);
    }
  }

}