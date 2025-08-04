import 'package:fcc/app/ui/home/home_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      // Use addons to customize the behavior of Widgetbook
      addons: [
        // Add Material 3 theme
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Light',
              data: ThemeData.light(),
            ),
            WidgetbookTheme(
              name: 'Dark',
              data: ThemeData.dark(),
            ),
          ],
        ),
      ],
      directories: [
        WidgetbookComponent(
          name: 'HomeUi',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => const ProviderScope(child: HomeUi()),
            ),
          ],
        ),
      ],
      
    );
  }
}