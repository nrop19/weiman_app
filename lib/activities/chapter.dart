part of '../main.dart';

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
    saveHistory(widget.chapter);
    _pageController = PageController(
        keepPage: false,
        initialPage: widget.book.chapters.indexOf(widget.chapter));
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void pageChanged(int page) {
    saveHistory(widget.book.chapters[page]);
    widget.book.saveBookCache();
  }

  void saveHistory(Chapter chapter) {
    Data.addHistory(widget.book, chapter);
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
        onPageChanged: pageChanged,
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
        },
      ),
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
    updateRead();
    _controller =
        ScrollController(initialScrollOffset: WidgetChapter.height * read);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
  TextStyle _style = TextStyle(color: Colors.white);
  BoxDecoration _decoration =
      BoxDecoration(color: Colors.black.withOpacity(0.4));

  bool loading = true;

  @override
  initState() {
    super.initState();
    Data.addHistory(widget.book, widget.chapter);
    SchedulerBinding.instance.addPostFrameCallback((_) => _refresh?.currentState
        ?.show(notificationDragOffset: SliverPullToRefreshHeader.height));
  }

  Future<bool> fetchImages() async {
    print('fetchImages');
    loading = true;
    images.clear();
    if (mounted) setState(() {});
    final _images = Chapter.fromCache(widget.book, widget.chapter);
    if (_images != null) {
      print('章节 有缓存');
      images.addAll(_images);
      return true;
    }
    try {
      images.addAll(await HttpHHMH39.instance
          .getChapterImages(widget.book, widget.chapter)
          .timeout(Duration(seconds: 10)));
    } catch (e) {
      print('错误 $e');
      showToastWidget(
        GestureDetector(
          child: Container(
            child: Text('读取章节内容出现错误\n点击复制错误内容'),
            color: Colors.black.withOpacity(0.5),
            padding: EdgeInsets.all(10),
          ),
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: e.toString()));
            final content = await Clipboard.getData(Clipboard.kTextPlain);
            print('粘贴板 ${content.text}');
          },
        ),
        duration: Duration(seconds: 5),
        handleTouch: true,
      );
      return false;
      // throw(e);
    }
    loading = false;
    // print('所有图片：' + images.toString());
    Chapter.saveCache(widget.book, widget.chapter, images);
    if (mounted) setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final list = <Widget>[];
    if (!loading && images.length < 20) {
      list.add(SliverToBoxAdapter(
          child: Padding(
              padding: EdgeInsets.all(5),
              child: Text('只读取到少于20张图片，友情提示：\n'
                  '由于能力有限，可能没有办法识别出本章的所有图片，\n'
                  '敬请谅解。'))));
    }
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
          PullToRefreshContainer(
            (info) => SliverPullToRefreshHeader(
              info: info,
              onTap: () => _refresh.currentState.show(
                  notificationDragOffset: SliverPullToRefreshHeader.height),
            ),
          ),
          ...list,
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                print('item $i');
                return StickyHeader(
                  overlapHeaders: true,
                  header: SafeArea(
                    top: true,
                    bottom: false,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: _decoration,
                          child: Text(
                            '${i + 1} / ${images.length}',
                            style: _style,
                          ),
                        ),
                      ],
                    ),
                  ),
                  content: ExtendedImage.network(
                    images[i],
                    cache: true,
                    enableLoadState: true,
                    enableMemoryCache: true,
                    fit: BoxFit.fitWidth,
                    loadStateChanged: (state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          return SizedBox(
                            height: 300,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          break;
                        case LoadState.failed:
                          return SizedBox(
                            width: double.infinity,
                            height: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('图片读取失败'),
                                RaisedButton(
                                  child: Text('重试'),
                                  onPressed: state.reLoadImage,
                                ),
                              ],
                            ),
                          );
                          break;
                        default:
                          return ExtendedRawImage(
                            image: state.extendedImageInfo?.image,
                          );
                      }
                    },
                  ),
                );
              },
              childCount: images.length,
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<String>> checkImage(String last) async {
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
  final List<String> list = [];
  int plus = 1;
  //print('最后的图片：' + last);
  while (true) {
    final String file1 = getFileName(name: fileName, divider: '_', plus: plus),
        file2 = getFileName(name: fileName, divider: '_', plus: plus + 1);
    var url1 = '$a/$b/$file1.$fileFormat', url2 = '$a/$b/$file2.$fileFormat';
    // print('正在测试:\n' + url1 + '\n' + url2);
    final res = await Future.wait(
        [HttpHHMH39.instance.head(url1), HttpHHMH39.instance.head(url2)]);
    if (res[0].statusCode != 200) break;
    list.add(url1);
    if (res[1].statusCode != 200) {
      break;
    }
    list.add(url2);
    plus += 2;
  }
  // print('最后的图片数量: ' + number.toString());
  return list;
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
