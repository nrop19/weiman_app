import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:weiman/activities/dataConvert.dart';
import 'package:weiman/activities/home.dart';
import 'package:weiman/classes/data.dart';
import 'package:weiman/db/book.dart';
import 'package:weiman/db/group.dart';
import 'package:weiman/db/historyOffset.dart';
import 'package:weiman/db/setting.dart';
import 'package:weiman/provider/favoriteData.dart';
import 'package:weiman/provider/theme.dart';

FirebaseAnalytics analytics;
FirebaseAnalyticsObserver observer;

const bool isDevMode = false;

int version;
BoxDecoration border;

Directory imageCacheDir;
String imageCacheDirPath;
PackageInfo packageInfo;

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {};
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
    Hive.initFlutter(),
    Data.init(),
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
  ]);
  Hive.registerAdapter<Group>(GroupAdapter());
  Hive.registerAdapter<Book>(BookAdapter());
  await Future.wait([
    Hive.openBox<Group>(GroupName).then((value) => Group.groupBox = value),
    Hive.openBox<Book>(BookName)
        .then((value) => Book.bookBox = Group.bookBox = value),
    Hive.openBox(HistoryOffsetName).then((value) => HistoryOffset.box = value),
    Hive.openBox(Setting.name).then((value) => Setting.settingBox = value),
  ]);
  packageInfo = await PackageInfo.fromPlatform();
  version = int.parse(packageInfo.buildNumber);
  runApp(Main());
}

class Main extends StatefulWidget {
  @override
  _Main createState() => _Main();
}

class _Main extends State<Main> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    Provider.of<ThemeProvider>(context, listen: false).update(context);
  }

  @override
  Widget build(BuildContext context) {
    border = BoxDecoration(
        border: Border(
            bottom: Divider.createBorderSide(context, color: Colors.grey)));
    return OKToast(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<Setting>(
            lazy: false,
            create: (_) => Setting(),
          ),
          ChangeNotifierProvider<FavoriteData>(
            lazy: false,
            create: (_) => FavoriteData(),
          ),
          ChangeNotifierProvider<ThemeProvider>(
            lazy: true,
            create: (_) => ThemeProvider(_),
          ),
        ],
        child: Consumer<ThemeProvider>(
          builder: (_, theme, __) => MaterialApp(
            title: '微漫 v${packageInfo.version}',
            themeMode: theme.themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              accentColor: Colors.redAccent,
            ),
            home: Data.hasData() ? ActivityDataConvert() : ActivityHome(),
            // home: ActivityHome(),
            debugShowCheckedModeBanner: isDevMode,
            navigatorObservers: <NavigatorObserver>[observer],
          ),
        ),
      ),
    );
  }
}
