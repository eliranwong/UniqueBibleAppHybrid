// Copyright 2020-2021 Eliran Wong. All rights reserved.

// Packages
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// My libraries
import 'config.dart';
// User interface
import 'ui_home.dart';

void main() {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  // The following line is suggested at https://flutter.dev/docs/cookbook/persistence/sqlite
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    ProviderScope(
      child: UniqueBibleApp(),
    ),
  );
}

class UniqueBibleApp extends HookWidget {
  @override
  build(BuildContext context) {
    final AsyncValue<Configurations> config = useProvider(configurationsProvider);

    return MaterialApp(
      title: 'Unique Bible App',
      home: config.when(
        loading: () => const Text('loading'),
        error: (error, stack) => const Text('Oops'),
        data: (config) => UiHome(),
      ),
    );
  }
}

/* an example of consumer widget
    return Consumer(
      builder: (context, watch, child) {
        return Text(watch(bible1P).state);
      },
    );
* */
