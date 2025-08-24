import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider: どこからでも通知サービスを取得できるようにする
final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});

/// ローカル通知サービス（Android向け最小構成）
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// 初期化（Androidの通知チャンネル作成を含む）
  Future<void> initialize() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);

    // Android の通知チャンネル作成（API 26+）
    const channel = AndroidNotificationChannel(
      'keyword_channel',
      'Keyword Detection',
      description: '通知: 合言葉検知',
      importance: Importance.max,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Android 13+ の通知権限をリクエストしてログを出す
  Future<void> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    // 呼び出しログ
    // ignore: avoid_print
    print('[Notif] requestPermissions() called');
    final granted = await android?.requestNotificationsPermission();
    // ignore: avoid_print
    print('[Notif] request result: granted=$granted');
    final enabled = await android?.areNotificationsEnabled();
    // ignore: avoid_print
    print('[Notif] current enabled state: $enabled');
  }

  /// 現在の通知有効状態をログ出力
  Future<void> logNotificationStatus() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final enabled = await android?.areNotificationsEnabled();
    // ignore: avoid_print
    print('[Notif] areNotificationsEnabled -> $enabled');
  }

  /// 「合言葉を検知しました」の通知を表示
  Future<void> showKeywordDetectedNotification() async {
    // ignore: avoid_print
    print('[Notif] showKeywordDetectedNotification()');

    const androidDetails = AndroidNotificationDetails(
      'keyword_channel',
      'Keyword Detection',
      channelDescription: '通知: 合言葉検知',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      0,
      '合言葉を検知しました',
      '指定された合言葉が検出されました。',
      details,
      payload: 'keyword_detected',
    );
    // ignore: avoid_print
    print('[Notif] show() dispatched');
  }

  /// 初期化→権限→通知を一括実行（安全側）
  Future<void> ensureAndNotifyKeywordDetected() async {
    await initialize();
    await requestPermissions();
    await showKeywordDetectedNotification();
  }

  /// 初期化→権限→状態ログ→通知（手元確認用）
  Future<void> ensureAndLogAndNotify() async {
    await initialize();
    await requestPermissions();
    await logNotificationStatus();
    await showKeywordDetectedNotification();
  }
}
