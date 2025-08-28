import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'home_ui_state.dart';
import '../../infra/contact_list_service.dart';
import '../../infra/emergency_service.dart'; // 緊急通知テスト用
import 'package:geolocator/geolocator.dart'; // 緊急通知テスト用

part 'home_ui_user_list_provider.g.dart';

@riverpod
class UserList extends _$UserList {
  @override
  List<User> build() {
    // 初期ユーザーリスト
    return _initialUsers();
  }

  // 初期ユーザーリスト
  List<User> _initialUsers() => const [
        User(id: 1, name: '緊急連絡できる友達を追加しましょう!'),
      ];

  // トグル切替
  void toggle(int userId) {
    state = [
      for (final user in state)
        if (user.id == userId)
          user.copyWith(isSelected: !user.isSelected)
        else
          user,
    ];
  }

  // list更新。
  Future<void> testRefreshList(int userId) async {
    try {
      final fetchedUsers = await ContactListService.fetchContacts(userId);

      if (fetchedUsers.isEmpty) {
        // 空の場合は初期リストに戻す
        state = _initialUsers();
        return;
      }

      // 既存の isSelected 状態を保持して更新
      state = fetchedUsers.map((user) {
        final oldUser = state.firstWhere(
          (u) => u.id == user.id,
          orElse: () => user,
        );
        return user.copyWith(isSelected: oldUser.isSelected);
      }).toList();

    } catch (e) {
      print("ユーザーリスト更新失敗: $e");
    }
  }

  // -----緊急通知テスト用。何かと便利なので消さないで---
  // void testSendEmergency(int userId, List<int> selectedIds) {
  //   Position position;
    
  //   Future(() async {
  //     try {
  //       // 権限確認 & 要求
  //       LocationPermission permission = await Geolocator.checkPermission();
  //       if (permission == LocationPermission.denied) {
  //         permission = await Geolocator.requestPermission();
  //         if (permission == LocationPermission.denied) {
  //           print("位置情報の権限が拒否されました");
  //           return;
  //         }
  //       }

  //       if (permission == LocationPermission.deniedForever) {
  //         print("位置情報の権限が永続的に拒否されています");
  //         return;
  //       }

  //       position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //     } catch (e) {
  //       print("位置情報取得エラー: $e");
  //       return;
  //     }
      
  //     await sendEmergency(userId, selectedIds, position.latitude, position.longitude);
  //   });
  // }
  // ------------------------------
  Future<void> testSendEmergency(int userId, List<int> selectedIds) async {
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

      // dispose 済みなら中断
      if (!ref.mounted) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!ref.mounted) return;

      await sendEmergency(userId, selectedIds, position.latitude, position.longitude);
    } catch (e) {
      print("位置情報取得エラー: $e");
    }
  }



  // ON のユーザーIDリストを返す
  List<int> get selectedIds =>
      state.where((u) => u.isSelected).map((u) => u.id).toList();
}
