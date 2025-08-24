import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fcc/app/ui/home/home_ui.dart';
import 'package:fcc/app/infra/audio_service.dart';
import 'package:fcc/app/infra/local_notification_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize notification service once.
    ref.read(localNotificationServiceProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to keyword detection and show notification.
    ref.listen<bool>(keywordDetectedProvider, (previous, next) {
      if (next == true) {
        ref.read(localNotificationServiceProvider).showKeywordDetectedNotification();
      }
    });

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeUI(),
    );
  }
}