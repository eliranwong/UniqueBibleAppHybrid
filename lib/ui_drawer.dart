// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// My libraries
import 'config.dart';
import 'text_transformer.dart';

class BibleDrawer extends StatelessWidget {
  final Function callBack;
  TextEditingController searchFieldController, excludeFromSearchController;

  BibleDrawer(this.callBack) {
    searchFieldController = TextEditingController();
    excludeFromSearchController = TextEditingController();
  }

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
      padding: const EdgeInsets.all(3),
      children: <Widget>[
        Container(height: 5),
        _buildVerseReferenceField(context),
        Container(height: 5),
        _buildBookMenuList(context),
        _buildChapterMenuList(context),
        _buildShowVerseSwitch(context),
        _buildVerseMenuList(context),
      ],
    );
  }

  /*Widget _buildMultipleReferenceSwitch(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final bool searchMultipleReference = watch(searchMultipleReferenceP).state;
      return ListTile(
        title: Text("Multiple References"),
        //Text(interface[24], style: Theme.of(context).textTheme.bodyText1),
        trailing: Switch(
            value: searchMultipleReference,
            onChanged: (bool newValue) {
              if (newValue != searchMultipleReference) {
                context.read(configProvider).state.searchMultipleReference = newValue;
                context.refresh(searchMultipleReferenceP);
              }
            }),
      );
    });
  }*/

  Widget _buildShowVerseSwitch(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final bool showVerseSelection = watch(showVerseSelectionP).state;
      return ListTile(
        title: Text("Verse Selection"),
        //Text(interface[24], style: Theme.of(context).textTheme.bodyText1),
        trailing: Switch(
            value: showVerseSelection,
            onChanged: (bool newValue) {
              if (newValue != showVerseSelection) {
                context
                    .read(configProvider)
                    .state
                    .save("showVerseSelection", newValue);
                context.refresh(showVerseSelectionP);
              }
            }),
      );
    });
  }

  Widget _buildVerseReferenceField(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String activeVerseReference = watch(activeVerseReferenceP).state;
        final List<int> activeVerse = context
            .read(configProvider)
            .state
            .listListIntValues["historyActiveVerse"]
            .first;
        return TextField(
          controller: TextEditingController(text: activeVerseReference),
          autofocus: watch(autoFocusVerseReferenceFieldP).state,
          decoration: InputDecoration(
            labelText: "Go to",
            labelStyle: TextStyle(color: watch(myColorsP).state["blueAccent"]),
            hintText: activeVerseReference,
            hintStyle: myTextStyle["subtitleStyle"],
            //errorText: _searchInputValid ? null : 'Invalid input!',
            //prefixIcon: Icon(Icons.search),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: watch(myColorsP).state["blueAccent"]),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: watch(myColorsP).state["grey"]),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          onSubmitted: (String value) async {
            // Convert full-width punctuations
            value = TextTransformer.removeFullWidthPunctuation(value);
            // Parse the entered reference(s)
            final List<List<dynamic>> references =
                context.read(parserP).state.extractAllReferences(value);
            if (references.first.join(".") != activeVerse.join(".")) {
              await callBack([
                (references.first.sublist(0, 2).join(".") ==
                        activeVerse.sublist(0, 2).join("."))
                    ? "newVerseSelectedSameChapter"
                    : "newVerseSelected",
                references.first
              ]);
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

  Widget _buildBookMenuList(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final List<int> activeVerse = watch(historyActiveVerseP).state.first;
      final int menuBook = watch(menuBookP).state;
      final List<int> bookList = watch(configProvider).state.bibleDB1.bookList;
      final Map<String, String> standardBookname =
          watch(parserP).state.standardBookname;
      final Map<String, String> standardAbbreviation =
          watch(parserP).state.standardAbbreviation;
      final int activeBookNo = activeVerse.first;
      final int activeChapterNo = activeVerse[1];
      final String currentBookName = standardBookname[activeBookNo.toString()];
      final String currentMenuBookName = standardBookname[menuBook.toString()];
      return ExpansionTile(
        leading: IconButton(
          tooltip: "Clear",
          icon: const Icon(Icons.settings_backup_restore),
          onPressed: () async {
            await context.read(configProvider).state.bibleDB1.updateMenuBook(activeBookNo, chapter: activeChapterNo);
            await context.read(configProvider).state.bibleDB1.updateMenuChapter(activeChapterNo);
            context.refresh(menuBookP);
            context.refresh(menuChapterListP);
            context.refresh(menuChapterP);
            context.refresh(menuVerseListP);
          },
        ),
        title: Text(currentBookName),
        subtitle: (currentMenuBookName == currentBookName) ? null : Text("-> $currentMenuBookName"),
        initiallyExpanded: true,
        backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Wrap(
              spacing: 3.0,
              children: (watch(displayAllMenuBookP).state) ? _buildBookMenuChips(context, bookList, standardBookname, standardAbbreviation, menuBook) : _buildSelectADifferentBookChip(context),
            ),
          )
        ],
        //onExpansionChanged: ,
      );
    });
  }

  List<Widget> _buildSelectADifferentBookChip(BuildContext context) {
    return <Widget>[
      Consumer(builder: (context, watch, child) {
        final String buttonTitle = watch(interfaceAppP).state[32];
        return ChoiceChip(
          backgroundColor: Colors.blue[50],
          label: Tooltip(
              message: buttonTitle,
              child: Text(
                buttonTitle,
                style: TextStyle(fontSize: 14),
              )),
          selected: false,
          onSelected: (bool selected) async {
            if (selected) {
              context.read(configProvider).state.updateDisplayAllMenuBook();
              context.refresh(displayAllMenuBookP);
            }
          },
        );
      }),
    ];
  }

  List<Widget> _buildBookMenuChips(
      BuildContext context,
      List<int> bookList,
      Map<String, String> standardBookname,
      Map<String, String> standardAbbreviation,
      int menuBook) {
    return List<Widget>.generate(
      bookList.length,
      (int index) {
        int bookNo = bookList[index];
        String bookName = standardBookname[bookNo.toString()];
        String bookAbb = standardAbbreviation[bookNo.toString()];
        return ChoiceChip(
          backgroundColor: Colors.blue[50],
          label: Tooltip(
              message: bookName,
              child: Text(
                bookAbb,
                style: TextStyle(fontSize: 14),
              )),
          selected: (bookNo == menuBook),
          onSelected: (bool selected) async {
            if ((selected) && (bookNo != menuBook)) {
              await context.read(configProvider).state.bibleDB1.updateMenuBook(bookNo);
              context.refresh(menuBookP);
              context.refresh(menuChapterListP);
              context.refresh(menuChapterP);
              context.refresh(menuVerseListP);
              context.read(configProvider).state.updateDisplayAllMenuBook();
              context.refresh(displayAllMenuBookP);
              if (context.read(openBookWithoutChapterSelectionP).state) {
                int newChapter = context.read(menuChapterP).state;
                int newVerse = context.read(menuVerseListP).state.first;
                await callBack(["newVerseSelected", [bookNo, newChapter, newVerse]]);
              }
            }
          },
        );
      },
    ).toList();
  }

  Widget _buildChapterMenuList(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final List<int> activeVerse = watch(historyActiveVerseP).state.first;
      final int activeBookNo = activeVerse.first;
      final int activeChapterNo = activeVerse[1];
      final int currentChapterNo = activeVerse[1];
      final int menuChapter = watch(menuChapterP).state;
      final List<int> chapterList = watch(menuChapterListP).state;
      return ExpansionTile(
        leading: IconButton(
          tooltip: "Clear",
          icon: const Icon(Icons.settings_backup_restore),
          onPressed: () async {
            await context.read(configProvider).state.bibleDB1.updateMenuBook(activeBookNo, chapter: activeChapterNo);
            await context.read(configProvider).state.bibleDB1.updateMenuChapter(activeChapterNo);
            context.refresh(menuBookP);
            context.refresh(menuChapterListP);
            context.refresh(menuChapterP);
            context.refresh(menuVerseListP);
          },
        ),
        title: Text("${watch(interfaceAppP).state[33]}$currentChapterNo"),
        subtitle: (menuChapter == currentChapterNo) ? null : Text("-> $menuChapter"),
        initiallyExpanded: true,
        backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
        children: <Widget>[
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Wrap(
                spacing: 3.0,
                children: _buildChapterMenuChips(context, chapterList, menuChapter,
                ),
              )
          )
        ],
        //onExpansionChanged: ,
      );
    });
  }

  List<Widget> _buildChapterMenuChips(
      BuildContext context, List<int> chapterList, int menuChapter) {
    return List<Widget>.generate(
      chapterList.length,
      (int index) {
        int chapterNo = chapterList[index];
        return ChoiceChip(
          backgroundColor: Colors.blue[50],
          label: Text(
            chapterNo.toString(),
            style: TextStyle(fontSize: 14),
          ),
          selected: (chapterNo == menuChapter),
          onSelected: (bool selected) async {
            if ((context.read(showVerseSelectionP).state) && (!context.read(openChapterWithoutVerseSelectionP).state)) {
              await context.read(configProvider).state.bibleDB1.updateMenuChapter(chapterNo);
              context.refresh(menuChapterP);
              context.refresh(menuVerseListP);
            } else if ("${context.read(menuBookP).state}.$chapterNo" != "${context.read(menuBookP).state}.$menuChapter") {
              await context.read(configProvider).state.bibleDB1.updateMenuChapter(chapterNo);
              final int firstVerseNo = context.read(configProvider).state.bibleDB1.menuVerseList.first;
              await callBack(["newVerseSelected", [context.read(menuBookP).state, chapterNo, firstVerseNo]]);
            }
          },
        );
      },
    ).toList();
  }

  Widget _buildVerseMenuList(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final bool showVerseSelection = watch(showVerseSelectionP).state;
      if (showVerseSelection) {
        final List<int> activeVerse = watch(historyActiveVerseP).state.first;
        final int activeBookNo = activeVerse.first;
        final int activeChapterNo = activeVerse[1];
        final List<int> verseList = watch(menuVerseListP).state;
        return ExpansionTile(
          leading: IconButton(
            tooltip: "Clear",
            icon: const Icon(Icons.settings_backup_restore),
            onPressed: () async {
              await context.read(configProvider).state.bibleDB1.updateMenuBook(activeBookNo, chapter: activeChapterNo);
              await context.read(configProvider).state.bibleDB1.updateMenuChapter(activeChapterNo);
              context.refresh(menuBookP);
              context.refresh(menuChapterListP);
              context.refresh(menuChapterP);
              context.refresh(menuVerseListP);
            },
          ),
          title: Text("${watch(interfaceAppP).state[34]}${activeVerse[2].toString()}"),
          /*title: Text(this.interfaceApp[this.abbreviations][12],
          style: _generalTextStyle),*/
          initiallyExpanded: true,
          backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
          children: <Widget>[
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Wrap(
                  spacing: 3.0,
                  children: _buildVerseMenuChips(context, verseList),
                )
            ),
          ],
          //onExpansionChanged: ,
        );
      }
      return Container();
    });
  }

  List<Widget> _buildVerseMenuChips(
      BuildContext context, List<int> verseList) {
    return List<Widget>.generate(
      verseList.length,
      (int index) {
        int verseNo = verseList[index];
        return ChoiceChip(
          backgroundColor: Colors.blue[50],
          label: Text(
            verseNo.toString(),
            style: TextStyle(fontSize: 14),
          ),
          selected: false,
          onSelected: (bool selected) async {
            if (selected) {
              final int menuBook = context.read(menuBookP).state;
              final int menuChapter = context.read(menuChapterP).state;
              await callBack(["newVerseSelected", [menuBook, menuChapter, verseNo]]);
            }
          },
        );
      },
    ).toList();
  }

  Widget _buildDrawerTab2(BuildContext context) {
    return ListView(
      children: <Widget>[
        _buildVersionList(context, true),
        _buildVersionList(context, false),
        _buildVersionFilterChipsList(context),
        _buildCompareButton(context),
      ],
    );
  }

  Widget _buildCompareButton(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final String activeVerseReference = watch(activeVerseReferenceP).state;
      final List<String> interfaceApp = watch(interfaceAppP).state;
      return ButtonBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          RaisedButton(
            child: Text("${interfaceApp[38]}\n$activeVerseReference", textAlign: TextAlign.center,),
            color: Colors.teal[50],
            onPressed: () async {
              await callBack(["loadMultipleVersions", [[context.read(configProvider).state.listListIntValues["historyActiveVerse"].first], true]]);
              _completeDrawerAction(context);
            },
          ),
        ],
      );
    });
  }

  Widget _buildVersionFilterChipsList(BuildContext context) {
    List<Widget> versionRowList = [
      Consumer(builder: (context, watch, child) {
        final List<String> compareBibleList =
            watch(compareBibleListP).state;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Wrap(
            spacing: 3.0,
            children: _buildVersionFilterChips(context, compareBibleList),
          ),
        );
      }),
    ];
    return ExpansionTile(
      title: Text("Verse Comparison"),
      /*title: Text(this.interfaceApp[this.abbreviations][12],
          style: _generalTextStyle),*/
      initiallyExpanded: false,
      backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
      children: versionRowList,
      //onExpansionChanged: ,
    );
  }

  List<Widget> _buildVersionFilterChips(
      BuildContext context, List<String> compareBibleList) {
    final Map<String, List<String>> allBibles =
        context.read(configProvider).state.allBibles;
    final List<String> allBiblesList = allBibles.keys.toList()..sort();
    return List<Widget>.generate(
      allBiblesList.length,
          (int index) {
        String module = allBiblesList[index];
        return FilterChip(
          selectedColor: Colors.blue[100],
          backgroundColor: Colors.blue[50],
          label: Tooltip(
              message: allBibles[module][1],
              child: Text(
                module,
                style: TextStyle(fontSize: 14),
              )),
          selected: (compareBibleList.contains(module)),
          onSelected: (bool selected) async {
            // Remove old bible version(s) and potential duplication.
            List<String> newCompareList = [for (String i in compareBibleList) if (allBiblesList.contains(i)) i].toSet().toList();
            if (selected) {
              newCompareList.add(module);
              await context.read(configProvider).state.save("compareBibleList", newCompareList);
            } else {
              newCompareList.remove(module);
              await context.read(configProvider).state.save("compareBibleList", newCompareList);
            }
            context.refresh(compareBibleListP);
          },
        );
      },
    ).toList();
  }

  Widget _buildVersionList(BuildContext context, bool primaryBible) {
    List<Widget> versionRowList = [
      Container(height: 5),
      (primaryBible)
          ? _buildBookVersionField1(context)
          : _buildBookVersionField2(context),
      Consumer(builder: (context, watch, child) {
        final String activeModule =
            (primaryBible) ? watch(bible1P).state : watch(bible2P).state;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Wrap(
            spacing: 3.0,
            children: _buildVersionChips(context, primaryBible, activeModule),
          ),
        );
      }),
    ];
    return ExpansionTile(
      title: Text((primaryBible) ? "Primary Bible" : "Secondary Bible"),
      /*title: Text(this.interfaceApp[this.abbreviations][12],
          style: _generalTextStyle),*/
      initiallyExpanded: (primaryBible) ? true : false,
      backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
      children: versionRowList,
      childrenPadding: const EdgeInsets.all(3),
      //onExpansionChanged: ,
    );
  }

  List<Widget> _buildVersionChips(
      BuildContext context, bool primaryBible, String activeModule) {
    final Map<String, List<String>> allBibles =
        context.read(configProvider).state.allBibles;
    final List<String> allBiblesList = allBibles.keys.toList()..sort();
    return List<Widget>.generate(
      allBiblesList.length,
      (int index) {
        String module = allBiblesList[index];
        return ChoiceChip(
          //tooltip: config.allBibleMap[abb],
          backgroundColor: Colors.grey[200],
          label: Tooltip(
              message: allBibles[module][1],
              child: Text(
                module,
                style: TextStyle(fontSize: 14),
              )),
          selected: (module == activeModule),
          onSelected: (bool selected) async {
            if ((selected) && (module != activeModule)) {
              (primaryBible)
                  ? await callBack(["changeBible1Version", module])
                  : await callBack(["changeBible2Version", module]);
              _completeDrawerAction(context);
            }
          },
        );
      },
    ).toList();
  }

  Widget _buildBookVersionField1(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String bible1 = watch(bible1P).state;
        return TextField(
          controller: TextEditingController(text: bible1),
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Primary Bible",
            labelStyle: TextStyle(color: watch(myColorsP).state["blueAccent"]),
            hintText: bible1,
            hintStyle: myTextStyle["subtitleStyle"],
            //errorText: _searchInputValid ? null : 'Invalid input!',
            //prefixIcon: Icon(Icons.search),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: watch(myColorsP).state["blueAccent"]),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: watch(myColorsP).state["grey"]),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          onSubmitted: (String value) async {
            if (value != bible1) {
              await callBack(["changeBible1Version", value]);
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

  Widget _buildBookVersionField2(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String bible2 = watch(bible2P).state;
        return TextField(
          controller: TextEditingController(text: bible2),
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Secondary Bible",
            labelStyle: TextStyle(color: watch(myColorsP).state["blueAccent"]),
            hintText: bible2,
            hintStyle: myTextStyle["subtitleStyle"],
            //errorText: _searchInputValid ? null : 'Invalid input!',
            //prefixIcon: Icon(Icons.search),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: watch(myColorsP).state["blueAccent"]),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: watch(myColorsP).state["grey"]),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          onSubmitted: (String value) async {
            if (value != bible2) {
              await callBack(["changeBible2Version", value]);
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

  Widget _buildDrawerTab3(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final bool searchWholeBible = watch(searchWholeBibleP).state;
      final bool searchEntryExclusion = watch(searchEntryExclusionP).state;
      return ListView(
        padding: const EdgeInsets.all(3),
        children: <Widget>[
          Container(height: 5),
          _buildSearchBibleField(context),
          //Container(height: 5),
          _buildSearchButtons(context),
          _buildSearchEntryOptionDescription(context),
          _buildSearchEntryOption(context),
          _buildSearchEntryExclusionOption(context),
          (searchEntryExclusion) ? _buildSearchExclusionField(context) : Container(),
          _buildSearchWholeBibleOption(context, searchWholeBible),
          (searchWholeBible) ? Container() : _buildBookCollectionList(context),
          (searchWholeBible) ? Container() : _buildBookFilterChipsList(context),
        ],
      );
    });
  }

  Widget _buildSearchButtons(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final String bible1 = watch(bible1P).state;
      final String bible2 = watch(bible2P).state;
      return ListTile(
        title: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Wrap(
            spacing: 3.0,
            children: <Widget>[
              ChoiceChip(
                backgroundColor: Colors.blue[50],
                label: Tooltip(
                    message: watch(interfaceAppP).state[2],
                    child: Text(bible1,
                      style: TextStyle(fontSize: 14),
                    )),
                selected: false,
                onSelected: (bool selected) async {
                  if (selected) await _searchSelectedBible(context, module: bible1);
                },
              ),
              ChoiceChip(
                backgroundColor: Colors.blue[50],
                label: Tooltip(
                    message: watch(interfaceAppP).state[2],
                    child: Text("$bible2",
                      style: TextStyle(fontSize: 14),
                    )),
                selected: false,
                onSelected: (bool selected) async {
                  if (selected) await _searchSelectedBible(context, module: bible2);
                },
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: watch(myColorsP).state["blueAccent"],),
          itemBuilder: (BuildContext context) {
            final Map<String, List<String>> allBibles = context.read(configProvider).state.allBibles;
            final List<String> allBiblesList = allBibles.keys.toList()..sort();
            return allBiblesList.map((i) => PopupMenuItem(value: i, child: Text(i))).toList();
          },
          onSelected: (String value) async => await _searchSelectedBible(context, module: value),
        ),
      );
    });
  }

  Widget _buildSearchEntryOptionDescription(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final List<String> searchOptionDescription = watch(searchEntryOptionsP).state;
      final int searchEntryOption = watch(searchEntryOptionP).state;
      return Text(searchOptionDescription[searchEntryOption]);
    });
  }

  Widget _buildSearchEntryOption(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final int searchEntryOption = watch(searchEntryOptionP).state;
      return Row(
        children: [0, 1, 2, 3, 4]
            .map((int index) => Radio<int>(
                  value: index,
                  groupValue: searchEntryOption,
                  onChanged: (int value) {
                    if (value != searchEntryOption) {
                      context.read(configProvider).state.searchEntryOption =
                          value;
                      context.refresh(searchEntryOptionP);
                    }
                  },
                ))
            .toList(),
      );
    });
  }

  Widget _buildSearchEntryExclusionOption(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final bool searchEntryExclusion = watch(searchEntryExclusionP).state;
      return ListTile(
        title: Text("Enable Exclusion"),
        //Text(interface[24], style: Theme.of(context).textTheme.bodyText1),
        trailing: Switch(
            value: searchEntryExclusion,
            onChanged: (bool newValue) {
              if (newValue != searchEntryExclusion) {
                context.read(configProvider).state.searchEntryExclusion = newValue;
                context.refresh(searchEntryExclusionP);
              }
            }),
      );
    });
  }

  Widget _buildSearchWholeBibleOption(
      BuildContext context, bool searchWholeBible) {
    return ListTile(
      title: Text("Search whole bible?"),
      //Text(interface[24], style: Theme.of(context).textTheme.bodyText1),
      trailing: Switch(
          value: searchWholeBible,
          onChanged: (bool newValue) {
            if (newValue != searchWholeBible) {
              context.read(configProvider).state.searchWholeBible = newValue;
              context.refresh(searchWholeBibleP);
            }
          }),
    );
  }

  Widget _buildBookCollectionList(BuildContext context) {
    List<Widget> versionRowList = [
      Consumer(builder: (context, watch, child) {
        final Map<String, Set<int>> bookCollections =
            watch(parserP).state.bookCollections;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Wrap(
            spacing: 3.0,
            children: _buildBookCollectionChips(context, bookCollections),
          ),
        );
      }),
    ];
    return ExpansionTile(
      title: Text("Book Collections"),
      /*title: Text(this.interfaceApp[this.abbreviations][12],
          style: _generalTextStyle),*/
      initiallyExpanded: false,
      backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
      children: versionRowList,
      //onExpansionChanged: ,
    );
  }

  List<Widget> _buildBookCollectionChips(
      BuildContext context, Map<String, Set<int>> bookCollections) {
    final List<String> bookCollectionsList = bookCollections.keys.toList();
    return List<Widget>.generate(
      bookCollectionsList.length,
      (int index) {
        String bookCollection = bookCollectionsList[index];
        return ChoiceChip(
          backgroundColor: Colors.teal[50],
          label: Tooltip(
              message: bookCollection,
              child: Text(
                bookCollection,
                style: TextStyle(fontSize: 14),
              )),
          selected: false,
          onSelected: (bool selected) async {
            if (selected) {
              context
                  .read(configProvider)
                  .state
                  .bibleDB1
                  .bibleSearchBookFilter
                  .addAll(bookCollections[bookCollection]);
              context.refresh(bibleSearchBookFilterP);
            }
          },
        );
      },
    ).toList();
  }

  Widget _buildBookFilterChipsList(BuildContext context) {
    List<Widget> versionRowList = [
      Consumer(builder: (context, watch, child) {
        final Set<int> bibleSearchBookFilter =
            watch(bibleSearchBookFilterP).state;
        final Map<String, String> standardAbbreviation =
            watch(parserP).state.standardAbbreviation;
        final Map<String, String> standardBookname =
            watch(parserP).state.standardBookname;
        final List<int> bookList =
            watch(configProvider).state.bibleDB1.bookList;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Wrap(
            spacing: 3.0,
            children: _buildBookFilterChips(context, bookList,
                bibleSearchBookFilter, standardBookname, standardAbbreviation),
          ),
        );
      }),
    ];
    return ExpansionTile(
      leading: IconButton(
        tooltip: "Clear",
        icon: const Icon(Icons.settings_backup_restore),
        onPressed: () {
          context
              .read(configProvider)
              .state
              .bibleDB1
              .bibleSearchBookFilter
              .clear();
          context.refresh(bibleSearchBookFilterP);
        },
      ),
      title: Text("Filters"),
      /*title: Text(this.interfaceApp[this.abbreviations][12],
          style: _generalTextStyle),*/
      initiallyExpanded: true,
      backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
      children: versionRowList,
      //onExpansionChanged: ,
    );
  }

  List<Widget> _buildBookFilterChips(
      BuildContext context,
      List<int> bookList,
      Set<int> bibleSearchBookFilter,
      Map<String, String> standardBookname,
      Map<String, String> standardAbbreviation) {
    return List<Widget>.generate(
      bookList.length,
      (int index) {
        int bookNo = bookList[index];
        String bookName = standardBookname[bookNo.toString()];
        String bookAbb = standardAbbreviation[bookNo.toString()];
        return FilterChip(
          selectedColor: Colors.blue[100],
          backgroundColor: Colors.blue[50],
          label: Tooltip(
              message: bookName,
              child: Text(
                bookAbb,
                style: TextStyle(fontSize: 14),
              )),
          selected: (bibleSearchBookFilter.contains(bookNo)),
          onSelected: (bool selected) async {
            if (selected) {
              context
                  .read(configProvider)
                  .state
                  .bibleDB1
                  .bibleSearchBookFilter
                  .add(bookNo);
            } else {
              context
                  .read(configProvider)
                  .state
                  .bibleDB1
                  .bibleSearchBookFilter
                  .remove(bookNo);
            }
            context.refresh(bibleSearchBookFilterP);
          },
        );
      },
    ).toList();
  }

  Widget _buildSearchBibleField(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String lastBibleSearchEntry = watch(bibleSearchDataP).state["lastBibleSearchEntry"];
        return TextField(
          controller: searchFieldController..text = lastBibleSearchEntry,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Search",
            labelStyle: TextStyle(color: watch(myColorsP).state["blueAccent"]),
            hintText: lastBibleSearchEntry,
            hintStyle: myTextStyle["subtitleStyle"],
            //errorText: _searchInputValid ? null : 'Invalid input!',
            //prefixIcon: Icon(Icons.search),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: watch(myColorsP).state["blueAccent"]),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: watch(myColorsP).state["grey"]),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          onSubmitted: (String value) async => await _searchSelectedBible(context),
          //onChanged: ,
          //onTap: ,
          //onEditingComplete: ,
        );
      },
    );
  }

  Widget _buildSearchExclusionField(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String lastBibleSearchEntry = watch(bibleSearchDataP).state["lastBibleSearchEntry"];
        final String lastBibleSearchExclusionEntry = watch(bibleSearchDataP).state["lastBibleSearchExclusionEntry"];
        return TextField(
          controller: excludeFromSearchController..text = lastBibleSearchExclusionEntry,
          autofocus: false,
          decoration: InputDecoration(
            labelText: "Exclude (separator |)",
            labelStyle: TextStyle(color: watch(myColorsP).state["blueAccent"]),
            hintText: "exclude these words",
            hintStyle: myTextStyle["subtitleStyle"],
            //errorText: _searchInputValid ? null : 'Invalid input!',
            //prefixIcon: Icon(Icons.search),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: watch(myColorsP).state["blueAccent"]),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: watch(myColorsP).state["grey"]),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          onSubmitted: (String value) async => await _searchSelectedBible(context),
          //onChanged: ,
          //onTap: ,
          //onEditingComplete: ,
        );
      },
    );
  }

  Future<void> _searchSelectedBible(BuildContext context, {String module = ""}) async {
    final String searchString = (searchFieldController.text.isNotEmpty) ? searchFieldController.text : context.read(bibleSearchDataP).state["lastBibleSearchEntry"];
    if (searchString.isNotEmpty) {
      final String searchExclusionString = excludeFromSearchController.text;
      final List<String> data = [searchString, searchExclusionString, module];
      await callBack(["searchBible", data]);
      _completeDrawerAction(context);
    }
  }

  Future<void> _completeDrawerAction(BuildContext context) async {
    if (!context.read(keepDrawerOpenP).state) {
      context
          .read(configProvider)
          .state
          .save("showDrawer", !context.read(showDrawerP).state);
      context.refresh(showDrawerP);
    }
  }
}
