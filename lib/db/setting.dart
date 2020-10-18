import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:weiman/crawler/http.dart';
import 'package:weiman/crawler/http18Comic.dart';

enum HideOption {
  none,
  auto,
  always,
}

class Setting with ChangeNotifier {
  static final String name = 'setting';
  static Box settingBox;
  Http18Comic http;

  Setting() {
    MyHttpClient.init(getProxy(), 10000);
  }

  HideOption getHideOption() {
    final index =
        settingBox.get('hideOption', defaultValue: HideOption.auto.index);
    return HideOption.values[index];
  }

  Future setHideOption(HideOption option) async {
    await settingBox.put('hideOption', option.index);
    notifyListeners();
  }

  String getProxy() {
    print('getProxy');
    return settingBox.get('proxy', defaultValue: null);
  }

  Future setProxy(String proxy) async {
    print('db/setting.setProxy $proxy');
    await settingBox.put('proxy', proxy);
    MyHttpClient.init(proxy, 10000);
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    final int index = settingBox.get('theme', defaultValue: -1);
    if (index == -1) return ThemeMode.system;
    return ThemeMode.values[index];
  }

  Future setThemeMode(ThemeMode mode) {
    return settingBox.put('theme', mode.index);
  }

  void refresh() {
    notifyListeners();
  }

  Http18Comic getHttp() {
    final String name =
        settingBox.get('http', defaultValue: baseUrls.keys.first);
    final http = Http18Comic(baseUrls[name], name: name, headers: headers);
    setProxy(getProxy());
    return http;
  }

  Future setHttp(HttpBook http) async {
    await settingBox.put('http', http.name);
    notifyListeners();
  }

  bool getViewerSwitch() {
    return settingBox.get('viewerSwitch', defaultValue: true);
  }

  Future setViewerSwitch(bool value) async {
    await settingBox.put('viewerSwitch', value);
    notifyListeners();
  }
}
