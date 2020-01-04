import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:async/async.dart';
import 'package:draggable_container/draggable_container.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:package_info/package_info.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart'
    hide CircularProgressIndicator;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'classes/networkImageSSL.dart';

part './activities/book.dart';

part './activities/chapter.dart';

part './activities/checkData.dart';

part './activities/home.dart';

part './activities/recommend.dart';

part './activities/search.dart';

part './activities/test.dart';

part './classes/book.dart';

part './classes/data.dart';

part './classes/http.dart';

part './widgets/book.dart';

part './widgets/favorites.dart';

part './widgets/histories.dart';

part './widgets/pullToRefreshHeader.dart';

part './widgets/quick.dart';

part './widgets/sliverExpandableGroup.dart';

part './widgets/utils.dart';

part 'utils.dart';

FirebaseAnalytics analytics;
FirebaseAnalyticsObserver observer;

const bool isDevMode = !bool.fromEnvironment('dart.vm.product');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  UserAgentClient.init(
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36');
  runApp(Main(packageInfo: packageInfo));
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
    return DynamicTheme(
        defaultBrightness: Brightness.dark,
        data: (brightness) => new ThemeData(
              brightness: brightness,
            ),
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
            title: 'Flutter Demo',
            theme: theme,
            home: ActivityHome(widget.packageInfo),
          );
        });
//    return MaterialApp(
//      title: '微漫',
//      theme: ThemeData(
//        brightness: Brightness.light,
//      ),
//      darkTheme: ThemeData(
//        brightness: Brightness.dark,
//      ),
//      themeMode: ThemeMode.system,
//      debugShowCheckedModeBanner: false,
//      navigatorObservers: [observer],
//      home: ActivityHome(widget.packageInfo),
//    );
  }
}
