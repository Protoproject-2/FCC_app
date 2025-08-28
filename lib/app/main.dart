import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fcc/app/ui/home/home_ui.dart';
import 'package:fcc/app/ui/home/home_ui_user_list_provider.dart';
import 'package:fcc/app/infra/audio_service.dart';
import 'package:fcc/app/infra/local_notification_service.dart';
import 'package:fcc/app/infra/app_user_service.dart';
import 'package:fcc/app/infra/emergency_service.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:geolocator/geolocator.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // prepere LINE sdk
  LineSDK.instance.setup('2007473247').then((_) {
    print('LineSDK Prepared');
  });
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  void _handleKeywordDetected() {
    Position position;
    final userId = int.tryParse(AppUserService.getAppId() ?? "0") ?? 0;
    final notifier = ref.read(userListProvider.notifier);
    // ON のユーザーIDを取得
    final activeIds = notifier.selectedIds;

    Future(() async {
      try {
        // 権限確認 & 要求
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            print("位置情報の権限が拒否されました");
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          print("位置情報の権限が永続的に拒否されています");
          return;
        }

        position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      } catch (e) {
        print("位置情報取得エラー: $e");
        return;
      }
      
      await sendEmergency(userId, activeIds, position.latitude, position.longitude);
    });
  }

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
        _handleKeywordDetected();
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