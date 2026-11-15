import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/database/database_helper.dart';
import 'providers/finance_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/learning_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final settings = SettingsProvider();
  await settings.load();

  final taskProvider = TaskProvider();
  final financeProvider = FinanceProvider();
  final learningProvider = LearningProvider();
  final goalProvider = GoalProvider();
  final journalProvider = JournalProvider();

  await DatabaseHelper.instance.database;
  await Future.wait([
    taskProvider.load(),
    financeProvider.load(),
    learningProvider.load(),
    goalProvider.load(),
    journalProvider.load(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: taskProvider),
        ChangeNotifierProvider.value(value: financeProvider),
        ChangeNotifierProvider.value(value: learningProvider),
        ChangeNotifierProvider.value(value: goalProvider),
        ChangeNotifierProvider.value(value: journalProvider),
      ],
      child: const GrsLifeApp(),
    ),
  );
}
