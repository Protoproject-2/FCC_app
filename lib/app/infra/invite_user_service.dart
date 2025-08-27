import 'dart:convert';
import 'package:http/http.dart' as http;

class InviteService {
  static const String baseUrl = "https://fccapi.ddns.net";

  // 生成した招待リンクを保持する変数
  static String? _inviteUrl;

  /// 指定ユーザーIDの招待リンクを取得
  static Future<void> fetchInviteUrl(int userId) async {
    final uri = Uri.parse("$baseUrl/generate_invite/$userId");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _inviteUrl = data["invite_url"] as String?;
      print("data = $data");
      print("招待リンク: $_inviteUrl");
    } else {
      throw Exception("エラー: ${response.statusCode} ${response.body}");
    }
  }

  /// 生成した招待リンクを取得するゲッター
  static String? get inviteUrl => _inviteUrl;

  /// 必要ならリセットするメソッド
  static void reset() {
    _inviteUrl = null;
  }
}