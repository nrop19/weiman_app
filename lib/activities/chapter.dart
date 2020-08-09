import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:weiman/activities/setting/hideStatusBar.dart';
import 'package:weiman/activities/setting/setting.dart';

import '../classes/book.dart';
import '../classes/data.dart';
import '../classes/networkImageSSL.dart';
import '../utils.dart';
import '../widgets/book.dart';
import '../widgets/pullToRefreshHeader.dart';

class ActivityChapter extends StatefulWidget {
  final Book book;
  final Chapter chapter;

  ActivityChapter(this.book, this.chapter);

  @override
  _ActivityChapter createState() => _ActivityChapter();
}

class _ActivityChapter extends State<ActivityChapter> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController _pageController;
  int showIndex = 0;
  bool hasNextImage = true;

  @override
  void initState() {
    _pageController = PageController(
        keepPage: false,
        initialPage: widget.book.chapters.indexOf(widget.chapter));
    super.initState();
    saveHistory(widget.chapter);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final hide = Provider.of<SettingData>(context, listen: false).hide;
      if (hide == HideOption.always) {
        hideStatusBar();
      }
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    showStatusBar();
    super.dispose();
  }

  void pageChanged(int page) {
    saveHistory(widget.book.chapters[page]);
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

  ScrollController scrollController;

  @override
  initState() {
    scrollController = ScrollController();
    super.initState();
    Data.addHistory(widget.book, widget.chapter);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refresh?.currentState
          ?.show(notificationDragOffset: SliverPullToRefreshHeader.height);
      final hide = Provider.of<SettingData>(context, listen: false).hide;
      if (hide == HideOption.auto) {
        scrollController.addListener(() {
          final isUp = scrollController.position.userScrollDirection ==
              ScrollDirection.forward;
          if (isUp)
            showStatusBar();
          else
            hideStatusBar();
        });
      }
    });
  }

  @override
  dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<bool> fetchImages() async {
    print('fetchImages');
    loading = true;
    images.clear();
    if (mounted) setState(() {});
    try {
      images.addAll(await widget.book.http
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
    if (mounted) setState(() {});
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
        controller: scrollController,
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
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
                  content: ExtendedImage(
                    image: NetworkImageSSL(widget.book.http, images[i]),
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
