part of '../main.dart';

class ActivityHome extends StatefulWidget {
  final PackageInfo packageInfo;

  const ActivityHome(this.packageInfo, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<ActivityHome> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Widget> histories = [];
  final List<Book> quick = [];
  final GlobalKey<QuickState> _quickState = GlobalKey();
  static final weekTime = 7 * 24 * 3600000;

  bool showFavorite = true;

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: '/activity_home');

    /// 提前检查一次藏书的更新情况
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      autoSwitchTheme();
      _FavoriteList.getBooks();
      await _FavoriteList.checkNews();
      final updated = _FavoriteList.hasNews.values
          .where((int updatedChapters) => updatedChapters > 0)
          .length;
      if (updated > 0)
        showToast(
          '$updated 本藏书有更新',
          backgroundColor: Colors.black.withOpacity(0.5),
        );
    });
  }

  void autoSwitchTheme() async {
    final isDark = await DynamicTheme.of(context).loadBrightness();
    final nowIsDark = DynamicTheme.of(context).brightness == Brightness.dark;
    if (isDark != nowIsDark)
      DynamicTheme.of(context)
          .setBrightness(isDark ? Brightness.dark : Brightness.light);
  }

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
          settings: RouteSettings(name: '/activity_recommend/'),
          builder: (_) => ActivityRank(),
        ));
  }

  bool isEdit = false;

  void _draggableModeChanged(bool mode) {
    print('mode changed $mode');
    isEdit = mode;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = (media.size.width * 0.8).roundToDouble();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('微漫 v' + widget.packageInfo.version),
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
          IconButton(
            onPressed: () {
              DynamicTheme.of(context).setBrightness(
                  Theme.of(context).brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark);
            },
            icon: Icon(Theme.of(context).brightness == Brightness.light
                ? FontAwesomeIcons.lightbulb
                : FontAwesomeIcons.solidLightbulb),
          ),
          SizedBox(width: 20),

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
      endDrawer: Drawer(
        child: LayoutBuilder(
          builder: (_, __) {
            if (showFavorite) {
              return FavoriteList();
            } else {
              return Histories();
            }
          },
        ),
      ),
      body: Container(
        alignment: Alignment.center,
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
                          '月排行榜',
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
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text(
                '在 level-plus.net 论坛首发',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (await canLaunch('tg://resolve?domain=weiman_app'))
                  launch('tg://resolve?domain=weiman_app');
                else
                  launch('https://t.me/weiman_app');
              },
              child: Text(
                'Telegram广播频道',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue[200],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Visibility(
              visible: isDevMode,
              child: FlatButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ActivityTest()));
                },
                child: Text('测试界面'),
              ),
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
          ],
        ),
      ),
    );
  }
}
