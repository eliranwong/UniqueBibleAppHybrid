import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'config.dart';
import 'app_translation.dart';
import 'bible_settings.dart';

class HomeTopAppBar {

  Widget buildSwitchButton(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        return IconButton(
          tooltip: AppTranslation.interfaceApp[watch(abbreviationsP).state][3],
          icon: const Icon(Icons.swap_calls),
          onPressed: () async {
            await context.read(configProvider).state.swapBibles();
            context.refresh(bible1P);
            context.refresh(bible2P);
            context.refresh(chapterDataP);
            context.refresh(activeScrollIndexP);
          },
        );
      },
    );
  }

  Widget buildWorkspaceButton(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        return IconButton(
          tooltip: AppTranslation.interfaceBottom[watch(abbreviationsP).state][9],
          icon: const Icon(Icons.workspaces_outline),
          onPressed: () async {
            await context.read(configProvider).state.changeWorkspaceLayout();
            context.refresh(workspaceLayoutP);
          },
        );
      },
    );
  }

  Widget buildPopupMenuButton(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final String abbreviations = watch(abbreviationsP).state;
        final List<String> interfaceApp =
            AppTranslation.interfaceApp[abbreviations];
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
          itemBuilder: (BuildContext context) => _buildPopupMenu(interfaceApp),
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenu(List<String> interfaceApp) {
    return <PopupMenuEntry<String>>[
      /*PopupMenuItem<String>(
        value: "Verse",
        child: ListTile(
          leading: Icon(Icons.directions),
          title: Text(interfaceApp[24]),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: "Big",
        child: ListTile(
          leading: Consumer(
            builder: (context, watch, child) {
              return Icon((watch(bigScreenP).state)
                  ? Icons.phone_android
                  : Icons.laptop);
            },
          ),
          title: Consumer(
            builder: (context, watch, child) {
              return Text((watch(bigScreenP).state)
                  ? interfaceApp[18]
                  : interfaceApp[17]);
            },
          ),
        ),
      ),*/
      /*PopupMenuItem<String>(
        value: "Workspace",
        child: ListTile(
          leading: Consumer(
            builder: (context, watch, child) {
              return Icon((watch(showWorkspaceP).state)
                  ? Icons.visibility_off
                  : Icons.visibility);
            },
          ),
          title: Consumer(
            builder: (context, watch, child) {
              return Text(
                  "${(watch(showWorkspaceP).state) ? interfaceApp[20] : interfaceApp[19]}${AppTranslation.interfaceBottom[watch(abbreviationsP).state][9]}");
            },
          ),
        ),
      ),*/
      //const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: "Flags",
        child: ListTile(
          leading: Consumer(
            builder: (context, watch, child) {
              return Icon((watch(showFlagsP).state)
                  ? Icons.visibility_off
                  : Icons.visibility);
            },
          ),
          title: Consumer(
            builder: (context, watch, child) {
              return Text(
                  "${(watch(showFlagsP).state) ? interfaceApp[20] : interfaceApp[19]}${interfaceApp[28]}");
            },
          ),
        ),
      ),
      PopupMenuItem<String>(
        value: "Notes",
        child: ListTile(
          leading: Consumer(
            builder: (context, watch, child) {
              return Icon((watch(showNotesP).state)
                  ? Icons.visibility_off
                  : Icons.visibility);
            },
          ),
          title: Consumer(
            builder: (context, watch, child) {
              return Text(
                  "${(watch(showNotesP).state) ? interfaceApp[20] : interfaceApp[19]}${interfaceApp[13]}");
            },
          ),
        ),
      ),
      PopupMenuItem<String>(
        value: "Transliteration",
        child: ListTile(
          leading: Consumer(
            builder: (context, watch, child) {
              return Icon((watch(showTransliterationP).state)
                  ? Icons.visibility_off
                  : Icons.visibility);
            },
          ),
          title: Consumer(
            builder: (context, watch, child) {
              return Text(
                  "${(watch(showTransliterationP).state) ? interfaceApp[20] : interfaceApp[19]}${interfaceApp[30]}");
            },
          ),
        ),
      ),
      PopupMenuItem<String>(
        value: "Pinyin",
        child: ListTile(
          leading: Consumer(
            builder: (context, watch, child) {
              return Icon((watch(showPinyinP).state)
                  ? Icons.visibility_off
                  : Icons.visibility);
            },
          ),
          title: Consumer(
            builder: (context, watch, child) {
              return Text(
                  "${(watch(showPinyinP).state) ? interfaceApp[20] : interfaceApp[19]}${interfaceApp[29]}");
            },
          ),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: "Settings",
        child: ListTile(
          leading: Icon(Icons.settings),
          title: Text(interfaceApp[4]),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: "Manual",
        child: ListTile(
          leading: Icon(Icons.help_outline),
          title: Consumer(
            builder: (context, watch, child) {
              return Text(AppTranslation
                  .interfaceBottom[watch(abbreviationsP).state][8]);
            },
          ),
        ),
      ),
      PopupMenuItem<String>(
        value: "Contact",
        child: ListTile(
          leading: Icon(Icons.alternate_email),
          title: Text(interfaceApp[14]),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: "Restart",
        child: ListTile(
          leading: Icon(Icons.replay),
          title: Text(interfaceApp[31]),
        ),
      ),
    ];
  }

}
