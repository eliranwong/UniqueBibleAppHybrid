// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
// My libraries
import 'config.dart';

class WordFeatures extends StatelessWidget {

  final Function callBack;
  TextEditingController wordFieldController = TextEditingController();
  ScrollController listViewScrollController = ScrollController();

  WordFeatures(this.callBack);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final List<Map<String, dynamic>> lookupMatches = watch(lookupMatchesP).state;
      final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
      return ListView(
        controller: listViewScrollController,
        //padding: const EdgeInsets.all(3),
        children: <Widget>[
          //Container(height: 5),
          ListTile(title: _buildVerseReferenceField(context),),
          if (lookupMatches.isNotEmpty) ExpansionTile(
            initiallyExpanded: true,
            title: Text("Matches"),
            backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
            children: [
              _buildMatchList(context, lookupMatches, myTextStyle),
            ],
          ),
          _buildFeaturesList(context),
        ],
      );
    });
    //return _buildCardList(context);
  }

  Widget _buildVerseReferenceField(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
        final String wordLookupEntry = watch(wordLookupEntryP).state;
        return TextField(
          controller: wordFieldController..text = wordLookupEntry,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Lookup",
            labelStyle: TextStyle(color: watch(myColorsP).state["blueAccent"]),
            //hintText: multipleVersionsReferences,
            //hintStyle: myTextStyle["subtitleStyle"],
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
            /*disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),*/
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          onSubmitted: (String value) {
            context.read(wordLookupEntryP).state = value;
            callBack(["speak", value]);
          },
          onChanged: (String value) {
            // The following lines keeps the cursor at the end of the editing text
            // Reference: https://stackoverflow.com/questions/56851701/how-to-set-cursor-position-at-the-end-of-the-value-in-flutter-in-textfield
            final val = TextSelection.collapsed(offset: wordFieldController.text.length);
            wordFieldController.selection = val;
          },
          /*onEditingComplete: () {
            print("complete");
          },*/
          //onTap: ,
          //onEditingComplete: ,
        );
      },
    );
  }

  Widget _buildMatchList(BuildContext context, List<Map<String, dynamic>> lookupMatches, Map<String, TextStyle> myTextStyle) {
    final List<String> keys = lookupMatches.first.keys.toList();
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: lookupMatches.length,
      itemBuilder: (context, i) {
        final String entry = lookupMatches[i][keys.first];
        return ListTile(
          title: ParsedText(
            alignment: TextAlign.start,
            text: entry,
            style: myTextStyle["verseFont"],
            parse: [
              MatchText(
                pattern: wordFieldController.text,
                regexOptions: RegexOptions(
                  caseSensitive: false,
                  unicode: true,
                ),
                style: context.read(configProvider).state.myTextStyle["instantHighlight"],
              ),
            ],
          ),
          onTap: () {
            context.read(lookupContentP).state = lookupMatches[i][keys.last];
          },
        );
      },
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    Map<String, List<String>> featureModules = {
      "lexicon": context.read(configProvider).state.allLexicons.keys.toList(),
      "encyclopedia": context.read(configProvider).state.allEncyclopedia.keys.toList(),
      "dictionary": context.read(configProvider).state.allDictionaries.keys.toList(),
      "generalDictionary": context.read(configProvider).state.allGeneralDictionaries.keys.toList(),
    };
    List<String> featureModuleList = featureModules.keys.toList(); //= [for (String i in featureModules.keys) if (featureModules[i].isNotEmpty) i];
    return Consumer(builder: (context, watch, child) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 15.0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: featureModuleList.length,
        itemBuilder: (context, i) {
          final String feature = featureModuleList[i];
          return _buildLookupSection(context, feature, featureModules[feature]);
        },
      );
    });
  }

  Widget _buildLookupSection(BuildContext context, String feature, List<String> moduleList) {
    return ExpansionTile(
      initiallyExpanded: false,
      title: Text(feature),
      backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
      children: [
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: moduleList.length,
          itemBuilder: (context, i) {
            final String module = moduleList[i];
            return ListTile(
              title: Text(module),
              onTap: () async => await lookupWord(feature, module),
              trailing: IconButton(
                tooltip: "Search",
                icon: const Icon(Icons.search),
                onPressed: () async => await lookupWord(feature, module),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> lookupWord(String feature, String module) async {
    if (wordFieldController.text.isNotEmpty) {
      listViewScrollController.animateTo(0, duration: Duration (milliseconds: 500), curve: Curves.linear);
      await callBack([feature, [module, wordFieldController.text]]);
    }
  }

}