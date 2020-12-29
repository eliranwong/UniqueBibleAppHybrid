// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// My libraries
import 'config.dart';

class BibleDrawer extends StatelessWidget {

  final Function onCallBack;

  BibleDrawer(this.onCallBack);

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
          title: Text('Unique Bible App'),
        ),
        body: TabBarView(
          children: [
            _buildDrawerTab1(context),
            _buildDrawerTab2(context),
            Icon(Icons.search),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTab1(BuildContext context) {
    return ListView(
      //padding
      children: <Widget>[
        _buildVerseReferenceField(context),
      ],
    );
  }

  Widget _buildVerseReferenceField(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String activeVerseReference = watch(activeVerseReferenceP).state;
        return TextField(
          decoration: InputDecoration.collapsed(hintText: activeVerseReference, hintStyle: myTextStyle["activeVerseFont"]),
          onSubmitted: (String value) async {
            final List<List<dynamic>> references = context.read(parserP).state.extractAllReferences(value);
            await context.read(configProvider).state.newVerseSelected(references.first);
            context.refresh(chapterDataP);
            context.refresh(historyActiveVerseP);
            context.refresh(activeVerseReferenceP);
            context.refresh(activeScrollIndexP);
            onCallBack(["scroll", context.read(activeScrollIndexP).state]);
            if (!context.read(keepDrawerOpenP).state) {
              context.read(configProvider).state.save("showDrawer", !context.read(showDrawerP).state);
              context.refresh(showDrawerP);
            }
          },
          //onChanged: ,
          //onTap: ,
          //onEditingComplete: ,
        );
      },
    );
  }

  Widget _buildDrawerTab2(BuildContext context) {
    return ListView(
      //padding
      children: <Widget>[
        _buildBookVersionField(context),
      ],
    );
  }

  Widget _buildBookVersionField(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String bible1 = watch(bible1P).state;
        return TextField(
          decoration: InputDecoration.collapsed(hintText: bible1, hintStyle: myTextStyle["activeVerseFont"]),
          onSubmitted: (String value) async {
            final List<String> allBiblesList = context.read(configProvider).state.allBibles.keys.toList();
            final List<int> activeVerse = context.read(configProvider).state.listListIntValues["historyActiveVerse"].first;
            if (allBiblesList.contains(value)) {
              await context.read(configProvider).state.openBibleDB1(module: value);
              await context.read(configProvider).state.bibleDB1.updateBCVMenu(activeVerse);
              await context.read(configProvider).state.bibleDB1.updateChapterData(activeVerse);
              context.read(configProvider).state.updateActiveScrollIndex(activeVerse);
              context.read(configProvider).state.updateDisplayChapterData();
              context.refresh(bible1P);
              context.refresh(chapterDataP);
              context.refresh(activeScrollIndexP);
              if (!context.read(keepDrawerOpenP).state) {
                context.read(configProvider).state.save("showDrawer", !context.read(showDrawerP).state);
                context.refresh(showDrawerP);
              }
            }
          },
          //onChanged: ,
          //onTap: ,
          //onEditingComplete: ,
        );
      },
    );
  }

}
