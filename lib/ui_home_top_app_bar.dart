import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'config.dart';
import 'app_translation.dart';

class HomeTopAppBar {

  final configState = useProvider(configProvider).state;
  final Map<String, List<String>> interfaceApp = AppTranslation().interfaceApp;

  final BuildContext context;
  final String abbreviations;
  HomeTopAppBar(this.context, this.abbreviations);

  Widget buildTopAppBar() {
    //original color: Theme.of(context).appBarTheme.color
    //List<PopupMenuEntry<String>> popupMenu = _appBarPopupMenu();
    //if (!configState.bigScreen) popupMenu.removeAt(3);
    return AppBar(
      backgroundColor: configState.myColors["appBarColor"],
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
                // open drawer for small screen users
                //_scaffoldKey.currentState.openDrawer();
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

}