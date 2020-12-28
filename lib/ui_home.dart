// Packages
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// Core libraries
import 'dart:io';
// My libraries
import 'config.dart';
import 'app_translation.dart';
// ui
import 'ui_home_bottom_app_bar.dart';
import 'ui_home_top_app_bar.dart';
//testing

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
          title: Text(interfaceApp[useProvider(abbreviationsP).state].first),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                tooltip: interfaceApp[configState.stringValues["abbreviations"]][1],
                icon: const Icon(Icons.menu),
                onPressed: () {
                  configState.save("showDrawer", !context.read(showDrawerP).state);
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
            print("Floating button pressed!");
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
              (watch(showDrawerP).state) ? _buildTabletDrawer() : Container(),
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
      Consumer(
        builder: (context, watch, child) {
          final int workspaceLayout = watch(workspaceLayoutP).state;
          if (workspaceLayout == 0) {
            return Container();
          } else {
            return _wrap(_buildWorkspace(context), 2);
          }
        },
      ),
    ];
  }

  Widget _dummyWidget(String message) {
    return Center(child: Text(message));
  }

  Widget _buildTabletDrawer() {
    return SizedBox(
      width: 250,
      child: BibleDrawer(),
    );
  }

  Widget _buildBibleChapter(BuildContext context) {
    verseScrollController = ItemScrollController();
    versePositionsListener = ItemPositionsListener.create();
    return Consumer(
      builder: (context, watch, child) {
        final List<List<dynamic>> chapterData = watch(chapterDataP).state;
        final int activeScrollIndex = watch(activeScrollIndexP).state;
        return ScrollablePositionedList.builder(
          padding: EdgeInsets.zero,
          itemCount: chapterData.length,
          itemBuilder: (context, i) => _buildVerseRow(context, i, activeScrollIndex, chapterData[i]),
          initialScrollIndex: activeScrollIndex,
          //initialAlignment: 0.0,
          itemScrollController: verseScrollController,
          itemPositionsListener: versePositionsListener,
        );
      },
    );
  }

  Widget _buildVerseRow(BuildContext context, int i, int activeScrollIndex, List<dynamic> data) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        TextStyle verseStyle = (i == activeScrollIndex) ? myTextStyle["activeVerseFont"] : myTextStyle["verseFont"];
        return ListTile(
          title: Text(data[1], style: verseStyle,),
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
          onTap: () {
            print("tap");
          },
          onLongPress: () {
            print("long press");
            //_longPressedActiveVerse(context, _data[i]);
          },
        );
      },
    );
  }

  Widget _buildWorkspace(BuildContext context) {
    return _dummyWidget("Workspace HERE!");
  }

}

class BibleDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 48, // 48 is minimum height to height the title
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.account_tree_outlined)),
              Tab(icon: Icon(Icons.apps)),
              Tab(icon: Icon(Icons.search)),
            ],
          ),
          title: Text('Tabs Demo'),
        ),
        body: TabBarView(
          children: [
            Icon(Icons.account_tree_outlined),
            Icon(Icons.apps),
            Icon(Icons.search),
          ],
        ),
      ),
    );
  }
}

