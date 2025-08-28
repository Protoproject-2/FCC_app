import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ui/home/home_ui_state.dart'; 
import '../ui/home/home_ui_user_list_provider.dart'; 

/// ON のユーザーだけを抽出して Flask サーバーに送信する関数
Future<void> sendEmergency(int userId, List<int> selectedIds) async {
  const baseUrl = "https://fccapi.ddns.net";
  const message = "テスト緊急メッセージです！";

  if (selectedIds.isEmpty) {
    print("ON のユーザーがいません");
    return;
  }

  final payload = {
    "user_id": userId,
    "contact_ids": selectedIds,
    "message": message,
  };
  print("payload = ");
  print(payload);

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/send_emergency'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("送信成功: $data");
    } else {
      print("送信失敗: ${response.statusCode}, ${response.body}");
    }
  } catch (e) {
    print("エラー: $e");
  }
}
