import 'package:flutter/material.dart';

class Screen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
          ),
        ),
        title: Text("Back to Screen 1"),
      ),
      body: Center(
        child: InkWell(
          child: Text(
            'Screen 2 ',
          ),
        ),
      ),
    );
  }
}