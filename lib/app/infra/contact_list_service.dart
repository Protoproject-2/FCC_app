import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ui/home/home_ui_state.dart';

class ContactListService {
  static const _baseUrl = "https://fccapi.ddns.net";

  // 指定 userId の連絡先リストを取得
  static Future<List<User>> fetchContacts(int userId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/get_contactable_user'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch contacts: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final contactsJson = data['contacts'] as List;

    return contactsJson.map((json) => User(
      id: json['contact_id'],
      // name: json['display_name'] ?? 'Unknown', // NULL 補完
      name: json['display_name'], 
    )).toList();
  }
}
