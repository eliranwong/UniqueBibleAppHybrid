import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'config.dart';
import 'ui_bible_settings.dart';

class HomeTopAppBar {

  final Function callBack;

  HomeTopAppBar(this.callBack);

  Widget buildSwitchButton(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        return IconButton(
          tooltip: watch(interfaceAppP).state[3],
          icon: const Icon(Icons.swap_calls),
          onPressed: () async {
            await context.read(configProvider).state.swapBibles();
            context.refresh(bible1P);
            context.refresh(bible2P);
            context.refresh(allChapterData1P);
            context.refresh(chapterData2P);
            context.refresh(activeScrollIndex1P);
            context.refresh(activeScrollIndex2P);
          },
        );
      },
    );
  }

  Widget parallelVersesButton(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final bool parallelVerses = watch(parallelVersesP).state;
        return IconButton(
          tooltip: watch(interfaceAppP).state[5],
          icon: Icon((parallelVerses) ? Icons.layers_clear_outlined : Icons.layers_outlined),
          onPressed: () async {
            context
                .read(configProvider)
                .state
                .save("parallelVerses", !parallelVerses);
            context.refresh(parallelVersesP);
            final List<int> activeVerse = context.read(historyActiveVerseP).state.first;
            context.read(configProvider).state.updateDisplayChapterData(activeVerse);
            context.refresh(allChapterData1P);
            context.read(configProvider).state.updateActiveScrollIndex(activeVerse);
            context.refresh(activeScrollIndex1P);
            callBack(["scrollToBibleVerse", ""]);
          },
        );
      },
    );
  }

  Widget buildPopupMenuButton(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final List<String> interfaceApp = watch(interfaceAppP).state;
        final List<String> interfaceBottom = watch(interfaceBottomP).state;
        final Map<String, Color> myColors = watch(myColorsP).state;
        return PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          tooltip: interfaceApp[21],
          padding: EdgeInsets.zero,
          onSelected: (String value) {
            switch (value) {
              case "Notes":
                context
                    .read(configProvider)
                    .state
                    .save("showNotes", !context.read(showNotesP).state);
                context.refresh(showNotesP);
                break;
              case "Flags":
                context
                    .read(configProvider)
                    .state
                    .save("showFlags", !context.read(showFlagsP).state);
                context.refresh(showFlagsP);
                break;
              case "Pinyin":
                context
                    .read(configProvider)
                    .state
                    .save("showPinyin", !context.read(showPinyinP).state);
                context.refresh(showPinyinP);
                break;
              case "Transliteration":
                print("showTransliteration");
                context.read(configProvider).state.save("showTransliteration",
                    !context.read(showTransliterationP).state);
                context.refresh(showTransliterationP);
                break;
              case "Verse":
                print("Verse");
                //_openVerseSelector(context);
                break;
              case "Settings":
                Configurations.goTo(context, BibleSettings());
                break;
              case "Restart":
                context.refresh(configurationsProvider);
                break;
              case "Manual":
                print("Manual");
                //_launchUserManual();
                break;
              case "Contact":
                print("Contact");
                //_launchContact();
                break;
              default:
                break;
            }
          },
          itemBuilder: (BuildContext context) => _buildPopupMenu(interfaceApp, interfaceBottom, myColors),
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenu(List<String> interfaceApp, List<String> interfaceBottom, Map<String, Color> myColors) {
    return <PopupMenuEntry<String>>[
      PopupMenuItem<String>(
        value: "Flags",
        child: Consumer(builder: (context, watch, child) {
          return ListTile(
            leading: Icon((watch(showFlagsP).state)
                ? Icons.visibility_off
                : Icons.visibility, color: myColors["grey"],),
            title: Text(
                "${(watch(showFlagsP).state) ? interfaceApp[20] : interfaceApp[19]}${interfaceApp[28]}"),
          );
        }),
      ),
      PopupMenuItem<String>(
        value: "Notes",
        child: Consumer(builder: (context, watch, child) {
          return ListTile(
            leading: Icon((watch(showNotesP).state)
                ? Icons.visibility_off
                : Icons.visibility, color: myColors["grey"],),
            title: Text(
                "${(watch(showNotesP).state) ? interfaceApp[20] : interfaceApp[19]}${interfaceApp[13]}"),
          );
        }),
      ),
      PopupMenuItem<String>(
        value: "Transliteration",
        child: Consumer(builder: (context, watch, child) {
          return ListTile(
            leading: Icon((watch(showTransliterationP).state)
                ? Icons.visibility_off
                : Icons.visibility, color: myColors["grey"],),
            title: Text(
                "${(watch(showTransliterationP).state) ? interfaceApp[20] : interfaceApp[19]}${interfaceApp[30]}"),
          );
        }),
      ),
      PopupMenuItem<String>(
        value: "Pinyin",
        child: Consumer(builder: (context, watch, child) {
          return ListTile(
            leading: Icon((watch(showPinyinP).state)
                ? Icons.visibility_off
                : Icons.visibility, color: myColors["grey"],
            ),
            title: Text(
                "${(watch(showPinyinP).state) ? interfaceApp[20] : interfaceApp[19]}${interfaceApp[29]}"),
          );
        }),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: "Settings",
        child: Consumer(builder: (context, watch, child) {
          return ListTile(
            leading: Icon(Icons.settings, color: myColors["grey"],),
            title: Text(interfaceApp[4]),
          );
        }),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: "Manual",
        child: Consumer(builder: (context, watch, child) {
          return ListTile(
            leading: Icon(Icons.help_outline, color: myColors["grey"],),
            title: Consumer(
              builder: (context, watch, child) {
                return Text(interfaceBottom[8]);
              },
            ),
          );
        }),
      ),
      PopupMenuItem<String>(
        value: "Contact",
        child: Consumer(builder: (context, watch, child) {
          return ListTile(
            leading: Icon(Icons.alternate_email, color: myColors["grey"],),
            title: Text(interfaceApp[14]),
          );
        }),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: "Restart",
        child: Consumer(builder: (context, watch, child) {
          return ListTile(
            leading: Icon(Icons.replay, color: myColors["grey"],),
            title: Text(interfaceApp[31]),
          );
        }),
      ),
    ];
  }

}




