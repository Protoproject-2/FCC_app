// ui描画
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_ui_view_model.dart';

class HomeUi extends ConsumerWidget {
  const HomeUi({super.key});

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
                backgroundColor: Colors.grey[300],
                child: Text(
                  state.isDetecting ? '停止' : 'ここを押して\nON/OFF',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // アクションボタン3つ(ViewModelは未登録なので空)
            _buildActionButton(Icons.person, '連絡先登録', onPressed: () {}),
            _buildActionButton(Icons.chat, 'チャット', onPressed: () {}),
            _buildActionButton(Icons.add, '合言葉登録', onPressed: () {}),
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