import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'home_ui_state.dart';
import '../../infra/app_user_service.dart';

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
      final pictureUrl = result.userProfile?.pictureUrl;

      state = state.copyWith(
        isLoggedIn: true,
        pictureUrl: pictureUrl,
      );
      print('ログイン成功: ${result.userProfile?.displayName}');
    } catch (e) {
      print('ログイン失敗: $e');
      state = state.copyWith(
        isLoggedIn: false,
        pictureUrl: null,
      );
    }
  }

  Future<void> logout() async {
    try {
      await LineSDK.instance.logout();
      print("ログアウト成功");
      state = state.copyWith(isLoggedIn: false, pictureUrl: null);
      AppUserService.resetAppId();
    } catch (e) {
      print("ログアウト失敗: $e");
    }
  }
}
