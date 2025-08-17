
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fcc/app/infra/audio_service.dart';
import 'home_ui_state.dart';

part 'home_ui_view_model.g.dart';

@riverpod
class HomeUiViewModel extends _$HomeUiViewModel {
  @override
  HomeUiState build() {
    // Listen to the isRecordingProvider to update the state accordingly
    ref.listen<bool>(isRecordingProvider, (previous, next) {
      state = state.copyWith(isDetecting: next);
    });

    // Initial state
    return const HomeUiState(
      isDetecting: false, // Start with detection off
      keywordToggles: [
        KeywordToggle(keyword: '助けて', isActive: true),
        KeywordToggle(keyword: 'きゃー', isActive: false),
        KeywordToggle(keyword: '泥棒', isActive: true),
      ],
    );
  }

  /// Toggles the audio detection ON/OFF
  void toggleDetection() {
    final audioService = ref.read(audioServiceProvider);
    if (state.isDetecting) {
      audioService.stopRecording();
    } else {
      audioService.startRecording();
    }
  }

  /// Toggles the active state of a specific keyword
  void toggleKeyword(String keyword) {
    final toggles = state.keywordToggles.map((toggle) {
      if (toggle.keyword == keyword) {
        return toggle.copyWith(isActive: !toggle.isActive);
      }
      return toggle;
    }).toList();

    state = state.copyWith(keywordToggles: toggles);
  }
}
