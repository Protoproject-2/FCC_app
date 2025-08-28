// ui描画
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'home_ui_view_model.dart';
import 'home_ui_auth_provider.dart';
import 'home_ui_user_list_provider.dart';
import '../../infra/app_user_service.dart';
import '../../infra/invite_user_service.dart';

class HomeUI extends ConsumerWidget {
  const HomeUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeUiViewModelProvider);
    final viewModel = ref.read(homeUiViewModelProvider.notifier);
    final authState = ref.watch(homeUiAuthProvider);
    final authVm = ref.read(homeUiAuthProvider.notifier);
    final accountData = AccountButtonData(isLoggedIn: authState.isLoggedIn, pictureUrl: authState.pictureUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('悲鳴検知アプリ'),
        backgroundColor: Colors.lightBlueAccent.withValues(alpha: 0.3),
        actions: [
          _buildAccountButton(
            accountData,
            onTap: () async {
              if (accountData.isLoggedIn) {
                await authVm.logout();
              } else {
                await authVm.login();
                final userId = int.tryParse(AppUserService.getAppId() ?? "0") ?? 0;
                await ref.read(userListProvider.notifier).testRefreshList(userId);
              }
            },
          ),
          const SizedBox(width: 8), 
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 中央のON/OFFボタン
            const SizedBox(height: 32),
            GestureDetector(
              onTap: viewModel.toggleDetection,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: state.isDetecting ? Colors.redAccent : Colors.grey[300],
                child: Text(
                  state.isDetecting ? '停止' : 'ここを押して\nON/OFF',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: state.isDetecting ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            // if(state.isDetecting){
            //   // popup表示
            // }
            const SizedBox(height: 24),
            _buildActionButton(Icons.person, '連絡先登録', onPressed: () {}),
            _buildActionButton(Icons.add, '合言葉登録', onPressed: () {}),
            // LINEpopupナビゲーション
            _buildFloatingActionButton(Icons.share, 'LINE登録URL共有ボタン',
                onPressed: () async {
              try {
                final userId = int.tryParse(AppUserService.getAppId() ?? "0") ?? 0;
                await InviteService.fetchInviteUrl(userId);

                // 取得した招待リンクを使う
                final url = InviteService.inviteUrl;
                if (url != null) {
                  print("取得した招待リンク: $url");
                  _showLineQrDialog(context, ref, url);
                } else {
                  print("招待リンクが取得できませんでした");
                }
              } catch (e) {
                print("エラー: $e");
              }
            }),
            const Spacer(),
            EmergencyTestButton(),
            _BuildUpdateButton(context, ref),
            _UserListWidget(height: 200,),
            // 合言葉のスイッチ
            ...state.keywordToggles.map((toggle) {
              return SwitchListTile(
                title: Text(toggle.keyword),
                value: toggle.isActive,
                onChanged: (_) => viewModel.toggleKeyword(toggle.keyword),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

void _showLineQrDialog(BuildContext context, WidgetRef ref, String url) {
  ref.read(homeUiViewModelProvider.notifier).createLineQrCode(url);

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('LINE登録URL'),
        content: Consumer(
          builder: (context, ref, child) {
            final qrCodeUrl = ref.watch(homeUiViewModelProvider).qrCodeUrl;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // QRコード画像（外部APIで生成）
                if (qrCodeUrl != null)
                  Image.network(
                    qrCodeUrl,
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                  )
                else
                  const CircularProgressIndicator(),
                const SizedBox(height: 12),
                // URLの表示＆コピー
                SelectableText(
                  url,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: url));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URLをコピーしました')),
                );
              }
            },
            child: const Text('コピー'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('閉じる'),
          ),
        ],
      );
    },
  );
}

Widget _buildActionButton(IconData icon, String label, {required VoidCallback onPressed}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: Colors.lightBlueAccent.withValues(alpha: 0.3),
      ),
    ),
  );
}

Widget _buildFloatingActionButton(IconData icon, String label, {required VoidCallback onPressed}) {
  // Column内でレイアウトしやすいように、実体は拡張ボタン風にする
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: Colors.greenAccent.withValues(alpha: 0.3),
      ),
    ),
  );
}

Widget _buildAccountButton(AccountButtonData data, {required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.lightBlueAccent.withValues(alpha: 0.3),
          backgroundImage: data.isLoggedIn && data.pictureUrl != null
              ? NetworkImage(data.pictureUrl!)
              : null,
          child: data.isLoggedIn && data.pictureUrl != null
              ? null
              : const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 4),
        Text(
          data.isLoggedIn ? 'ログアウト' : 'ログイン',
          style: const TextStyle(color: Colors.black),
        ),
      ],
    ),
  );
}

class _UserListWidget extends ConsumerWidget {
  const _UserListWidget({this.height = 300});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userListProvider);
    final notifier = ref.read(userListProvider.notifier);

    return SizedBox(
      height: height,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return SwitchListTile(
                title: Text(user.name),
                value: user.isSelected,
                onChanged: (_) => notifier.toggle(user.id),
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget _BuildUpdateButton(BuildContext context, WidgetRef ref) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("リストを更新"),
          onPressed: () async {
            final userId = int.tryParse(AppUserService.getAppId() ?? "0") ?? 0;
            await ref.read(userListProvider.notifier).testRefreshList(userId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("ユーザーリストを更新しました")),
            );
          },
        ),
      ],
    ),
  );
}

// test用。終わったら消す
class EmergencyTestButton extends ConsumerWidget {
  const EmergencyTestButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        // notifier を取得
        final notifier = ref.read(userListProvider.notifier);

        // 選択されているユーザーIDだけを取得
        final selectedIds = notifier.selectedIds;

        final userId = int.tryParse(AppUserService.getAppId() ?? "0") ?? 0;

        // provider の関数を実行
        // notifier.testSendEmergency(userId, selectedIds);
        ref.read(userListProvider.notifier).testSendEmergency(userId, selectedIds);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("送信処理を実行しました")),
        );
      },
      child: const Text("緊急送信テスト"),
    );
  }
}