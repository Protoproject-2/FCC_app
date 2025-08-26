// ui描画
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'home_ui_view_model.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

class HomeUI extends ConsumerWidget {
  const HomeUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeUiViewModelProvider);
    final viewModel = ref.read(homeUiViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('悲鳴検知アプリ')),
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
                onPressed: () {
              const lineInviteUrl = 'https://lin.ee/abc1234'; // TODO: 実際のLINE登録URLに差し替えてください
              _showLineQrDialog(context, ref, lineInviteUrl);
            }),
            _buildActionButton(Icons.add, 'LINEアカウントでログイン', 
                onPressed: () async {
              try {
                // LINEログイン画面を表示
                final result = await LineSDK.instance.login(scopes: ["profile", "openid", "email"]);
                
                final accessToken = await LineSDK.instance.currentAccessToken;

                final userEmail = result.accessToken.email;
                // ログイン成功時
                print("ログイン成功: ${result.userProfile?.displayName}");
                // ここで result.accessToken なども利用可能
              } catch (e) {
                // ログイン失敗時
                print("ログインエラー: $e");
              }
            }),
            const Spacer(),
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
        backgroundColor: Colors.lightBlueAccent.withOpacity(0.3),
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
        backgroundColor: Colors.greenAccent.withOpacity(0.3),
      ),
    ),
  );
}