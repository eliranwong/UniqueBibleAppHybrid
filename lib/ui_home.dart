// Packages
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Core libraries
import 'dart:io';
// My libraries
import 'config.dart';
import 'app_translation.dart';

class UiHome extends HookWidget {

  // A global key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // To work with riverpod
  //final Config config = useProvider(configProvider);
  //final Configurations configState = useProvider(configProvider.state);
  //AsyncValue<Configurations> config = useProvider(configProvider);
  //Configurations configState;

  final configState = useProvider(configProvider).state;

  // variable to work with translations
  String abbreviations;
  final Map<String, List<String>> interfaceApp = AppTranslation().interfaceApp,
      interfaceBottom = AppTranslation().interfaceBottom,
      interfaceMessage = AppTranslation().interfaceMessage,
      interfaceDialog = AppTranslation().interfaceDialog,
      interfaceBibleSearch = AppTranslation().interfaceBibleSearch;

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
    print("main builder here");
    return Theme(
      data: ThemeData(
        unselectedWidgetColor: configState.myColors["blue"],
      ),
      child: Scaffold(
        key: _scaffoldKey,
        //drawer: (configState.boolValues["bigScreen"]) ? null : _buildDrawer(),
        appBar: _buildAppBar(context),
        body: Container(
          color: configState.backgroundColor,
          child: _buildLayout(context),
        ),
        bottomNavigationBar: _buildBottomAppBar(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  // Required by build function: _buildDrawer(), _buildAppBar(context), _buildLayout(context), _buildBottomAppBar(context), _buildFloatingActionButton()
  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: configState.floatingButtonColor,
      onPressed: () {
        print("Floating button pressed!");
      },
      //tooltip: interfaceApp[abbreviations][5],
      child: Icon(Icons.add),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    //original color: Theme.of(context).appBarTheme.color
    //List<PopupMenuEntry<String>> popupMenu = _appBarPopupMenu();
    //if (!configState.bigScreen) popupMenu.removeAt(3);
    return AppBar(
      backgroundColor: configState.appBarColor,
      title: Text(interfaceApp[abbreviations].first),
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            tooltip: interfaceApp[abbreviations][1],
            icon: const Icon(Icons.menu),
            onPressed: () {
              print("navigation button pressed.");
              print(configState.boolValues["showDrawer"]);
              if (configState.boolValues["bigScreen"]) {
                print("navigation button's action triggered.");
                configState.save("showDrawer", !context.read(showDrawerP).state);
                context.refresh(showDrawerP);
                print(configState.boolValues["showDrawer"]);
              } else {
                _scaffoldKey.currentState.openDrawer();
              }
            },
          );
        },
      ),
      actions: <Widget>[
        IconButton(
          tooltip: interfaceApp[abbreviations][3],
          icon: const Icon(Icons.swap_calls),
          onPressed: () {
            print("switch button pressed");
          },
        ),
      ],
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      // Container placed here is necessary for controlling the height of the ListView.
      child: Container(
        padding: EdgeInsets.only(right: 84.0),
        height: 48,
        color: configState.bottomAppBarColor,
        child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
        ]),
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    /*if (configState.boolValues["bigScreen"]) {
      //
    }
    return _buildBibleChapter(context);*/

    return Row(
      children: <Widget>[
        //(configState.boolValues["showDrawer"]) ? _buildTabletDrawer() : Container(),
        Consumer(
          // Rebuild only the Text when counterProvider updates
          builder: (context, watch, child) {
            // Listens to the value exposed by counterProvider
            final bool showDrawer = watch(showDrawerP).state;
            return (showDrawer) ? Center(child: Text("FOR TESTING ONLY!")) : Container();
          },
        ),
        (configState.boolValues["showDrawer"]) ? _buildDivider() : Container(),
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
      _wrap(_buildBibleChapter(context), 2),
      //(_display) ? _buildDivider() : Container(),
      //(_display) ? _wrap(_buildWorkspace(context), 2) : Container(),
    ];
  }

  Widget _dummyWidget() {
    return Center(child: Text("FOR TESTING ONLY!"));
  }

  Widget _buildTabletDrawer() {
    return _dummyWidget();
  }

  Widget _buildBibleChapter(BuildContext context) {
    return _dummyWidget();
  }

}
