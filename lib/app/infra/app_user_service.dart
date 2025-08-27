import 'dart:convert';
import 'package:http/http.dart' as http;

class AppUserService {
  static const String baseUrl = "https://fccapi.ddns.net";

  static String? _appId;

  /// サーバーにユーザーデータを送信し、idを保持する
  static Future<void> sendUserData(String name, String lineUserId) async {
    final payload = {
      "name": name,
      "line_user_id": lineUserId,
    };

    final response = await http.post(
      Uri.parse("$baseUrl/get_id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _appId = data["id"].toString();
    } else {
      throw Exception("エラー: ${response.statusCode} ${response.body}");
    }
  }

  static String? getAppId() => _appId;

  static void resetAppId() {
    _appId = null;
  }
}
