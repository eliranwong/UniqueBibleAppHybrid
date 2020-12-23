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
// ui
import 'ui_home_bottom_app_bar.dart';
import 'ui_home_top_app_bar.dart';

class UiHome extends HookWidget {

  // A global key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // To work with riverpod
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
    return Theme(
      data: ThemeData(
        unselectedWidgetColor: configState.myColors["blue"],
      ),
      child: Scaffold(
        key: _scaffoldKey,
        //drawer: (configState.boolValues["bigScreen"]) ? null : _buildDrawer(),
        appBar: HomeTopAppBar(context, abbreviations).buildTopAppBar(),
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
    /*if (configState.boolValues["bigScreen"]) {
      //
    }
    return _buildBibleChapter(context);*/

    return Row(
      children: <Widget>[
        Consumer(
          builder: (context, watch, child) {
            final bool showDrawer = watch(showDrawerP).state;
            return (showDrawer) ? _buildTabletDrawer() : Container();
          },
        ),
        Consumer(
          builder: (context, watch, child) {
            final bool showDrawer = watch(showDrawerP).state;
            return (showDrawer) ? _buildDivider() : Container();
          },
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
      _wrap(_buildBibleChapter(context), 2),
      //(_display) ? _buildDivider() : Container(),
      //(_display) ? _wrap(_buildWorkspace(context), 2) : Container(),
    ];
  }

  Widget _dummyWidget() {
    return Center(child: Text("TESTING!"));
  }

  Widget _buildTabletDrawer() {
    return _dummyWidget();
  }

  Widget _buildBibleChapter(BuildContext context) {
    return _dummyWidget();
  }

}
