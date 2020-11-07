import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weiman/activities/dataConvert.dart';
import 'package:weiman/db/setting.dart';
import 'package:weiman/provider/theme.dart';

import 'package:weiman/activities/checkData.dart';
import 'package:weiman/activities/hot.dart';
import 'package:weiman/activities/search/search.dart';
import 'package:weiman/activities/test2.dart';
import 'package:weiman/classes/book.dart';
import 'package:weiman/main.dart';
import 'package:weiman/provider/favoriteData.dart';
import 'package:weiman/widgets/checkConnect/checkConnect.dart';
import 'package:weiman/widgets/favorites.dart';
import 'package:weiman/widgets/histories.dart';
import 'package:weiman/widgets/quick.dart';
import 'checkDB.dart';
import 'setting/setting.dart';

class ActivityHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<ActivityHome> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Widget> histories = [];
  final List<Book> quick = [];
  final GlobalKey<QuickState> _quickState = GlobalKey();

  bool showFavorite = true;

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: '/activity_home');

    /// 提前检查一次藏书的更新情况
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      autoSwitchTheme();
      FavoriteData favData = Provider.of<FavoriteData>(context, listen: false);
      await favData.loadBooksList();
      final updated = await favData.checkUpdate();
      if (updated > 0)
        showToast(
          '$updated 本藏书有更新',
          textPadding: EdgeInsets.all(10),
        );
    });
  }

  void autoSwitchTheme() async {}

  void gotoSearch() {
    Navigator.push(
        context,
        MaterialPageRoute(
            settings: RouteSettings(name: '/activity_search'),
            builder: (context) => ActivitySearch()));
  }

  void gotoRecommend() {
    Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: '/activity_recommend'),
          builder: (_) => ActivityRank(),
        ));
  }

  void gotoPatreon() {
    launch('https://www.patreon.com/nrop19');
  }

  bool isEdit = false;

  void _draggableModeChanged(bool mode) {
    print('mode changed $mode');
    isEdit = mode;
    setState(() {});
  }

  Widget themeButton() {
    final system = FontAwesomeIcons.cloudSun,
        light = FontAwesomeIcons.solidSun,
        dark = FontAwesomeIcons.solidMoon;
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    Widget themeIcon;
    switch (theme.themeMode) {
      case ThemeMode.light:
        themeIcon = Icon(light);
        break;
      case ThemeMode.dark:
        themeIcon = Icon(dark);
        break;
      default:
        themeIcon = Icon(system);
        break;
    }
    return IconButton(
      onPressed: () {
        switch (theme.themeMode) {
          case ThemeMode.light:
            theme.changeTheme(ThemeMode.dark);
            break;
          case ThemeMode.dark:
            theme.changeTheme(ThemeMode.system);
            break;
          default:
            theme.changeTheme(ThemeMode.light);
        }
        Provider.of<Setting>(context, listen: false)
            .setThemeMode(theme.themeMode);
        showToastWidget(
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.black.withOpacity(0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    system,
                    size: 14,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text('跟随系统，自动切换明暗模式\n如果系统不支持，默认为明亮模式'),
                ]),
                SizedBox(height: 10),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    light,
                    size: 14,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text('为明亮模式'),
                ]),
                SizedBox(height: 10),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    dark,
                    size: 14,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text('为暗黑模式'),
                ]),
              ],
            ),
          ),
          dismissOtherToast: true,
          duration: Duration(seconds: 4),
        );
      },
      icon: themeIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = (media.size.width * 0.8).roundToDouble();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('微漫 v' + packageInfo.version),
        automaticallyImplyLeading: false,
        leading: isEdit
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  _quickState.currentState.exit();
                },
              )
            : null,
        actions: <Widget>[
          /// 黑白样式切换
          themeButton(),
          SizedBox(width: 20),

          /// 设置界面
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: RouteSettings(name: '/activity_setting'),
                      builder: (_) => ActivitySetting()));
            },
            icon: Icon(FontAwesomeIcons.cog),
          ),

          /// 收藏列表
          IconButton(
            onPressed: () {
              showFavorite = true;
              _scaffoldKey.currentState.openEndDrawer();
            },
            icon: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
          ),

          /// 浏览历史列表
          IconButton(
            onPressed: () {
              showFavorite = false;
              // getHistory();
              _scaffoldKey.currentState.openEndDrawer();
            },
            icon: Icon(Icons.history),
          ),
        ],
      ),
      drawerEnableOpenDragGesture: false,
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Drawer(
        child: LayoutBuilder(
          builder: (_, constraints) {
            if (showFavorite) {
              return FavoriteList();
            } else {
              return Histories();
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                child: OutlineButton(
                  onPressed: gotoSearch,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.search,
                        color: Colors.blue,
                      ),
                      Text(
                        '搜索漫画',
                        style: TextStyle(color: Colors.blue),
                      )
                    ],
                  ),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                  shape: StadiumBorder(),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: OutlineButton(
                      onPressed: gotoRecommend,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.whatshot,
                            color: Colors.red,
                          ),
                          Text(
                            '热门漫画',
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                      shape: StadiumBorder(),
                    ),
                  ),
                ],
              ),
              Center(
                child: Quick(
                  key: _quickState,
                  width: width,
                  draggableModeChanged: _draggableModeChanged,
                ),
              ),
              CheckConnectWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      launch('https://bbs.level-plus.net/');
                    },
                    child: Text(
                      '魂+论坛首发',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue[200],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () async {
                      if (await canLaunch('tg://resolve?domain=weiman_app'))
                        launch('tg://resolve?domain=weiman_app');
                      else
                        launch('https://t.me/weiman_app');
                    },
                    child: Text(
                      'Telegram 广播频道',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue[200],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: isDevMode,
                child: FlatButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ActivityCheckData()));
                  },
                  child: Text('操作 收藏列表数据'),
                ),
              ),
              Visibility(
                visible: isDevMode,
                child: FlatButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ActivityCheckDB()));
                  },
                  child: Text('操作 DB数据'),
                ),
              ),
              Visibility(
                visible: isDevMode,
                child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ActivityDataConvert()));
                  },
                  child: Text('进入旧数据处理功能'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isDevMode
          ? FloatingActionButton(
              child: Text('测试'),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ActivityTest()));
              },
            )
          : null,
    );
  }
}
