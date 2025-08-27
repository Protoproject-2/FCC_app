import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'home_ui_state.dart'; // LoggedInStateを参照

part 'home_ui_auth_provider.g.dart';

@riverpod
class HomeUiAuth extends _$HomeUiAuth {
  @override
  LoggedInState build() => const LoggedInState();

  Future<void> login() async {
    try {
      final result = await LineSDK.instance.login();
      print("ログイン成功: ${result.userProfile?.displayName}");
      state = state.copyWith(isLoggedIn: true);
    } catch (e) {
      print("ログイン失敗: $e");
      state = state.copyWith(isLoggedIn: false);
    }
  }

  Future<void> logout() async {
    try {
      await LineSDK.instance.logout();
      print("ログアウト成功");
      state = state.copyWith(isLoggedIn: false);
    } catch (e) {
      print("ログアウト失敗: $e");
    }
  }
}
