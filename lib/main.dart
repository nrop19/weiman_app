import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:draggable_container/draggable_container.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:extended_image/extended_image.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:flutter/painting.dart' as image_provider;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:focus_widget/focus_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http_client_helper/http_client_helper.dart';
import 'package:loadmore/loadmore.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart'
    hide CircularProgressIndicator;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:url_launcher/url_launcher.dart';

part './activities/book.dart';

part './activities/chapter.dart';

part './activities/checkData.dart';

part './activities/home.dart';

part './activities/rank.dart';

part './activities/search.dart';

part './activities/setting.dart';

part './activities/test.dart';

part './classes/book.dart';

part './classes/data.dart';

part './classes/networkImageSSL.dart';

part './crawler/hhmh39.dart';

part './crawler/http.dart';

part './crawler/httpHanManJia.dart';

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
  FlutterError.onError = (FlutterErrorDetails details) {};
  WidgetsFlutterBinding.ensureInitialized();

  try {
    analytics = FirebaseAnalytics();
    observer = FirebaseAnalyticsObserver(analytics: analytics);
  } catch (e) {}

  await Future.wait([
    Data.init(),
    Book.initCachePath(),
    MyHttpClient.init(),
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
  ]);
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingData>(create: (_) => SettingData()),
        ChangeNotifierProvider<FavoriteData>(create: (_) => FavoriteData()),
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
  static BoxDecoration _border;

  @override
  initState() {
    super.initState();
    HttpClientHelper().set(HttpHHMH39.instance.inner);
  }

  @override
  Widget build(BuildContext context) {
    if (_border == null)
      _border = BoxDecoration(
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
            ),
          );
        });
  }
}
