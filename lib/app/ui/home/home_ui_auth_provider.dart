import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'home_ui_state.dart';

part 'home_ui_auth_provider.g.dart';

class AccountButtonData {
  final bool isLoggedIn;
  final String? pictureUrl;

  AccountButtonData({required this.isLoggedIn, this.pictureUrl});
}

@riverpod
class HomeUiAuth extends _$HomeUiAuth {
  @override
  LoggedInState build() => const LoggedInState();

  AccountButtonData get accountButtonData {
    return AccountButtonData(
      isLoggedIn: state.isLoggedIn,
      pictureUrl: state.pictureUrl,
    );
  }

  Future<void> login() async {
    try {
      final result = await LineSDK.instance.login();
      final profile = result.userProfile;
      // final displayName = profile.displayName;
      // final pictureUrl = profile.pictureUrl;
      print("ログイン成功: ${result.userProfile?.displayName}");
      state = state.copyWith(
        isLoggedIn: true,
        pictureUrl: profile?.pictureUrl,
      );
      // -------------ToDo-------------
      // httpリクエストでIDを取得(https://fccapi.ddns.net/get_id)
    } catch (e) {
      print("ログイン失敗: $e");
      state = state.copyWith(isLoggedIn: false, pictureUrl: null);
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
