import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'config.dart';

class HomeBottomAppBar {

  final configState = useProvider(configProvider).state;
  final BuildContext context;
  HomeBottomAppBar(this.context);

  Widget buildBottomAppBar() {
    return BottomAppBar(
      // Container placed here is necessary for controlling the height of the ListView.
      child: Container(
        padding: EdgeInsets.only(right: 84.0),
        height: 48,
        color: configState.myColors["bottomAppBarColor"],
        child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
          //
        ]),
      ),
    );
  }

}