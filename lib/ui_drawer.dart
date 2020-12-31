// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// My libraries
import 'config.dart';

class BibleDrawer extends StatelessWidget {

  final Function callBack;

  BibleDrawer(this.callBack);

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
            _buildDrawerTab3(context),
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

  Widget _buildDrawerTab2(BuildContext context) {
    return ListView(
      //padding
      children: <Widget>[
        _buildBookVersionField1(context),
        _buildBookVersionField2(context),
      ],
    );
  }

  Widget _buildDrawerTab3(BuildContext context) {
    return ListView(
      //padding
      children: <Widget>[
        _buildSearchBibleField(context),
      ],
    );
  }

  Widget _buildSearchBibleField(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String lastBibleSearchEntry = watch(lastBibleSearchEntryP).state;
        return TextField(
          decoration: InputDecoration.collapsed(hintText: lastBibleSearchEntry, hintStyle: myTextStyle["activeVerseFont"]),
          onSubmitted: (String value) async {
            if (value != lastBibleSearchEntry) {
              await context.read(configProvider).state.bibleDB1.searchMultipleBooks(value);
              context.refresh(lastBibleSearchHitP);
              context.refresh(lastBibleSearchEntryP);
              context.refresh(lastBibleSearchResultsP);
              _completeDrawerAction(context);
            }
          },
          //onChanged: ,
          //onTap: ,
          //onEditingComplete: ,
        );
      },
    );
  }

  Widget _buildVerseReferenceField(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String activeVerseReference = watch(activeVerseReferenceP).state;
        final List<int> activeVerse = context.read(configProvider).state.listListIntValues["historyActiveVerse"].first;
        return TextField(
          decoration: InputDecoration.collapsed(hintText: activeVerseReference, hintStyle: myTextStyle["activeVerseFont"]),
          onSubmitted: (String value) async {
            final List<List<dynamic>> references = context.read(parserP).state.extractAllReferences(value);
            if (references.first.join(".") != activeVerse.join(".")) {
              await context.read(configProvider).state.newVerseSelected(references.first);
              refreshProvidersOnNewChapter(context);
              _completeDrawerAction(context);
            }
          },
          //onChanged: ,
          //onTap: ,
          //onEditingComplete: ,
        );
      },
    );
  }

  Widget _buildBookVersionField1(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String bible1 = watch(bible1P).state;
        return TextField(
          decoration: InputDecoration.collapsed(hintText: bible1, hintStyle: myTextStyle["activeVerseFont"]),
          onSubmitted: (String value) async {
            if (value != bible1) await _changeBible1Version(context, value);
          },
          //onChanged: ,
          //onTap: ,
          //onEditingComplete: ,
        );
      },
    );
  }

  Widget _buildBookVersionField2(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String bible2 = watch(bible2P).state;
        return TextField(
          decoration: InputDecoration.collapsed(hintText: bible2, hintStyle: myTextStyle["activeVerseFont"]),
          onSubmitted: (String value) async {
            if (value != bible2) await _changeBible2Version(context, value);
          },
          //onChanged: ,
          //onTap: ,
          //onEditingComplete: ,
        );
      },
    );
  }

  Future<void> _changeBible1Version(BuildContext context, String module) async {
    final List<String> allBiblesList = context.read(configProvider).state.allBibles.keys.toList();
    final List<int> activeVerse = context.read(configProvider).state.listListIntValues["historyActiveVerse"].first;
    if (allBiblesList.contains(module)) {
      await context.read(configProvider).state.openBibleDB1(module: module);
      await context.read(configProvider).state.bibleDB1.updateBCVMenu(activeVerse);
      await context.read(configProvider).state.bibleDB1.updateChapterData(activeVerse);
      context.read(configProvider).state.updateActiveScrollIndex(activeVerse);
      context.read(configProvider).state.updateDisplayChapterData();
      context.refresh(bible1P);
      context.refresh(chapterData1P);
      context.refresh(activeScrollIndex1P);
      _completeDrawerAction(context);
    }
  }

  Future<void> _changeBible2Version(BuildContext context, String module) async {
    final List<String> allBiblesList = context.read(configProvider).state.allBibles.keys.toList();
    final List<int> activeVerse = context.read(configProvider).state.listListIntValues["historyActiveVerse"].first;
    if (allBiblesList.contains(module)) {
      await context.read(configProvider).state.openBibleDB2(module: module);
      await context.read(configProvider).state.bibleDB2.updateBCVMenu(activeVerse);
      await context.read(configProvider).state.bibleDB2.updateChapterData(activeVerse);
      context.read(configProvider).state.updateActiveScrollIndex(activeVerse);
      context.read(configProvider).state.updateDisplayChapterData();
      context.refresh(bible2P);
      context.refresh(chapterData2P);
      context.refresh(activeScrollIndex2P);
      _completeDrawerAction(context);
    }
  }

  void refreshProvidersOnNewChapter(BuildContext context) {
    context.refresh(chapterData1P);
    context.refresh(chapterData2P);
    context.refresh(historyActiveVerseP);
    context.refresh(activeVerseReferenceP);
    context.refresh(activeScrollIndex1P);
    context.refresh(activeScrollIndex2P);
  }

  void _completeDrawerAction(BuildContext context) {
    callBack(["scroll", context.read(activeScrollIndex1P).state]);
    if (!context.read(keepDrawerOpenP).state) {
      context.read(configProvider).state.save("showDrawer", !context.read(showDrawerP).state);
      context.refresh(showDrawerP);
    }
    //onCallBack(["scroll", context.read(activeScrollIndex1P).state]);
  }

}
