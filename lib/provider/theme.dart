import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weiman/db/setting.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system; // 主题模式

  ThemeProvider(BuildContext context) {
    themeMode = Provider.of<Setting>(context, listen: false).getThemeMode();
  }

  void changeTheme(ThemeMode mode) {
    print('改变主题 $mode');
    themeMode = mode;
    notifyListeners();
  }

  void update(BuildContext context) {
    final bright = MediaQuery.platformBrightnessOf(context);
    switch (bright) {
      case Brightness.light:
        changeTheme(ThemeMode.light);
        break;
      case Brightness.dark:
        changeTheme(ThemeMode.dark);
    }
    print('update $bright');
  }
}
