part of '../main.dart';

enum LoadState {
  Loading,
  Finish,
  Timeout,
}

class LoadMoreListSource extends LoadingMoreBase<int> {
  @override
  Future<bool> loadData([bool isloadMoreAction = false]) {
    return Future.delayed(Duration(seconds: 1), () {
      for (var i = 0; i < 10; i++) {
        this.add(0);
      }

      return true;
    });
  }
}

class ActivityChapter extends StatefulWidget {
  final Book book;
  final Chapter chapter;

  ActivityChapter(this.book, this.chapter);

  @override
  ChapterState createState() => ChapterState();
}

class ChapterState extends State<ActivityChapter> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController _pageController;
  int showIndex = 0;
  bool hasNextImage = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
        keepPage: false,
        initialPage: widget.book.chapters.indexOf(widget.chapter));
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: ChapterDrawer(
        book: widget.book,
        onTap: (chapter) {
          _pageController.jumpToPage(widget.book.chapters.indexOf(chapter));
        },
      ),
      body: PageView.builder(
          physics: AlwaysScrollableClampingScrollPhysics(),
          controller: _pageController,
          itemCount: widget.book.chapters.length,
          itemBuilder: (ctx, index) {
            return ChapterContentView(
              actions: [
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState.openEndDrawer();
                  },
                ),
              ],
              book: widget.book,
              chapter: widget.book.chapters[index],
            );
          }),
//      floatingActionButton: FloatingActionButton(
//        child: Text('下一章'),
//        onPressed: () {
//          if (hasNextChapter)
//            return openChapter(widget.book.chapters[chapterIndex + 1]);
//          Fluttertoast.showToast(msg: '已经是最后一章了');
//        },
//      ),
    );
  }
}

class ChapterDrawer extends StatefulWidget {
  final Book book;
  final void Function(Chapter chapter) onTap;

  const ChapterDrawer({
    Key key,
    @required this.book,
    @required this.onTap,
  }) : super(key: key);

  @override
  _ChapterDrawer createState() => _ChapterDrawer();
}

class _ChapterDrawer extends State<ChapterDrawer> {
  ScrollController _controller;
  int read;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    updateRead();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.jumpTo(WidgetChapter.height * read);
    });
  }

  void updateRead() {
    final readChapter = widget.book.chapters
        .firstWhere((chapter) => widget.book.history?.cid == chapter.cid);
    read = widget.book.chapters.indexOf(readChapter);
  }

  void scrollToRead() {
    setState(() {
      updateRead();
    });
    _controller.animateTo(
      WidgetChapter.height * read,
      duration: Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          controller: _controller,
          children: ListTile.divideTiles(
            context: context,
            tiles: widget.book.chapters.map((chapter) {
              final isRead = widget.book.history?.cid == chapter.cid;
              return WidgetChapter(
                chapter: chapter,
                onTap: (chapter) {
                  if (widget.onTap != null) widget.onTap(chapter);
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    scrollToRead();
                  });
                },
                read: isRead,
              );
            }),
          ).toList(),
        ),
      ),
    );
  }
}

class ChapterContentView extends StatefulWidget {
  final Book book;
  final Chapter chapter;
  final List<Widget> actions;

  const ChapterContentView({Key key, this.book, this.chapter, this.actions})
      : super(key: key);

  @override
  _ChapterContentView createState() => _ChapterContentView();
}

class _ChapterContentView extends State<ChapterContentView> {
  final GlobalKey<PullToRefreshNotificationState> _refresh = GlobalKey();
  final List<String> images = [];

  int chapterIndex = -1;
  bool hasNextChapter = false;

  @override
  initState() {
    super.initState();

    chapterIndex = widget.book.chapters.indexOf(widget.chapter);
    hasNextChapter = widget.book.chapters.last != widget.chapter;
    Data.addHistory(widget.book, widget.chapter);
    SchedulerBinding.instance.addPostFrameCallback((_) => _refresh?.currentState
        ?.show(notificationDragOffset: kToolbarHeight * 2));
  }

  Future<bool> fetchImages() async {
    print('fetchImages');
    setState(() {});
    images.clear();
    try {
      images.addAll(await UserAgentClient.instance
          .getImages(aid: widget.book.aid, cid: widget.chapter.cid)
          .timeout(const Duration(seconds: 5)));
      if (images.length < 5) {
        // print('图片 前：' + images.toString());
        var list = await checkImage(images.last);
        images.addAll(list);
      }
    } catch (e) {
      print('错误');
      return false;
      // throw(e);
    }
    // print('所有图片：' + images.toString());
    setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PullToRefreshNotification(
      key: _refresh,
      onRefresh: fetchImages,
      maxDragOffset: kToolbarHeight * 2,
      child: CustomScrollView(
        physics: AlwaysScrollableClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text(widget.chapter.cname),
            pinned: false,
            floating: true,
            actions: widget.actions,
          ),
          PullToRefreshContainer((info) => SliverPullToRefreshHeader(
                info: info,
                onTap: () => _refresh.currentState
                    .show(notificationDragOffset: kToolbarHeight * 2),
              )),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                (ctx, i) => Image.network(images[i]),
                childCount: images.length),
          ),
        ],
      ),
    );
  }
}

Future<dynamic> checkImage(String last) async {
  final response = new ReceivePort();
  await Isolate.spawn(_checkImage, response.sendPort);
  final sendPort = await response.first as SendPort;
  //接收消息的ReceivePort
  final answer = new ReceivePort();
  //发送数据
  sendPort.send([answer.sendPort, last]);
  return answer.first;
}

void _checkImage(SendPort initialReplyTo) {
  UserAgentClient.instance = UserAgentClient('chrome');
  final port = new ReceivePort();
  initialReplyTo.send(port.sendPort);
  port.listen((message) async {
    // 获取数据并解析
    final send = message[0] as SendPort;
    final last = message[1] as String;
    // 返回结果
    final uri = Uri.parse(last);
    // print({'scheme': uri.scheme, 'host': uri.host, 'path': uri.path});
    final a = uri.scheme + '://' + uri.host;
    final b = uri.pathSegments.take(uri.pathSegments.length - 1).join('/');
    // print({'a': a, 'b': b});
    //网址最后的图片文件名
    final file = uri.pathSegments.last.split('.');
    final fileName = file[0];
    // 图片格式
    final fileFormat = file[1];
    final list = <String>[];
    int plus = 1;
    //print('最后的图片：' + last);
    while (true) {
      final String file1 =
              getFileName(name: fileName, divider: '_', plus: plus),
          file2 = getFileName(name: fileName, divider: '_', plus: plus + 1);
      var url1 = '$a/$b/$file1.$fileFormat', url2 = '$a/$b/$file2.$fileFormat';
      // print('正在测试:\n' + url1 + '\n' + url2);
      final res = await Future.wait([
        UserAgentClient.instance.head(url1),
        UserAgentClient.instance.head(url2)
      ]);
      if (res[0].statusCode != 200) break;
      list.add(url1);
      if (res[1].statusCode != 200) {
        break;
      }
      list.add(url2);
      plus += 2;
    }
    // print('最后的图片数量: ' + number.toString());
    send.send(list);
  });
}

String getFileName(
    {@required String name, @required String divider, @required int plus}) {
  List<String> data = name.split(divider), newName = [];
  for (var i = 0; i < data.length; i++) {
    try {
      int number = int.parse(data[i]) + plus;
      newName.add(number.toString());
    } catch (e) {
      newName.add(data[i]);
    }
  }
  return newName.join(divider);
}
