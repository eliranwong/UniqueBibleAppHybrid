// Packages
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipedetector/swipedetector.dart';
// Core libraries
import 'dart:io';
// My libraries
import 'config.dart';
import 'app_translation.dart';
import 'bibles_scroll_coordinator.dart';
// ui
import 'ui_home_bottom_app_bar.dart';
import 'ui_home_top_app_bar.dart';
import 'ui_drawer.dart';
import 'ui_workspace.dart';

class UiHome extends HookWidget {
  // A global key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // To work with provider
  final configState = useProvider(configProvider).state;
  // variable to work with translations
  String abbreviations;
  final Map<String, List<String>> interfaceApp = AppTranslation.interfaceApp,
      interfaceBottom = AppTranslation.interfaceBottom,
      interfaceMessage = AppTranslation.interfaceMessage,
      interfaceDialog = AppTranslation.interfaceDialog,
      interfaceBibleSearch = AppTranslation.interfaceBibleSearch;
  ItemScrollController verseScrollController1, verseScrollController2;
  ItemPositionsListener versePositionsListener1, versePositionsListener2;
  BiblesScrollCoordinator biblesScrollCoordinator;

  // Constructor
  UiHome() {
    setupPackages();
    setupAtmosphere();
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

  void setupAtmosphere() {
    abbreviations = configState.stringValues["abbreviations"];
  }

  @override
  build(BuildContext context) {
    setupBiblesScrollCoordinator(context);
    return Theme(
      data: useProvider(mainThemeP).state,
      child: Scaffold(
        key: _scaffoldKey,
        //drawer: (configState.boolValues["bigScreen"]) ? null : _buildDrawer(),
        appBar: AppBar(
          backgroundColor: useProvider(myColorsP).state["appBarColor"],
          title: Text(useProvider(activeVerseReferenceP).state),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                tooltip: interfaceApp[configState.stringValues["abbreviations"]]
                    [1],
                icon: const Icon(Icons.menu),
                onPressed: () {
                  configState.save(
                      "showDrawer", !context.read(showDrawerP).state);
                  context.refresh(showDrawerP);
                },
              );
            },
          ),
          actions: <Widget>[
            HomeTopAppBar().buildSwitchButton(context),
            HomeTopAppBar().buildWorkspaceButton(context),
            HomeTopAppBar().buildPopupMenuButton(context),
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
          onPressed: () {
            context
                .read(configProvider)
                .state
                .save("parallelVerses", !context.read(parallelVersesP).state);
            context.refresh(parallelVersesP);
            context.read(configProvider).state.updateDisplayChapterData();
            context.refresh(chapterData1P);
            context.read(configProvider).state.updateActiveScrollIndex(
                context.read(historyActiveVerseP).state.first);
            context.refresh(activeScrollIndex1P);
            scrollToBibleVerse1(context.read(activeScrollIndex1P).state);
          },
          //tooltip: interfaceApp[abbreviations][5],
          child: Icon(Icons.add),
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
          return _wrap( DefaultTabController(
            initialIndex: 0,
            length: pages.length,
            child: Builder(
              builder: (BuildContext context) => Padding(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    TabPageSelector(),
                    /*TabBar(
                  labelColor: this.config.myColors["blueAccent"],
                  unselectedLabelColor: this.config.myColors["blue"],
                  tabs: _tabs,
                ),*/
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
              ),
            ),
          ),
          2);
          //return _wrap(_bible2ChapterContent(context), 2);
          /*return _wrap(Workspace((List<dynamic> data) {
            Map<String, Function> actions = {
              "scroll": scrollToBibleVerse1,
            };
            actions[data.first](data.last);
          }), 2);*/
        }
      }),
    ];
  }

  List<Widget> _buildWorkspacePages(BuildContext context) {
    final workspace = Workspace((List<dynamic> data) {
      Map<String, Function> actions = {
        "scroll": scrollToBibleVerse1,
      };
      actions[data.first](data.last);
    });
    return <Widget>[
      _bible2ChapterContent(context),
      workspace.dummyWidget("Tab 1"),
      workspace.dummyWidget("Tab 2"),
      workspace.dummyWidget("Tab 3"),
    ];
  }

  Widget _buildDrawer(BuildContext context) {
    return SizedBox(
      width: 250,
      child: BibleDrawer((List<dynamic> data) {
        Map<String, Function> actions = {
          "scroll": scrollToBibleVerse1,
        };
        actions[data.first](data.last);
      }),
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
        String verseText = data[1].trim();
        if (verseText.contains("<zh>"))
          verseText = verseText.replaceAll(RegExp("<zh>|</zh>"), "");
        return ListTile(
          title: Text(
            "[${data.first.last}]$displayVersion $verseText",
            style: verseStyle,
          ),
          //subtitle: nonEnglishSubtitle,
          /*leading: ((this.config.showFlags) &&
          (chapterHeadingsList.contains(bcvList[2])))
          ? IconButton(
          tooltip: chapterHeadings[
          chapterHeadingsList.indexOf(bcvList[2])][1],
          icon: Icon(
            Icons.outlined_flag,
            color: this.config.myColors["grey"],
          ),
          onPressed: () {
            showSnackbarMessage(chapterHeadings[
            chapterHeadingsList.indexOf(bcvList[2])][1]);
          })
          : null,*/
          /*trailing: (!this.config.showNotes)
          ? null
          : IconButton(
          tooltip: (_noteList.contains(bcvList[2]))
              ? interfaceApp[this.abbreviations][16]
              : interfaceApp[this.abbreviations][15],
          icon: Icon(
            (_noteList.contains(bcvList[2]))
                ? Icons.edit
                : Icons.note_add,
            color: this.config.myColors["blueAccent"],
          ),
          onPressed: () {
            _launchNotePad(context, bcvList);
          }),*/
          onTap: () async {
            if (i != activeScrollIndex) {
              await context
                  .read(configProvider)
                  .state
                  .newVerseSelected(data.first);
              context.refresh(historyActiveVerseP);
              context.refresh(activeVerseReferenceP);
              context.refresh(activeScrollIndex1P);
              context.refresh(activeScrollIndex2P);
            }
          },
          onLongPress: () {
            print("long press");
            //_longPressedActiveVerse(context, _data[i]);
          },
        );
      },
    );
  }

  void setupBiblesScrollCoordinator(BuildContext context) {
    biblesScrollCoordinator = BiblesScrollCoordinator(context, (List<int> data) async {
      // data.first tells which bible to scroll
      // data.last tells which index to go

      // The following delay is necessary to avoid calling on items currently being built.
      await new Future.delayed(const Duration(microseconds: 1));

      final int goToIndex = data.last;
      switch (data.first) {
        case 1:
          if (verseScrollController1.isAttached) verseScrollController1.jumpTo(index: goToIndex);
          break;
        case 2:
          if (verseScrollController2.isAttached) verseScrollController2.jumpTo(index: goToIndex);
          break;
        default:
          break;
      }
    });
  }

  void scrollToBibleVerse1(int index, {bool slowly = false}) {
    if (slowly) {
      verseScrollController1.scrollTo(
          index: index,
          duration: Duration(seconds: 2),
          curve: Curves.easeInOutCubic);
    } else {
      verseScrollController1.jumpTo(index: index);
    }
  }

  void refreshProvidersOnNewChapter(BuildContext context) {
    context.refresh(chapterData1P);
    context.refresh(chapterData2P);
    context.refresh(historyActiveVerseP);
    context.refresh(activeVerseReferenceP);
    context.refresh(activeScrollIndex1P);
    context.refresh(activeScrollIndex2P);
    scrollToBibleVerse1(context.read(activeScrollIndex1P).state);
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
        if (newChapterVerseList.isNotEmpty) {
          await context.read(configProvider).state.newVerseSelected(
              <int>[newBook, newChapter, newChapterVerseList.first]);
          refreshProvidersOnNewChapter(context);
        }
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
      if (newChapterVerseList.isNotEmpty) {
        await context.read(configProvider).state.newVerseSelected(
            <int>[currentBook, newChapter, newChapterVerseList.first]);
        refreshProvidersOnNewChapter(context);
      }
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
        if (newChapterVerseList.isNotEmpty) {
          await context.read(configProvider).state.newVerseSelected(
              <int>[newBook, newChapter, newChapterVerseList.first]);
          refreshProvidersOnNewChapter(context);
        }
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
      if (newChapterVerseList.isNotEmpty) {
        await context.read(configProvider).state.newVerseSelected(
            <int>[currentBook, newChapter, newChapterVerseList.first]);
        refreshProvidersOnNewChapter(context);
      }
    }
  }

}
