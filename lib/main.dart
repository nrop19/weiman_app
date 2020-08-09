import 'dart:async';
import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'activities/home.dart';
import 'activities/setting/setting.dart';
import 'classes/data.dart';
import 'widgets/favorites.dart';

FirebaseAnalytics analytics;
FirebaseAnalyticsObserver observer;

const bool isDevMode = !bool.fromEnvironment('dart.vm.product');

int version;
BoxDecoration border;

Directory imageCacheDir;
String imageCacheDirPath;

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {};
  WidgetsFlutterBinding.ensureInitialized();

  getTemporaryDirectory().then((dir) {
    imageCacheDir = Directory(path.join(dir.path, 'images'));
    imageCacheDirPath = imageCacheDir.path;
    if (imageCacheDir.existsSync() == false) imageCacheDir.createSync();
    print('图片缓存目录 $imageCacheDirPath');
  });

  try {
    analytics = FirebaseAnalytics();
    observer = FirebaseAnalyticsObserver(analytics: analytics);
  } catch (e) {}

  await Future.wait([
    Data.init(),
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
  ]);
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  version = int.parse(packageInfo.buildNumber);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingData>(
          create: (_) => SettingData(),
          lazy: false,
        ),
        ChangeNotifierProvider<FavoriteData>(
            create: (_) => FavoriteData(), lazy: false),
      ],
      child: Main(packageInfo: packageInfo),
    ),
  );
}

class Main extends StatefulWidget {
  final PackageInfo packageInfo;

  const Main({Key key, this.packageInfo}) : super(key: key);

  @override
  _Main createState() => _Main();
}

class _Main extends State<Main> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    border = BoxDecoration(
        border: Border(
            bottom: Divider.createBorderSide(context, color: Colors.grey)));
    return DynamicTheme(
        defaultBrightness: Brightness.dark,
        data: (brightness) => new ThemeData(
              brightness: brightness,
            ),
        themedWidgetBuilder: (context, theme) {
          return OKToast(
            child: MaterialApp(
              title: '微漫 v${widget.packageInfo.version}',
              theme: theme,
              home: ActivityHome(widget.packageInfo),
              debugShowCheckedModeBanner: isDevMode,
            ),
          );
        });
  }
}
