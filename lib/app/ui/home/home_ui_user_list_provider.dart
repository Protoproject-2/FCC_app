import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'home_ui_state.dart';
import '../../infra/contact_list_service.dart';

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

  // ON のユーザーIDリストを返す
  List<int> get selectedIds =>
      state.where((u) => u.isSelected).map((u) => u.id).toList();
}
