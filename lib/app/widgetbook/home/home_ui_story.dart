// HomeuiのStory
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../ui/home/home_ui.dart';

final homeUiStory = WidgetbookComponent(
  name: 'HomeUi',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => const ProviderScope(child: HomeUi()),
    ),
  ],
);