// Packages
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
// Core libraries
import 'dart:io';
// My libraries
import 'config.dart';
import 'app_translation.dart';
import 'bibles_scroll_coordinator.dart';
import 'bible.dart';
// ui
import 'ui_home_bottom_app_bar.dart';
import 'ui_home_top_app_bar.dart';
import 'ui_drawer.dart';
import 'ui_workspace.dart';
import 'ui_workspace_bible_search_result.dart';
import 'ui_workspace_multiple_verses.dart';

class UiHome extends HookWidget {
  // A global key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // To work with provider
  final configState = useProvider(configProvider).state;
  // variable to work with translations
  /*String language;
  final Map<String, List<String>> interfaceApp = AppTranslation.interfaceApp,
      interfaceBottom = AppTranslation.interfaceBottom,
      interfaceMessage = AppTranslation.interfaceMessage,
      interfaceDialog = AppTranslation.interfaceDialog,
      interfaceBibleSearch = AppTranslation.interfaceBibleSearch;*/
  ItemScrollController verseScrollController1, verseScrollController2;
  ItemPositionsListener versePositionsListener1, versePositionsListener2;
  BiblesScrollCoordinator biblesScrollCoordinator;
  TabController workSpaceTabController;
  int workSpaceTabIndex = 0;

  // Constructor
  UiHome() {
    setupPackages();
    //setupAtmosphere();
  }

  void setupPackages() {
    // Using hybrid composition for webview v1.0.7+; read https://pub.dev/packages/webview_flutter
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    // initiate tts plugin
    //initTts();
    // Lemmatizer
    //lemmatizer =  Lemmatizer();
    // _text = lemmatizer.lemma(_controller.text);

    // Setup scroll controllers for reading parallel chapters.
    verseScrollController1 = ItemScrollController();
    versePositionsListener1 = ItemPositionsListener.create();
    verseScrollController2 = ItemScrollController();
    versePositionsListener2 = ItemPositionsListener.create();
  }

  /*void setupAtmosphere() {
    language = configState.stringValues["language"];
  }*/

  @override
  build(BuildContext context) {
    setupBiblesScrollCoordinator(context);
    final HomeTopAppBar homeTopAppBar = HomeTopAppBar(
        (List<dynamic> data) async => await callBack(context, data));
    return Theme(
      data: useProvider(mainThemeP).state,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: useProvider(myColorsP).state["appBarColor"],
          title: Text(useProvider(activeVerseReferenceP).state),
          leading: Builder(
            builder: (BuildContext context) {
              return Consumer(
                builder: (context, watch, child) {
                  return IconButton(
                    tooltip: watch(interfaceAppP).state[1],
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      configState.save(
                          "showDrawer", !context.read(showDrawerP).state);
                      context.refresh(showDrawerP);
                    },
                  );
                });
            },
          ),
          actions: <Widget>[
            homeTopAppBar.parallelVersesButton(context),
            homeTopAppBar.buildSwitchButton(context),
            homeTopAppBar.buildPopupMenuButton(context),
          ],
        ),
        body: Container(
          color: configState.myColors["backgroundColor"],
          child: _buildLayout(context),
        ),
        bottomNavigationBar: HomeBottomAppBar(context).buildBottomAppBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  // Required by build function: _buildDrawer(), _buildAppBar(context), _buildLayout(context), _buildBottomAppBar(context), _buildFloatingActionButton()
  Widget _buildFloatingActionButton(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        return FloatingActionButton(
          backgroundColor: watch(myColorsP).state["floatingButtonColor"],
          tooltip: watch(interfaceBottomP).state[9],
          onPressed: () async {
            await context.read(configProvider).state.changeWorkspaceLayout();
            context.refresh(workspaceLayoutP);
          },
          child: Icon(Icons.workspaces_outline),
        );
      },
    );
  }

  Widget _buildLayout(BuildContext context) {
    return Row(
      children: <Widget>[
        Consumer(
          builder: (context, watch, child) =>
              (watch(showDrawerP).state) ? _buildDrawer(context) : Container(),
        ),
        Consumer(
          builder: (context, watch, child) =>
              (watch(showDrawerP).state) ? _buildDivider() : Container(),
        ),
        _wrap(
          OrientationBuilder(
            builder: (context, orientation) {
              List<Widget> layoutWidgets = _buildLayoutWidgets(context);
              return (orientation == Orientation.portrait)
                  ? Column(children: layoutWidgets)
                  : Row(children: layoutWidgets);
            },
          ),
          1,
        ),
      ],
    );
  }

  Widget _wrap(Widget widget, int flex) {
    return Expanded(
      flex: flex,
      child: widget,
    );
  }

  Widget _buildDivider() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: configState.myColors["grey"])),
    );
  }

  List<Widget> _buildLayoutWidgets(BuildContext context) {
    return <Widget>[
      Consumer(
        builder: (context, watch, child) {
          final int workspaceLayout = watch(workspaceLayoutP).state;
          if (workspaceLayout == 2) {
            return Container();
          } else {
            return _wrap(_buildBibleChapter1(context), 2);
          }
        },
      ),
      Consumer(
        builder: (context, watch, child) {
          final int workspaceLayout = watch(workspaceLayoutP).state;
          if (workspaceLayout == 1) {
            return _buildDivider();
          } else {
            return Container();
          }
        },
      ),
      Consumer(builder: (context, watch, child) {
        final int workspaceLayout = watch(workspaceLayoutP).state;
        if (workspaceLayout == 0) {
          return Container();
        } else {
          List<Widget> pages = _buildWorkspacePages(context);
          return _wrap(
              DefaultTabController(
                initialIndex: workSpaceTabIndex,
                length: pages.length,
                child: Builder(builder: (BuildContext context) {
                  workSpaceTabController = DefaultTabController.of(context);
                  workSpaceTabController.addListener(() {
                    if ((!workSpaceTabController.indexIsChanging) &&
                        (workSpaceTabIndex != workSpaceTabController.index))
                      workSpaceTabIndex = workSpaceTabController.index;
                  });
                  return Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: <Widget>[
                        TabPageSelector(),
                        Expanded(
                          child: IconTheme(
                            data: IconThemeData(
                                //color: canvasColor,
                                ),
                            child: TabBarView(
                              children: pages,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              2);
        }
      }),
    ];
  }

  List<Widget> _buildWorkspacePages(BuildContext context) {
    final workspace =
        Workspace((List<dynamic> data) async => await callBack(context, data));
    return <Widget>[
      _bible2ChapterContent(context),
      BibleSearchResults((List<dynamic> data) async => await callBack(context, data)),
      MultipleVerses((List<dynamic> data) async => await callBack(context, data)),
      //TestChart(),
      //TestFlutterHTML(),
      //workspace.dummyWidget("Tab 3"),
    ];
  }

  Widget _buildDrawer(BuildContext context) {
    return SizedBox(
      width: 250,
      child: BibleDrawer(
          (List<dynamic> data) async => await callBack(context, data)),
    );
  }

  Widget _buildBibleChapter1(BuildContext context) {
    return SwipeDetector(
      child: _bible1ChapterContent(context),
      onSwipeLeft: () async {
        await goNextChapter(context);
      },
      onSwipeRight: () async {
        await goPreviousChapter(context);
      },
    );
  }

  Widget _bible1ChapterContent(BuildContext context) {
    return ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: versePositionsListener1.itemPositions,
      builder: (context, positions, child) {
        int topIndex;
        if (positions.isNotEmpty) {
          topIndex = positions
              .where((ItemPosition position) => position.itemTrailingEdge > 0)
              .reduce((ItemPosition min, ItemPosition position) =>
                  position.itemTrailingEdge < min.itemTrailingEdge
                      ? position
                      : min)
              .index;
          /*int bottomIndex = positions
              .where((ItemPosition position) => position.itemLeadingEdge < 1)
              .reduce((ItemPosition max, ItemPosition position) =>
          position.itemLeadingEdge > max.itemLeadingEdge
              ? position
              : max)
              .index;*/

          // Update bible 1 current position
          biblesScrollCoordinator.updateBible1Index(topIndex);
        }
        return _buildBibleVerses1(context);
      },
    );
  }

  Widget _bible2ChapterContent(BuildContext context) {
    return ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: versePositionsListener2.itemPositions,
      builder: (context, positions, child) {
        int topIndex;
        if (positions.isNotEmpty) {
          topIndex = positions
              .where((ItemPosition position) => position.itemTrailingEdge > 0)
              .reduce((ItemPosition min, ItemPosition position) =>
                  position.itemTrailingEdge < min.itemTrailingEdge
                      ? position
                      : min)
              .index;
          /*int bottomIndex = positions
              .where((ItemPosition position) => position.itemLeadingEdge < 1)
              .reduce((ItemPosition max, ItemPosition position) =>
          position.itemLeadingEdge > max.itemLeadingEdge
              ? position
              : max)
              .index;*/

          // Update bible 2 current position
          biblesScrollCoordinator.updateBible2Index(topIndex);
        }
        return _buildBibleVerses2(context);
      },
    );
  }

  Widget _buildBibleVerses1(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final List<List<dynamic>> chapterData = watch(chapterData1P).state;
        final int activeScrollIndex1 = watch(activeScrollIndex1P).state;
        return ScrollablePositionedList.builder(
          padding: EdgeInsets.zero,
          itemCount: chapterData.length,
          itemBuilder: (context, i) =>
              _buildVerseRow(context, i, activeScrollIndex1, chapterData[i]),
          initialScrollIndex: activeScrollIndex1,
          itemScrollController: verseScrollController1,
          itemPositionsListener: versePositionsListener1,
        );
      },
    );
  }

  Widget _buildBibleVerses2(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final List<List<dynamic>> chapterData = watch(chapterData2P).state;
        final int activeScrollIndex2 = watch(activeScrollIndex2P).state;
        return ScrollablePositionedList.builder(
          padding: EdgeInsets.zero,
          itemCount: chapterData.length,
          itemBuilder: (context, i) =>
              _buildVerseRow(context, i, activeScrollIndex2, chapterData[i]),
          initialScrollIndex: activeScrollIndex2,
          //initialAlignment: 0.0,
          itemScrollController: verseScrollController2,
          itemPositionsListener: versePositionsListener2,
        );
      },
    );
  }

  Widget _buildVerseRow(
      BuildContext context, int i, int activeScrollIndex, List<dynamic> data) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final TextStyle verseStyle = (i == activeScrollIndex)
            ? myTextStyle["activeVerseFont"]
            : myTextStyle["verseFont"];
        final String displayVersion =
            (context.read(parallelVersesP).state) ? " [${data.last}]" : "";
        final String verseText = Bible.processVerseText(data[1]);
        return ListTile(
          title: ParsedText(
            //selectable: true, //selectable option breaks the listener for parallel scrolling
            alignment: TextAlign.start,
            text: "[${data.first.last}]$displayVersion $verseText",
            style: verseStyle,
              parse: <MatchText>[
                MatchText(
                  pattern: r"\[[0-9]+?\]",
                  style: myTextStyle["verseNoFont"],
                ),
              ],
          ),
          onTap: () async {
            if (i != activeScrollIndex)
              await newVerseSelectedSameChapter(context, data.first);
          },
          onLongPress: () {
            // TODO: implement verse features here.
            print("long press");
          },
          // WARNING: DO NOT use SelectableText widget together with itemPositionsListener.  The listener breaks.
          /*title: SelectableText.rich(
            TextSpan(
              text: "[${data.first.last}]$displayVersion $verseText",
              style: verseStyle,
            ),
            //toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
            onTap: () async {
              if (i != activeScrollIndex) {
                await newVerseSelectedSameChapter(context, data.first);
              }
            },
          ),*/
        );
      },
    );
  }

  void setupBiblesScrollCoordinator(BuildContext context) {
    biblesScrollCoordinator =
        BiblesScrollCoordinator(context, (List<int> data) async {
      // data.first tells which bible to scroll
      // data.last tells which index to go

      // The following delay is necessary to avoid calling on items currently being built.
      await new Future.delayed(const Duration(microseconds: 1));

      final int goToIndex = data.last;
      switch (data.first) {
        case 1:
          if (verseScrollController1.isAttached)
            verseScrollController1.jumpTo(index: goToIndex);
          break;
        case 2:
          if (verseScrollController2.isAttached)
            verseScrollController2.jumpTo(index: goToIndex);
          break;
        default:
          break;
      }
    });
  }

  void scrollToBibleVerse(BuildContext context,
      {int index = -1, bool slowly = false}) {
    int workspaceLayout = context.read(workspaceLayoutP).state;
    if ((workspaceLayout != 2) && (verseScrollController1.isAttached)) {
      index = (index == -1) ? context.read(activeScrollIndex1P).state : index;
      if (slowly) {
        verseScrollController1.scrollTo(
            index: index,
            duration: Duration(seconds: 2),
            curve: Curves.easeInOutCubic);
      } else {
        verseScrollController1.jumpTo(index: index);
      }
    } else if (verseScrollController2.isAttached) {
      index = (index == -1) ? context.read(activeScrollIndex2P).state : index;
      if (slowly) {
        verseScrollController2.scrollTo(
            index: index,
            duration: Duration(seconds: 2),
            curve: Curves.easeInOutCubic);
      } else {
        verseScrollController2.jumpTo(index: index);
      }
    }
  }

  Future<void> goNextChapter(BuildContext context) async {
    final List<int> activeVerse = context.read(historyActiveVerseP).state.first;
    final int currentBook = activeVerse.first;
    final int currentChapter = activeVerse[1];
    final List<int> chapterList =
        context.read(configProvider).state.bibleDB1.chapterList;
    if (currentChapter == chapterList.last) {
      // Current chapter is the last chapter of the currently opened book.
      // Therefore, we open the first chapter of next available book.
      final List<int> bookList =
          context.read(configProvider).state.bibleDB1.bookList;
      // If the currently opened book is the last book of the opened bible module, we open the first chapter of the first book.
      final int newBook = (currentBook == bookList.last)
          ? bookList.first
          : bookList[bookList.indexOf(currentBook) + 1];
      final List<int> newChapterList = await context
          .read(configProvider)
          .state
          .bibleDB1
          .getChapterList([newBook, 1, 1]);
      if (newChapterList.isNotEmpty) {
        final int newChapter = newChapterList.first;
        final List<int> newChapterVerseList = await context
            .read(configProvider)
            .state
            .bibleDB1
            .getVerseList([newBook, newChapter, 1]);
        if (newChapterVerseList.isNotEmpty)
          await newVerseSelected(
              context, <int>[newBook, newChapter, newChapterVerseList.first]);
      }
    } else {
      final int currentChapterIndex = chapterList.indexOf(currentChapter);
      final int newChapter = context
          .read(configProvider)
          .state
          .bibleDB1
          .chapterList[currentChapterIndex + 1];
      final List<int> newChapterVerseList = await context
          .read(configProvider)
          .state
          .bibleDB1
          .getVerseList([currentBook, newChapter, 1]);
      if (newChapterVerseList.isNotEmpty)
        await newVerseSelected(
            context, <int>[currentBook, newChapter, newChapterVerseList.first]);
    }
  }

  Future<void> goPreviousChapter(BuildContext context) async {
    final List<int> activeVerse = context.read(historyActiveVerseP).state.first;
    final int currentBook = activeVerse.first;
    final int currentChapter = activeVerse[1];
    final List<int> chapterList =
        context.read(configProvider).state.bibleDB1.chapterList;
    if (currentChapter == chapterList.first) {
      // Current chapter is the first chapter of the currently opened book.
      // Therefore, we open the last chapter of previous available book.
      final List<int> bookList =
          context.read(configProvider).state.bibleDB1.bookList;
      // If the currently opened book is the last book of the opened bible module, we open the first chapter of the first book.
      final int newBook = (currentBook == bookList.first)
          ? bookList.last
          : bookList[bookList.indexOf(currentBook) - 1];
      final List<int> newChapterList = await context
          .read(configProvider)
          .state
          .bibleDB1
          .getChapterList([newBook, 1, 1]);
      if (newChapterList.isNotEmpty) {
        final int newChapter = newChapterList.last;
        final List<int> newChapterVerseList = await context
            .read(configProvider)
            .state
            .bibleDB1
            .getVerseList([newBook, newChapter, 1]);
        if (newChapterVerseList.isNotEmpty)
          await newVerseSelected(
              context, <int>[newBook, newChapter, newChapterVerseList.first]);
      }
    } else {
      final int currentChapterIndex = chapterList.indexOf(currentChapter);
      final int newChapter = context
          .read(configProvider)
          .state
          .bibleDB1
          .chapterList[currentChapterIndex - 1];
      final List<int> newChapterVerseList = await context
          .read(configProvider)
          .state
          .bibleDB1
          .getVerseList([currentBook, newChapter, 1]);
      if (newChapterVerseList.isNotEmpty)
        await newVerseSelected(
            context, <int>[currentBook, newChapter, newChapterVerseList.first]);
    }
  }

  // Workspace
  Future<void> changeWorkspaceTab(BuildContext context, int i) async {
    // Open workspace if it is closed.
    if (context.read(configProvider).state.intValues["workspaceLayout"] == 0) {
      await context.read(configProvider).state.changeWorkspaceLayout();
      context.refresh(workspaceLayoutP);
    }

    workSpaceTabIndex = i;
    if ((workSpaceTabController != null) &&
        (!workSpaceTabController.indexIsChanging))
      workSpaceTabController.animateTo(i);
  }

  // Call back functions

  Future<void> callBack(BuildContext context, List<dynamic> data) async {
    Map<String, Function> actions = {
      "newVersionVerseSelected": newVersionVerseSelected,
      "newVerseSelected": newVerseSelected,
      "newVerseSelectedSameChapter": newVerseSelectedSameChapter,
      "changeBible1Version": changeBible1Version,
      "changeBible2Version": changeBible2Version,
      "searchBible1": searchBible1,
      "loadMultipleVerses": loadMultipleVerses,
      "scrollToBibleVerse": scrollToBibleVerse, // non-future function
    };
    (data.last.isEmpty)
        ? actions[data.first](context)
        : await actions[data.first](context, data.last);
  }

  Future<void> newVersionVerseSelected(
      BuildContext context, List<dynamic> data) async {
    final String module = data.last;
    final String activeModule = context.read(bible1P).state;
    if (module != activeModule) await changeBible1Version(context, module);
    final List<int> bcvList = [for (int i in data.first) i];
    final List<int> activeVerse = context.read(configProvider).state.listListIntValues["historyActiveVerse"].first;
    if (bcvList.join(".") != activeVerse.join(".")) await newVerseSelected(context, bcvList);
  }

  Future<void> newVerseSelectedSameChapter(
          BuildContext context, List<dynamic> bcvList) async =>
      await newVerseSelected(context, bcvList, sameChapter: true);

  Future<void> newVerseSelected(BuildContext context, List<dynamic> bcvList,
      {bool sameChapter = false}) async {
    await context.read(configProvider).state.newVerseSelected(bcvList);
    context.refresh(historyActiveVerseP);
    context.refresh(activeScrollIndex1P);
    context.refresh(activeScrollIndex2P);
    if (!sameChapter) {
      context.refresh(chapterData1P);
      context.refresh(chapterData2P);
    }
    context.refresh(menuBookP);
    context.refresh(menuChapterP);
    scrollToBibleVerse(context);
  }

  Future<void> changeBible1Version(BuildContext context, String module) async =>
      await changeBibleVersion(context, module, 1);
  Future<void> changeBible2Version(BuildContext context, String module) async =>
      await changeBibleVersion(context, module, 2);

  Future<void> changeBibleVersion(
      BuildContext context, String module, int whichBible) async {
    final List<String> allBiblesList =
        context.read(configProvider).state.allBibles.keys.toList();
    final List<int> activeVerse = context
        .read(configProvider)
        .state
        .listListIntValues["historyActiveVerse"]
        .first;
    if (allBiblesList.contains(module)) {
      switch (whichBible) {
        case 1:
          await context.read(configProvider).state.openBibleDB1(module: module);
          await context
              .read(configProvider)
              .state
              .bibleDB1
              .updateBCVMenu(activeVerse);
          await context
              .read(configProvider)
              .state
              .bibleDB1
              .updateChapterData(activeVerse);
          context.refresh(bible1P);
          break;
        case 2:
          await context.read(configProvider).state.openBibleDB2(module: module);
          await context
              .read(configProvider)
              .state
              .bibleDB2
              .updateBCVMenu(activeVerse);
          await context
              .read(configProvider)
              .state
              .bibleDB2
              .updateChapterData(activeVerse);
          context.refresh(bible2P);

          break;
        default:
          break;
      }
      context.read(configProvider).state.updateActiveScrollIndex(activeVerse);
      context.read(configProvider).state.updateDisplayChapterData();
      switch (whichBible) {
        case 1:
          context.refresh(bible1P);
          context.refresh(chapterData1P);
          context.refresh(activeScrollIndex1P);
          break;
        case 2:
          context.refresh(bible2P);
          context.refresh(chapterData2P);
          context.refresh(activeScrollIndex2P);
          break;
        default:
          break;
      }
    }
    scrollToBibleVerse(context);
  }

  Future<void> searchBible1(BuildContext context, List<dynamic> data) async {
    await changeWorkspaceTab(context, 1);

    final int searchEntryOption = context.read(searchEntryOptionP).state;
    final bool searchWholeBible = context.read(searchWholeBibleP).state;
    List<int> filter = (searchWholeBible) ? [] : context.read(bibleSearchBookFilterP).state.toList()..sort();
    await context
        .read(configProvider)
        .state
        .bibleDB1
        .searchMultipleBooks(data.first, searchEntryOption, filter: filter, exclusion: data.last);
    context.refresh(bibleSearchDataP);
  }

  Future<void> loadMultipleVerses(BuildContext context, List<dynamic> data) async {
    // Remove empty item .removeWhere((i) => i.isEmpty);
    Bible bible = context.read(configProvider).state.bibleDB1;
    List<List<dynamic>> newData = [for (List<dynamic> item in data) (item.length > 3) ? await bible.getSingleVerseDataRange(item) : await bible.getSingleVerseData(item)]..removeWhere((i) => (i).isEmpty);
    context.read(configProvider).state.updateMultipleVersesData(newData);
    context.read(configProvider).state.updateMultipleVersesShowVersion(false);
    context.refresh(multipleVersesP);
  }

}
