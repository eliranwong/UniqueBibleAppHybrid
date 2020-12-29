// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// My libraries
import 'config.dart';

class Workspace extends StatelessWidget {

  final Function onCallBack;

  Workspace(this.onCallBack);

  @override
  Widget build(BuildContext context) {
    return _dummyWidget("Workspace HERE!");
  }

  Widget _dummyWidget(String message) {
    return Center(child: Text(message));
  }

}