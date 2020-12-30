// Packages
import 'package:flutter/material.dart';

class Workspace {

  final Function onCallBack;

  Workspace(this.onCallBack);

  Widget dummyWidget(String message) {
    return Center(child: Text(message));
  }

}