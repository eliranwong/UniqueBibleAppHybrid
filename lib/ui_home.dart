// Packages
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
//import 'package:swipedetector/swipedetector.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
// The following three imports work with webview.
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
// Core libraries
import 'dart:io';
import 'dart:async';
// My libraries
import 'config.dart';
import 'file_mx.dart';
import 'bibles_scroll_coordinator.dart';
import 'bible.dart';
import 'bible_parser.dart';
import 'text_transformer.dart';
import 'html_elements.dart';
import 'font_uri.dart';
import 'testing_text.dart';
// ui
import 'ui_workspace_word_features.dart';
import 'ui_home_bottom_app_bar.dart';
import 'ui_home_top_app_bar.dart';
import 'ui_drawer.dart';
import 'ui_workspace.dart';
import 'ui_workspace_bible_search_result.dart';
import 'ui_workspace_multiple_verses.dart';
import 'ui_workspace_multiple_versions.dart';
import 'ui_workspace_lookup_content.dart';

class UiHome extends HookWidget {
  // A global key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Widget controllers
  PageController chaptersPageController;
  ItemScrollController verseScrollController1 = ItemScrollController(), verseScrollController2 = ItemScrollController();
  ItemPositionsListener versePositionsListener1 = ItemPositionsListener.create(), versePositionsListener2 = ItemPositionsListener.create();
  BiblesScrollCoordinator biblesScrollCoordinator;
  TabController workSpaceTabController;
  int workSpaceTabIndex = 0;
  WebViewController _webViewController;

  // Constructor
  UiHome() {
    setupPackages();
    //setupAtmosphere();
  }

  void setupPackages() {
    // Using hybrid composition for webview v1.0.7+; read https://pub.dev/packages/webview_flutter
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    // Lemmatizer
    //lemmatizer =  Lemmatizer();
    // _text = lemmatizer.lemma(_controller.text);
  }

  void setupChaptersPageController(BuildContext context) {
    final List<String> allChapterList1 = context.read(allChapterList1P).state;
    final List<int> activeVerse = context.read(historyActiveVerseP).state.first;
    final int initialChapterIndex = allChapterList1.indexOf("${activeVerse.first}.${activeVerse[1]}");
    chaptersPageController = PageController(initialPage: (initialChapterIndex == -1) ? 0 : initialChapterIndex);
    // The following line does not work.
    //context.read(currentChapterPageP).state = initialChapterIndex.toDouble();
    // Therefore, we use the following line instead.
    context.read(configProvider).state.updateCurrentChapterPage(initialChapterIndex.toDouble());
    chaptersPageController.addListener(() => context.read(currentChapterPageP).state = chaptersPageController.page);
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

  @override
  build(BuildContext context) {
    setupChaptersPageController(context);
    setupBiblesScrollCoordinator(context);
    final Map<String, Color> myColors = useProvider(myColorsP).state;
    final HomeTopAppBar homeTopAppBar = HomeTopAppBar(
        (List<dynamic> data) async => await callBack(context, data));
    return Theme(
      data: useProvider(mainThemeP).state,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: myColors["appBarColor"],
          title: Row(
            children: [
              IconButton(
                //tooltip: watch(interfaceAppP).state[1],
                icon: const Icon(Icons.navigate_before),
                onPressed: () {
                  chaptersPageController.previousPage(
                    duration: Duration(milliseconds: 10),
                    curve: Curves.linear,
                  );
                },
              ),
              Consumer(builder: (context, watch, child) {
                return TextButton(
                  onPressed: () {
                    context.read(configProvider).state.save(
                        "showDrawer", !context.read(showDrawerP).state);
                    context.refresh(showDrawerP);
                  },
                  child: Text(
                    watch(activeVerseReferenceP).state,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }),
              IconButton(
                //tooltip: watch(interfaceAppP).state[1],
                icon: const Icon(Icons.navigate_next),
                onPressed: () {
                  chaptersPageController.nextPage(
                    duration: Duration(milliseconds: 10),
                    curve: Curves.linear,
                  );
                },
              ),
            ],
          ),
          /*leading: Builder(
            builder: (BuildContext context) {
              return Consumer(builder: (context, watch, child) {
                return IconButton(
                  tooltip: watch(interfaceAppP).state[1],
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    context.read(configProvider).state.save(
                        "showDrawer", !context.read(showDrawerP).state);
                    context.refresh(showDrawerP);
                  },
                );
              });
            },
          ),*/
          actions: <Widget>[
            homeTopAppBar.parallelVersesButton(context),
            homeTopAppBar.buildSwitchButton(context),
            homeTopAppBar.buildPopupMenuButton(context),
          ],
        ),
        body: Container(
          color: myColors["backgroundColor"],
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
          mini: true,
          backgroundColor: watch(myColorsP).state["floatingButtonColor"],
          tooltip: watch(interfaceBottomP).state[9],
          onPressed: () async {
            await context.read(configProvider).state.changeWorkspaceLayout();
            context.refresh(workspaceLayoutP);
          },
          child: Icon(
            Icons.workspaces_outline,
            color: Colors.white,
          ),
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
    return Consumer(builder: (context, watch, child) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(color: watch(myColorsP).state["grey"])),
      );
    });
  }

  List<Widget> _buildLayoutWidgets(BuildContext context) {
    return <Widget>[
      Consumer(
        builder: (context, watch, child) {
          final int workspaceLayout = watch(workspaceLayoutP).state;
          if (workspaceLayout == 2) {
            return Container();
          } else {
            return _wrap(_buildBibleChapters(context), 2);
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
      _buildMarvelBibleView(context),
      BibleSearchResults(
          (List<dynamic> data) async => await callBack(context, data)),
      MultipleVerses(
          (List<dynamic> data) async => await callBack(context, data)),
      MultipleVersions(
          (List<dynamic> data) async => await callBack(context, data)),
      WordFeatures(
              (List<dynamic> data) async => await callBack(context, data)),
      LookupContent(
              (List<dynamic> data) async => await callBack(context, data)),
      //TestChart(),
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

  Widget _buildBibleChapters(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final List<String> allChapterList1 = watch(allChapterList1P).state;
      return PageView.builder(
        controller: chaptersPageController,
        itemCount: allChapterList1.length,
        itemBuilder: (BuildContext context, int pageIndex) {
          /*if (index == context.read(currentChapterPageP).state.floor()) {
            // Condition: If the page is the page being swiped from
          } else if (index == context.read(currentChapterPageP).state.floor() + 1) {
            // Condition: If the page is the page being swiped to
          } else {
            // Condition: If the page is a page off screen
          }*/
          return _bible1EachChapterContent(context, pageIndex, allChapterList1[pageIndex]);
        },
        onPageChanged: (int newPageIndex) async {
          final String newChapterBcString = allChapterList1[newPageIndex];
          final List<int> newChapterBcList = [for (String i in newChapterBcString.split(".")) int.parse(i)];

          // Load new chapter data
          // This step must be done before saving history record and updating scroll index.
          await context.read(configProvider).state.onChapterChanged([...newChapterBcList, 1]);

          // Save history record only if book and chapter does not match the latest one.
          final List<int> activeVerse = context.read(configProvider).state.listListIntValues["historyActiveVerse"].first;
          if (activeVerse.sublist(0, 2).join(".") != newChapterBcString) {
            final int firstVerseNo = context.read(configProvider).state.bibleDB1.verseList.first;
            await context.read(configProvider).state.add("historyActiveVerse", [...newChapterBcList, firstVerseNo]);
          } else {
            // The following line is important to update scroll index without saving history record.
            context.read(configProvider).state.updateActiveScrollIndex(activeVerse);
          }

          // Update providers
          context.refresh(historyActiveVerseP);
          context.refresh(activeScrollIndex1P);
          context.refresh(activeScrollIndex2P);
          context.refresh(allChapterData1P);
          context.refresh(chapterData2P);
          context.refresh(menuBookP);
          context.refresh(menuChapterP);
        },
      );
    });
  }

  Widget _bible1EachChapterContent(BuildContext context, int pageIndex, String chapterKey) {
    return Consumer(builder: (context, watch, child) {
      final List<List<dynamic>> chapterData = watch(allChapterData1P).state[chapterKey] ?? [];
      if (chapterData.isEmpty) return Center(child: CircularProgressIndicator(),);
      final bool listeningBible1Chapter = watch(enableParallelChapterScrollingP).state;
      // To ensure verseScrollController1 is attached to the opened chapter and the page is not changing.
      final double currentChapterPage = watch(currentChapterPageP).state;
      final bool listener = (currentChapterPage % 1 == 0) && (currentChapterPage.toInt() == pageIndex);
      if ((!listeningBible1Chapter) || (!listener))
        return _buildEachChapterBibleVerses1(context, chapterData, listener: false);
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
          return _buildEachChapterBibleVerses1(context, chapterData);
        },
      );
    });
  }

  Widget _buildEachChapterBibleVerses1(BuildContext context, List<List<dynamic>> chapterData, {bool listener: true}) {
    return Consumer(
      builder: (context, watch, child) {
        final int activeScrollIndex1 = watch(activeScrollIndex1P).state;
        return ScrollablePositionedList.builder(
          padding: EdgeInsets.zero,
          itemCount: chapterData.length,
          itemBuilder: (context, i) => _buildVerseRow(
              context, i, activeScrollIndex1, chapterData[i],
              listener: listener),
          initialScrollIndex: activeScrollIndex1,
          itemScrollController: (listener) ? verseScrollController1 : null,
          itemPositionsListener: (listener) ? versePositionsListener1 : null,
        );
      },
    );
  }

  // The following three functions were used without PageView
  /*Widget _buildBibleChapter1(BuildContext context) {
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
    return Consumer(builder: (context, watch, child) {
      final bool listeningBible1Chapter =
          watch(enableParallelChapterScrollingP).state;
      if (!listeningBible1Chapter)
        return _buildBibleVerses1(context, listener: false);
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
    });
  }

  Widget _buildBibleVerses1(BuildContext context, {bool listener: true}) {
    return Consumer(
      builder: (context, watch, child) {
        final List<List<dynamic>> chapterData = watch(chapterData1P).state;
        final int activeScrollIndex1 = watch(activeScrollIndex1P).state;
        return ScrollablePositionedList.builder(
          padding: EdgeInsets.zero,
          itemCount: chapterData.length,
          itemBuilder: (context, i) => _buildVerseRow(
              context, i, activeScrollIndex1, chapterData[i],
              listener: listener),
          initialScrollIndex: activeScrollIndex1,
          itemScrollController: verseScrollController1,
          itemPositionsListener: (listener) ? versePositionsListener1 : null,
        );
      },
    );
  }*/

  Widget _bible2ChapterContent(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final bool listeningBible1Chapter =
          watch(enableParallelChapterScrollingP).state;
      if (!listeningBible1Chapter)
        return _buildBibleVerses2(context, listener: false);
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
    });
  }

  Widget _buildBibleVerses2(BuildContext context, {bool listener: true}) {
    return Consumer(
      builder: (context, watch, child) {
        final List<List<dynamic>> chapterData = watch(chapterData2P).state;
        final int activeScrollIndex2 = watch(activeScrollIndex2P).state;
        return ScrollablePositionedList.builder(
          padding: EdgeInsets.zero,
          itemCount: chapterData.length,
          itemBuilder: (context, i) => _buildVerseRow(
              context, i, activeScrollIndex2, chapterData[i],
              listener: listener),
          initialScrollIndex: activeScrollIndex2,
          //initialAlignment: 0.0,
          itemScrollController: verseScrollController2,
          itemPositionsListener: (listener) ? versePositionsListener2 : null,
        );
      },
    );
  }

  Widget _buildTaggedVerseContent(
      BuildContext context,
      List<dynamic> data,
      Map<String, List<TextStyle>> bibleTextStyles,
      bool isActiveVerse,
      String displayVersion,
      {bool listener: true}) {
    final String language =
    context.read(configProvider).state.getBibleLanguage(data);
    final bool isHebrewBible = (language == "he");
    final defaultBibleTextStyle = bibleTextStyles["en"];
    final List<TextStyle> bibleTextStyle =
        bibleTextStyles[language] ?? defaultBibleTextStyle;
    final TextStyle verseStyle =
    (isActiveVerse) ? bibleTextStyle.first : bibleTextStyle.last;

    final String verseNoText = "[${data.first.last}]$displayVersion";
    String verseText = data[1];
    //verseText = TextTransformer.processBibleVerseText(verseText);

    return Consumer(builder: (context, watch, child) {
      final String instantHighlightWord = watch(instantHighlightWordP).state;
      return ParsedText(
        selectable:
        (!listener), //selectable option breaks the listener for parallel scrolling
        textDirection: (isHebrewBible) ? TextDirection.rtl : TextDirection.ltr,
        alignment: (isHebrewBible) ? TextAlign.right : TextAlign.left,
        text: "$verseNoText $verseText",
        style: verseStyle,
        parse: <MatchText>[
          MatchText(
            pattern: r'<(heb|grk) onclick="w\(([0-9]+?,[0-9]+?)\)" onmouseover="iw\(([0-9]+?,[0-9]+?)\)">(.*?)<\/\1>',
            // you must return a map with two keys
            // [display] - the text you want to show to the user
            // [value] - the value underneath it
            renderText: ({String str, String pattern}) {
              Map<String, String> map = Map<String, String>();
              RegExp customRegExp = RegExp(pattern);
              Match match = customRegExp.firstMatch(str);
              map['display'] = match.group(4);
              map['value'] = match.group(2);
              return map;
            },
            onTap: (url) {
              // do something here with passed url
              print(url);
            },
          ),
          MatchText(
            pattern: r'<(heb|grk)>([^<>]*?)<\/\1>',
            // you must return a map with two keys
            // [display] - the text you want to show to the user
            // [value] - the value underneath it
            renderText: ({String str, String pattern}) {
              Map<String, String> map = Map<String, String>();
              RegExp customRegExp = RegExp(pattern);
              Match match = customRegExp.firstMatch(str);
              map['display'] = match.group(2);
              map['value'] = match.group(2);
              return map;
            },
          ),
          MatchText(
            pattern: r"^\[[0-9]+?\]|\[[A-Z][A-Z]+?[a-z]*?[0-9]*?\]",
            style: (isActiveVerse)
                ? bibleTextStyles["verseNo"].first
                : bibleTextStyles["verseNo"].last,
            onTap: (url) async {
              enableParallelChapterScrolling(context);
              await newVerseSelected(context, data.first);
            },
          ),
          if (instantHighlightWord.isNotEmpty)
            MatchText(
              pattern:
              instantHighlightWord, // predefined type can be any of this ParsedTypes
              style: context.read(configProvider).state.myTextStyle[
              "instantHighlight"], // custom style to be applied to this matched text
              onTap: (url) {
                enableParallelChapterScrolling(context);
                context
                    .read(configProvider)
                    .state
                    .speak(url, language: language);
              }, // callback funtion when the text is tapped on
            ),
        ],
      );
    });
  }

  Widget _buildPlainVerseContent(
      BuildContext context,
      List<dynamic> data,
      Map<String, List<TextStyle>> bibleTextStyles,
      bool isActiveVerse,
      String displayVersion,
      {bool listener: true}) {
    final String language =
        context.read(configProvider).state.getBibleLanguage(data);
    final bool isHebrewBible = (language == "he");
    final defaultBibleTextStyle = bibleTextStyles["en"];
    final List<TextStyle> bibleTextStyle =
        bibleTextStyles[language] ?? defaultBibleTextStyle;
    final TextStyle verseStyle =
        (isActiveVerse) ? bibleTextStyle.first : bibleTextStyle.last;

    final String verseNoText = "[${data.first.last}]$displayVersion";
    String verseText = data[1];
    verseText = TextTransformer.processBibleVerseText(verseText);

    return Consumer(builder: (context, watch, child) {
      final String instantHighlightWord = watch(instantHighlightWordP).state;
      return ParsedText(
        selectable:
            (!listener), //selectable option breaks the listener for parallel scrolling
        textDirection: (isHebrewBible) ? TextDirection.rtl : TextDirection.ltr,
        alignment: (isHebrewBible) ? TextAlign.right : TextAlign.left,
        text: "$verseNoText $verseText",
        style: verseStyle,
        parse: <MatchText>[
          MatchText(
            pattern: r"^\[[0-9]+?\]|\[[A-Z][A-Z]+?[a-z]*?[0-9]*?\]",
            style: (isActiveVerse)
                ? bibleTextStyles["verseNo"].first
                : bibleTextStyles["verseNo"].last,
            onTap: (url) async {
              enableParallelChapterScrolling(context);
              await newVerseSelected(context, data.first);
            },
          ),
          if (instantHighlightWord.isNotEmpty)
            MatchText(
              pattern:
              instantHighlightWord, // predefined type can be any of this ParsedTypes
              style: context.read(configProvider).state.myTextStyle[
                  "instantHighlight"], // custom style to be applied to this matched text
              onTap: (url) {
                enableParallelChapterScrolling(context);
                context
                    .read(configProvider)
                    .state
                    .speak(url, language: language);
              }, // callback funtion when the text is tapped on
            ),
          MatchText(
            pattern:
                r"\b([A-Za-z][a-z]*?)\b|([^ ]*?) |[^\w\.\?\[\]\{\}\!\@\#\$\%\^\&\*\(\)\-\+\=\,\:\;\' ]", // a custom pattern to match
            onTap: (String url) async {
              enableParallelChapterScrolling(context);
              context.read(configProvider).state.speak(url, language: language);
              context.read(instantHighlightWordP).state = url.trim();
              // do something here with passed url
            }, // callback function when the text is tapped on
          ),
        ],
      );
    });
  }

  Widget _buildCustomisedVerseContent(
      BuildContext context,
      List<dynamic> data,
      Map<String, List<TextStyle>> bibleTextStyles,
      bool isActiveVerse,
      String displayVersion,
      {bool listener: true}) {
    final String language =
    context.read(configProvider).state.getBibleLanguage(data);
    final bool isHebrewBible = (language == "he");
    final TextDirection textDirection =
    (isHebrewBible) ? TextDirection.rtl : TextDirection.ltr;
    final String verseNoText = "[${data.first.last}]$displayVersion";
    final String verseText = data[1];
    final List<String> clauses = verseText.split("＠");
    return Consumer(builder: (context, watch, child) {
      final Map<String, bool> customInterlinear = watch(customInterlinearP).state;
      final Map<String, Color> myColors = watch(myColorsP).state;
      return (!customInterlinear["clauseBoundaries"]) ? _buildCustomisedVerseContentClause(context, [data.first, verseText.replaceAll("＠", "｜"), data.last], bibleTextStyles, isActiveVerse, displayVersion, customInterlinear, listener: listener, verseNoText: verseNoText) : Wrap(
        textDirection: textDirection,
        spacing: 1.0,
        runSpacing: 1.0,
        children: <Widget>[
          ParsedText(
            selectable:
            (!listener), //selectable option breaks the listener for parallel scrolling
            textDirection:
            (isHebrewBible) ? TextDirection.rtl : TextDirection.ltr,
            alignment: (isHebrewBible) ? TextAlign.right : TextAlign.left,
            text: verseNoText,
            style: bibleTextStyles["en"].last,
            parse: <MatchText>[
              MatchText(
                pattern: r"\[[0-9]+?\]|\[[A-Z][A-Z]+?[a-z]*?[0-9]*?\]",
                style: (isActiveVerse)
                    ? bibleTextStyles["verseNo"].first
                    : bibleTextStyles["verseNo"].last,
                onTap: (url) async {
                  enableParallelChapterScrolling(context);
                  await newVerseSelected(context, data.first);
                },
              ),
            ],
          ),
          ...List<Widget>.generate(
              clauses.length,
                  (index) {
                return OutlinedButton(
                  style: ButtonStyle(
                    side: MaterialStateProperty.resolveWith<BorderSide>(
                          (Set<MaterialState> states) {
                        return BorderSide(
                          color: myColors["grey"],
                        );
                      },
                    ),
                  ),
                  child: _buildCustomisedVerseContentClause(context, [data.first, clauses[index], data.last], bibleTextStyles, isActiveVerse, displayVersion, customInterlinear, listener: listener),
                );
              }
          ),
        ],
      );
    });
  }

  Widget _buildCustomisedVerseContentClause(
      BuildContext context,
      List<dynamic> data,
      Map<String, List<TextStyle>> bibleTextStyles,
      bool isActiveVerse,
      String displayVersion, Map<String, bool> customInterlinear, {bool listener: true, String verseNoText = ""}) {
    final String language =
    context.read(configProvider).state.getBibleLanguage(data);
    final bool isHebrewBible = (language == "he");
    final TextDirection textDirection =
    (isHebrewBible) ? TextDirection.rtl : TextDirection.ltr;
    String verseText = data[1];
    final List<String> wordList = verseText.split("｜");
    List<Widget> customisedWords = List<Widget>.generate(
        wordList.length,
            (index) => _customisedWord(
            context, wordList[index], bibleTextStyles, isActiveVerse, language, customInterlinear, listener: listener));
    return Wrap(
      textDirection: textDirection,
      spacing: 1.0,
      runSpacing: 1.0,
      children: <Widget>[
        if (verseNoText.isNotEmpty) ParsedText(
          selectable:
          (!listener), //selectable option breaks the listener for parallel scrolling
          textDirection:
          (isHebrewBible) ? TextDirection.rtl : TextDirection.ltr,
          alignment: (isHebrewBible) ? TextAlign.right : TextAlign.left,
          text: verseNoText,
          style: bibleTextStyles["en"].last,
          parse: <MatchText>[
            MatchText(
              pattern: r"\[[0-9]+?\]|\[[A-Z][A-Z]+?[a-z]*?[0-9]*?\]",
              style: (isActiveVerse)
                  ? bibleTextStyles["verseNo"].first
                  : bibleTextStyles["verseNo"].last,
              onTap: (url) async {
                enableParallelChapterScrolling(context);
                await newVerseSelected(context, data.first);
              },
            ),
          ],
        ),
        ...customisedWords,
      ],
    );
  }

  Widget _customisedWord(
      BuildContext context,
      String wordText,
      Map<String, List<TextStyle>> bibleTextStyles,
      bool isActiveVerse,
      String language, Map<String, bool> customInterlinear, {bool listener: true}) {
    final bool isHebrewBible = (language == "he");
    final defaultBibleTextStyle = bibleTextStyles["en"];
    final List<TextStyle> bibleTextStyle =
        bibleTextStyles[language] ?? defaultBibleTextStyle;
    final TextStyle mainWordStyle =
    (isActiveVerse) ? bibleTextStyle.first : bibleTextStyle.last;
    return ElevatedButton(
      //padding: EdgeInsets.zero,
      child: ParsedText(
        selectable:
        (!listener), //selectable option breaks the listener for parallel scrolling
        //textDirection: (isHebrewBible) ? TextDirection.rtl : TextDirection.ltr,
        alignment: (isHebrewBible) ? TextAlign.right : TextAlign.left,
        text: wordText,
        style: (isActiveVerse)
            ? defaultBibleTextStyle.first
            : defaultBibleTextStyle.last,
        parse: <MatchText>[
          MatchText(
            pattern: r"<cid>(.*?)</cid><wid>(.*?)</wid><w>(.*?)</w>",
            style: mainWordStyle,
            renderText: ({String str, String pattern}) {
              Map<String, String> map = Map<String, String>();
              RegExp customRegExp = RegExp(pattern);
              Match match = customRegExp.firstMatch(str);
              map['display'] = (customInterlinear["interlinearWord"]) ? match.group(3) : "";
              map['value'] = "${match.group(1)}.${match.group(2)}";
              return map;
            },
            onTap: (url) async {
              enableParallelChapterScrolling(context);
              print(url);
            },
          ),
          MatchText(
            pattern: r"<transliterate>(.*?)</transliterate>",
            style: bibleTextStyles["interlinear2"].last,
            renderText: ({String str, String pattern}) {
              Map<String, String> map = Map<String, String>();
              RegExp customRegExp = RegExp(pattern);
              Match match = customRegExp.firstMatch(str);
              map['display'] = (customInterlinear["interlinearTransliteration"]) ? "\n${match.group(1)}" : "";
              map['value'] = match.group(1);
              return map;
            },
            onTap: (url) async {
              enableParallelChapterScrolling(context);
              print(url);
            },
          ),
          MatchText(
            pattern: r"<pronounce>(.*?)</pronounce>",
            style: bibleTextStyles["interlinear2"].last,
            renderText: ({String str, String pattern}) {
              Map<String, String> map = Map<String, String>();
              RegExp customRegExp = RegExp(pattern);
              Match match = customRegExp.firstMatch(str);
              map['display'] = (customInterlinear["interlinearPronunciation"]) ? "\n${match.group(1)}" : "";
              map['value'] = match.group(1);
              return map;
            },
            onTap: (url) async {
              enableParallelChapterScrolling(context);
              print(url);
            },
          ),
          MatchText(
            pattern: r"<lexeme>(.*?)</lexeme>",
            style: mainWordStyle,
            renderText: ({String str, String pattern}) {
              Map<String, String> map = Map<String, String>();
              RegExp customRegExp = RegExp(pattern);
              Match match = customRegExp.firstMatch(str);
              map['display'] = (customInterlinear["interlinearLexeme"]) ? "\n${match.group(1)}" : "";
              map['value'] = match.group(1);
              return map;
            },
            onTap: (url) async {
              enableParallelChapterScrolling(context);
              print(url);
            },
          ),
          MatchText(
            pattern: r"<lexicon>(.*?)</lexicon>",
            style: bibleTextStyles["interlinear2"].first,
            renderText: ({String str, String pattern}) {
              Map<String, String> map = Map<String, String>();
              RegExp customRegExp = RegExp(pattern);
              Match match = customRegExp.firstMatch(str);
              map['display'] = (customInterlinear["interlinearLexicon"]) ? "\n${match.group(1)}" : "";
              map['value'] = match.group(1);
              return map;
            },
            onTap: (url) async {
              enableParallelChapterScrolling(context);
              print(url);
            },
          ),
          MatchText(
            pattern: r"<gloss>(.*?)</gloss>",
            style: bibleTextStyles["interlinear"].first,
            renderText: ({String str, String pattern}) {
              Map<String, String> map = Map<String, String>();
              RegExp customRegExp = RegExp(pattern);
              Match match = customRegExp.firstMatch(str);
              map['display'] = (customInterlinear["interlinearGloss"]) ? "\n${match.group(1)}" : "";
              map['value'] = match.group(1);
              return map;
            },
            onTap: (url) async {
              enableParallelChapterScrolling(context);
              print(url);
            },
          ),
          MatchText(
            pattern: r"<morphCode>(.*?)</morphCode><morph>(.*?)</morph>",
            style: bibleTextStyles["interlinear2"].first,
            renderText: ({String str, String pattern}) {
              Map<String, String> map = Map<String, String>();
              RegExp customRegExp = RegExp(pattern);
              Match match = customRegExp.firstMatch(str);
              map['display'] = (customInterlinear["interlinearMorphology"]) ? "\n${match.group(1)}" : "";
              map['value'] = match.group(2);
              return map;
            },
            onTap: (url) async {
              enableParallelChapterScrolling(context);
              print(url);
            },
          ),
          MatchText(
            pattern: r"<literal>(.*?)</literal>",
            style: bibleTextStyles["interlinear"].last,
            renderText: ({String str, String pattern}) {
              Map<String, String> map = Map<String, String>();
              RegExp customRegExp = RegExp(pattern);
              Match match = customRegExp.firstMatch(str);
              map['display'] = (customInterlinear["interlinearLiteral"]) ? "\n${match.group(1)}" : "";
              map['value'] = match.group(1);
              return map;
            },
            onTap: (url) async {
              enableParallelChapterScrolling(context);
              print(url);
            },
          ),
          MatchText(
            pattern: r"<smooth>(.*?)</smooth>",
            style: bibleTextStyles["interlinear"].first,
            renderText: ({String str, String pattern}) {
              Map<String, String> map = Map<String, String>();
              RegExp customRegExp = RegExp(pattern);
              Match match = customRegExp.firstMatch(str);
              map['display'] = (customInterlinear["interlinearSmooth"]) ? "\n${match.group(1)}" : "";
              map['value'] = match.group(1);
              return map;
            },
            onTap: (url) async {
              enableParallelChapterScrolling(context);
              print(url);
            },
          ),
        ],
      ),
      style: ButtonStyle(
        elevation: MaterialStateProperty.resolveWith<double>(
              (Set<MaterialState> states) {
            return 0;
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Colors.lightBlue[50];
          },
        ),
      ),
      //color: Colors.lightBlue[50],
      //disabledColor: Colors.lightBlue[50],
      //elevation: 0,
      onPressed: () {
        enableParallelChapterScrolling(context);
      },
    );
  }

  Widget _buildInterlinearVerseContent(
      BuildContext context,
      List<dynamic> data,
      Map<String, List<TextStyle>> bibleTextStyles,
      bool isActiveVerse,
      String displayVersion,
      {bool listener: true}) {
    final String language =
        context.read(configProvider).state.getBibleLanguage(data);
    final bool isHebrewBible = (language == "he");
    final TextDirection textDirection =
        (isHebrewBible) ? TextDirection.rtl : TextDirection.ltr;
    final String verseNoText = "[${data.first.last}]$displayVersion";
    String verseText = data[1];
    verseText = verseText.replaceAll("｜＠", "\n");
    final List<String> wordList = verseText.split(" ｜");
    List<Widget> interlinearWords = List<Widget>.generate(
        wordList.length,
        (index) => _interlinearWord(
            context, wordList[index], bibleTextStyles, isActiveVerse, language,
            listener: listener, index: index));
    return Wrap(
      textDirection: textDirection,
      spacing: 1.0,
      runSpacing: 1.0,
      children: <Widget>[
        ParsedText(
          selectable:
              (!listener), //selectable option breaks the listener for parallel scrolling
          textDirection:
              (isHebrewBible) ? TextDirection.rtl : TextDirection.ltr,
          alignment: (isHebrewBible) ? TextAlign.right : TextAlign.left,
          text: verseNoText,
          style: bibleTextStyles["en"].last,
          parse: <MatchText>[
            MatchText(
              pattern: r"\[[0-9]+?\]|\[[A-Z][A-Z]+?[a-z]*?[0-9]*?\]",
              style: (isActiveVerse)
                  ? bibleTextStyles["verseNo"].first
                  : bibleTextStyles["verseNo"].last,
              onTap: (url) async {
                enableParallelChapterScrolling(context);
                await newVerseSelected(context, data.first);
              },
            ),
          ],
        ),
        ...interlinearWords,
      ],
    );
  }
  
  Widget _interlinearWord(
      BuildContext context,
      String wordText,
      Map<String, List<TextStyle>> bibleTextStyles,
      bool isActiveVerse,
      String language,
      {bool listener: true, int index}) {
    final bool isHebrewBible = (language == "he");
    final defaultBibleTextStyle = bibleTextStyles["en"];
    final List<TextStyle> bibleTextStyle =
        bibleTextStyles[language] ?? defaultBibleTextStyle;
    final TextStyle mainWordStyle =
        (isActiveVerse) ? bibleTextStyle.first : bibleTextStyle.last;
    return ElevatedButton(
      //padding: EdgeInsets.zero,
      child: ParsedText(
        selectable:
            (!listener), //selectable option breaks the listener for parallel scrolling
        //textDirection: (isHebrewBible) ? TextDirection.rtl : TextDirection.ltr,
        alignment: (isHebrewBible) ? TextAlign.right : TextAlign.left,
        text: wordText,
        style: (isActiveVerse)
            ? defaultBibleTextStyle.first
            : defaultBibleTextStyle.last,
        parse: <MatchText>[
          MatchText(
            pattern: r"^(.*?)\n",
            style: mainWordStyle,
          ),
          MatchText(
            pattern: r"\b([\w]+?)\b",
            style: bibleTextStyles["interlinear"].first,
          ),
          MatchText(
            pattern: r"[\[\]\+]",
            style: bibleTextStyles["interlinear2"].last,
          ),
        ],
      ),
      style: ButtonStyle(
        elevation: MaterialStateProperty.resolveWith<double>(
          (Set<MaterialState> states) {
            return 0;
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.lightBlue[50];
          },
        ),
      ),
      //color: Colors.lightBlue[50],
      //disabledColor: Colors.lightBlue[50],
      //elevation: 0,
      onPressed: () {
        enableParallelChapterScrolling(context);
        if (index != null) print(index);
      },
    );
  }

  Widget _buildVerseRow(
      BuildContext context, int i, int activeScrollIndex, List<dynamic> data,
      {bool listener: true}) {
    final bool isActiveVerse = (i == activeScrollIndex);
    return Consumer(builder: (context, watch, child) {
        final Map<String, List<TextStyle>> bibleTextStyles =
            watch(bibleTextStylesP).state;
        final String displayVersion =
            (context.read(parallelVersesP).state) ? " [${data.last}]" : "";
        final module = data.last;
        final Map<String, Function> verseContent = {
          "i": _buildInterlinearVerseContent,
          "c": _buildCustomisedVerseContent,
          "x": _buildTaggedVerseContent,
        };
        final Function verseContentFunction = verseContent[module[module.length - 1]] ?? _buildPlainVerseContent;
        return ListTile(
          title: verseContentFunction(context, data, bibleTextStyles, isActiveVerse, displayVersion, listener: listener),
          //onTap: () => enableParallelChapterScrolling(context),
          onLongPress: () => disableParallelChapterScrolling(context),
        );
      },
    );
  }

  void enableParallelChapterScrolling(BuildContext context) {
    final bool enableParallelChapterScrolling =
        context.read(enableParallelChapterScrollingP).state;
    if (!enableParallelChapterScrolling)
      context.read(enableParallelChapterScrollingP).state = true;
  }

  void disableParallelChapterScrolling(BuildContext context) {
    final bool enableParallelChapterScrolling =
        context.read(enableParallelChapterScrollingP).state;
    if (enableParallelChapterScrolling)
      context.read(enableParallelChapterScrollingP).state = false;
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

  /*Future<void> goNextChapter(BuildContext context) async {
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
  }*/

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
      "changeBible1Version": changeBible1Version,
      "changeBible2Version": changeBible2Version,
      "searchBible": searchBible,
      "loadMultipleVerses": loadMultipleVerses,
      "loadMultipleVersions": loadMultipleVersions,
      "speak": speak,
      "lexicon": lexicon,
      "dictionary": dictionary,
      "encyclopedia": encyclopedia,
      "generalDictionary": generalDictionary,
      "marvelBible": syncMarvelBible,
      "scrollToBibleVerse": scrollToBibleVerse, // non-future function
    };
    (data.last.isEmpty)
        ? actions[data.first](context)
        : await actions[data.first](context, data.last);
  }

  void speak(BuildContext context, String data) {
    context.read(configProvider).state.speak(data, language: (RegExp("a-zA-Z").hasMatch(data)) ? "en" : "zh");
  }

  Future<void> lexicon(BuildContext context, List<String> moduleEntry) async {
    print(moduleEntry);
  }

  Future<void> dictionary(BuildContext context, List<String> moduleEntry) async {
    print(moduleEntry);
  }

  Future<void> encyclopedia(BuildContext context, List<String> moduleEntry) async {
    print(moduleEntry);
  }

  Future<void> generalDictionary(BuildContext context, List<String> moduleEntry) async {
    final FileMx fileMx = context.read(fileMxP).state;
    final String filename = context.read(configProvider).state.allGeneralDictionaries[moduleEntry.first];
    final String sqlStatementExact = "SELECT word, data FROM dictionary WHERE word = ?";
    final List<Map<String, dynamic>> exactMatch = await fileMx.querySqliteDB("FULLPATH", filename, sqlStatementExact, [moduleEntry.last]);
    final String sqlStatementPartial = "SELECT word, data FROM dictionary WHERE word LIKE ? AND word != ?";
    final List<Map<String, dynamic>> partialMatches = await fileMx.querySqliteDB("FULLPATH", filename, sqlStatementPartial, ["%${moduleEntry.last}%", moduleEntry.last]);
    final List<Map<String, dynamic>> allMatches = [if (exactMatch.isNotEmpty) ...exactMatch, if (partialMatches.isNotEmpty) ...partialMatches];
    context.read(lookupMatchesP).state = allMatches;
  }

  Future<void> newVersionVerseSelected(
      BuildContext context, List<dynamic> data) async {
    final String module = data.last;
    final String activeModule = context.read(bible1P).state;
    if (module != activeModule) await changeBible1Version(context, module);
    final List<int> bcvList = [for (int i in data.first) i];
    await newVerseSelected(context, bcvList);
  }

  Future<void> newVerseSelected(BuildContext context, List<dynamic> bcvList) async {
    final List<int> activeVerse = context.read(configProvider).state.listListIntValues["historyActiveVerse"].first;

    // Check if same as the last active verse.
    if (bcvList.sublist(0, 3).join(".") != activeVerse.sublist(0, 3).join(".")) {

      // Save active verse
      await context.read(configProvider).state.add("historyActiveVerse", bcvList);

      // Check if on the same chapter
      if (bcvList.sublist(0, 2).join(".") != activeVerse.sublist(0, 2).join(".")) {
        // Scroll to the right page to open a new chapter.
        final List<String> allChapterList1 = context.read(allChapterList1P).state;
        final int chapterIndex = allChapterList1.indexOf("${bcvList.first}.${bcvList[1]}");
        chaptersPageController.jumpToPage((chapterIndex == -1) ? 0 : chapterIndex);
      } else {
        context.refresh(historyActiveVerseP);
        context.refresh(activeScrollIndex1P);
        context.refresh(activeScrollIndex2P);
        context.refresh(menuBookP);
        context.refresh(menuChapterP);
        scrollToBibleVerse(context);
      }
    }
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
      context.read(configProvider).state.updateDisplayChapterData(activeVerse);
      context.read(configProvider).state.updateActiveScrollIndex(activeVerse);
      switch (whichBible) {
        case 1:
          context.refresh(bible1P);
          context.refresh(allChapterData1P);
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

  Future<void> searchBible(BuildContext context, List<dynamic> data) async {
    await changeWorkspaceTab(context, 1);

    final int searchEntryOption = context.read(searchEntryOptionP).state;
    final bool searchWholeBible = context.read(searchWholeBibleP).state;
    List<int> filter = (searchWholeBible)
        ? []
        : context.read(bibleSearchBookFilterP).state.toList()
      ..sort();
    await context
        .read(configProvider)
        .state
        .updateSearchBibleDB(context, module: data.last);
    final Bible targetSearchBible =
        context.read(configProvider).state.searchBibleDB;
    await targetSearchBible.searchMultipleBooks(data.first, searchEntryOption,
        filter: filter, exclusion: data[1]);

    // Draw parallel verses if parallel feature for search result is enabled.
    Map<int, List<List<dynamic>>> lastBibleSearchResultsParallel = {};
    if (context.read(enableParallelSearchResultsP).state) {
      final Bible bible2 = context.read(configProvider).state.bibleDB2;
      for (MapEntry mi in targetSearchBible.lastBibleSearchResults.entries) {
        final List<List<dynamic>> newData2 = [];
        for (List<dynamic> li in mi.value) {
          List<dynamic> parallelData =
              await bible2.getVerseData([for (int i in li.first) i]);
          newData2.add((parallelData.isNotEmpty)
              ? parallelData
              : [li.first, "", bible2.module]);
        }
        lastBibleSearchResultsParallel[mi.key] = newData2;
      }
    }
    context
        .read(configProvider)
        .state
        .updateLastBibleSearchResultsParallel(lastBibleSearchResultsParallel);

    context.refresh(bibleSearchDataP);
  }

  Future<void> loadMultipleVerses(
      BuildContext context, List<dynamic> data) async {
    // Remove empty item .removeWhere((i) => i.isEmpty);
    final Bible bible1 = context.read(configProvider).state.bibleDB1;
    final List<List<dynamic>> newData1 = [
      for (List<dynamic> item in data) await bible1.getVerseData(item)
    ]..removeWhere((i) => (i).isEmpty);

    // Draw parallel verses if parallel feature for multiple display is enabled.
    final List<List<dynamic>> newData2 = [];
    if (context.read(enableParallelMultipleVersesP).state) {
      final Bible bible2 = context.read(configProvider).state.bibleDB2;
      for (List<dynamic> i in newData1) {
        List<dynamic> parallelData =
            await bible2.getVerseData([for (int i in i.first) i]);
        newData2.add((parallelData.isNotEmpty)
            ? parallelData
            : [i.first, "", bible2.module]);
      }
    }

    final BibleParser parser = context.read(parserP).state;
    final String references = [
      for (List<dynamic> i in data) parser.bcvToVerseReference(i)
    ].join("; ");

    context
        .read(configProvider)
        .state
        .updateMultipleVersesData(newData1, newData2, references);
    context.refresh(multipleVersesP);
  }

  Future<void> loadMultipleVersions(
      BuildContext context, List<dynamic> data) async {
    final FileMx fileMx = context.read(fileMxP).state;
    final List<String> compareBibleList = context.read(compareBibleListP).state
      ..sort();
    final Map<String, List<String>> allBibles =
        context.read(configProvider).state.allBibles;
    final List<String> allBibleList = allBibles.keys.toList();
    final List<int> firstReference = data.first.first;
    List<List<dynamic>> verseData = [];
    for (String module in compareBibleList) {
      if (allBibleList.contains(module)) {
        final Bible bible = Bible(module, allBibles[module].last, fileMx);
        await bible.openDatabase();
        verseData.add(await bible.getVerseData(firstReference));
        bible.db.close();
      }
    }

    String references = "";
    if (data.last) {
      final BibleParser parser = context.read(parserP).state;
      references = [
        for (List<dynamic> i in data.first) parser.bcvToVerseReference(i)
      ].join("; ");
    }

    verseData = verseData..removeWhere((i) => (i).isEmpty);
    context
        .read(configProvider)
        .state
        .updateMultipleVersions(verseData, references: references);
    context.refresh(multipleVersionsP);
  }

  // Functions to work with WebView

  void syncMarvelBible(BuildContext context) {
    final List<int> activeVerse = context.read(historyActiveVerseP).state.first;
    final Map<String, List<String>> allBibles = context.read(configProvider).state.allBibles;
    final String module = "MAB";
    final FileMx fileMx = context.read(fileMxP).state;
    Bible(module, allBibles[module].last, fileMx).getFormattedChapterString(activeVerse).then((content) => context.read(marvelBibleContentP).state = content);
  }

  Widget _buildMarvelBibleView(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final List<int> activeVerse = context.read(historyActiveVerseP).state.first;
      final bool rtl = (activeVerse.first < 40) ? true : false;
      final String content = watch(marvelBibleContentP).state;
      final Map<String, Color> myColors = watch(myColorsP).state;
      final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
      final double fontSize = watch(fontSizeP).state;
      return WebView(
        initialUrl: _buildHtmlContent(context, content, myColors, myTextStyle, fontSize, rtl: rtl),
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: <JavascriptChannel>[
          HtmlElements.ubaJsChannel(),
        ].toSet(),
        onWebViewCreated: (WebViewController webViewController) => _webViewController = webViewController,
        gestureRecognizers: Set()
          ..addAll({
            Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
            Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
          }),
      );
    });
  }

  String _buildHtmlContent(BuildContext context, String content, Map<String, Color> myColors, Map<String, TextStyle> myTextStyle, double fontSize, {bool rtl = false}) {

    final String backgroundColor = myColors["background"].toHex();
    final String fontColor = myColors["black"].toHex();

    final List<int> bcvList = context.read(historyActiveVerseP).state.first;
    final String activeBcvSettings = "var activeText = 'KJV'; var activeB = ${bcvList.first}; var activeC = ${bcvList[1]}; var activeV = ${bcvList[2]};";

    final fullContent = """
<!DOCTYPE html><html>
<head><title>UniqueBible.app</title>
<style>
body { font-size: ${fontSize}px; background-color: $backgroundColor; color: $fontColor; } 
@font-face { font-family: 'KoineGreek'; src: url(${FontUri.koineGreekttf}); } 
@font-face { font-family: 'Ezra SIL'; src: url(${FontUri.sileotttf}); } 
</style>
<style>${HtmlElements.defaultCss}</style>
<script>${HtmlElements.defaultJs}</script>
<script>${HtmlElements.w3Js}</script>
<script>$activeBcvSettings</script>
<script>
var versionList = []; 
var compareList = []; 
var parallelList = []; 
var diffList = []; 
var searchList = [];
</script>
</head>
<body>
<span id='v0.0.0'></span>
${rtl ? "<div style='direction: rtl;'>" : "<div>"}
$content
</div>
</body>
</html>
    """;

    return Uri.dataFromString(fullContent, mimeType: 'text/html', encoding: utf8).toString();
  }

  void webViewScrollToBcv(BuildContext context, WebViewController webViewController, {List<int> bcvList = const []}) {
    if (bcvList.isEmpty) bcvList = context.read(historyActiveVerseP).state.first;
    final String js = "var activeVerse = document.getElementById('v${bcvList.first}.${bcvList[1]}.${bcvList[2]}'); "
        "if (typeof(activeVerse) != 'undefined' && activeVerse != null) { "
        "activeVerse.scrollIntoView(); activeVerse.style.color = 'red'; } "
        "else { document.getElementById('v0.0.0').scrollIntoView(); }";
    webViewController?.evaluateJavascript(js);
  }

}
