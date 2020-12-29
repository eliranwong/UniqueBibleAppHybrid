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
  ItemScrollController verseScrollController;
  ItemPositionsListener versePositionsListener;

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
  }

  void setupAtmosphere() {
    abbreviations = configState.stringValues["abbreviations"];
  }

  @override
  build(BuildContext context) {
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
            context.refresh(chapterDataP);
            context.read(configProvider).state.updateActiveScrollIndex(
                context.read(historyActiveVerseP).state.first);
            context.refresh(activeScrollIndexP);
            scrollToBibleVerse(context.read(activeScrollIndexP).state);
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
            return _wrap(_buildBibleChapter(context), 2);
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
          return _wrap(Workspace((List<dynamic> data) {
            Map<String, Function> actions = {
              "scroll": scrollToBibleVerse,
            };
            actions[data.first](data.last);
          }), 2);
        }
      }),
    ];
  }

  Widget _buildDrawer(BuildContext context) {
    return SizedBox(
      width: 250,
      child: BibleDrawer((List<dynamic> data) {
        Map<String, Function> actions = {
          "scroll": scrollToBibleVerse,
        };
        actions[data.first](data.last);
      }),
    );
  }

  void scrollToBibleVerse(int index, {bool slowly = false}) {
    if (slowly) {
      this.verseScrollController.scrollTo(
          index: index,
          duration: Duration(seconds: 2),
          curve: Curves.easeInOutCubic);
    } else {
      this.verseScrollController.jumpTo(index: index);
    }
  }

  Widget _buildBibleChapter(BuildContext context) {
    return SwipeDetector(
      child: _buildBibleVerses(context),
      onSwipeLeft: () async {
        await goNextChapter(context);
      },
      onSwipeRight: () async {
        await goPreviousChapter(context);
      },
    );
  }

  void refreshProvidersForNewChapter(BuildContext context) {
    context.refresh(chapterDataP);
    context.refresh(historyActiveVerseP);
    context.refresh(activeVerseReferenceP);
    context.refresh(activeScrollIndexP);
    scrollToBibleVerse(context.read(activeScrollIndexP).state);
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
          refreshProvidersForNewChapter(context);
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
        refreshProvidersForNewChapter(context);
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
          refreshProvidersForNewChapter(context);
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
        refreshProvidersForNewChapter(context);
      }
    }
  }

  Widget _buildBibleVerses(BuildContext context) {
    verseScrollController = ItemScrollController();
    versePositionsListener = ItemPositionsListener.create();
    return Consumer(
      builder: (context, watch, child) {
        final List<List<dynamic>> chapterData = watch(chapterDataP).state;
        final int activeScrollIndex = watch(activeScrollIndexP).state;
        return ScrollablePositionedList.builder(
          padding: EdgeInsets.zero,
          itemCount: chapterData.length,
          itemBuilder: (context, i) =>
              _buildVerseRow(context, i, activeScrollIndex, chapterData[i]),
          initialScrollIndex: activeScrollIndex,
          //initialAlignment: 0.0,
          itemScrollController: verseScrollController,
          itemPositionsListener: versePositionsListener,
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
              context.refresh(activeScrollIndexP);
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
}
