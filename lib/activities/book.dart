part of '../main.dart';

class ActivityBook extends StatefulWidget {
  final Book book;
  final String heroTag;

  ActivityBook({@required this.book, @required this.heroTag});

  @override
  BookState createState() => BookState();
}

class BookState extends State<ActivityBook> {
  static BoxDecoration _border;
  final GlobalKey<PullToRefreshNotificationState> _refresh = GlobalKey();
  ScrollController _scrollController;

  bool _reverse = false;
  bool isFavorite = false;
  bool isLoading = true, isSuccess = false;
  Book book;
  List<Chapter> chapters = [];

  @override
  void initState() {
    super.initState();
    isFavorite = widget.book.isFavorite();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refresh.currentState.show();
    });
    _scrollController = ScrollController();
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> loadBook() async {
    setState(() {
      isLoading = true;
      isSuccess = false;
    });
    try {
      book = await UserAgentClient.instance
          .getBook(aid: widget.book.aid)
          .timeout(Duration(seconds: 5));
      book.history = Data.getHistories()[book.aid]?.history;
      chapters
        ..clear()
        ..addAll(book.chapters);
      if (_reverse) chapters = chapters.reversed.toList();

      /// 更新收藏列表里的漫画数据
      if (isFavorite) Data.addFavorite(book);

      _scrollToRead();
      isSuccess = true;
    } catch (e) {
      isSuccess = false;
      return false;
    }
    isLoading = false;
    print('刷新 $book');
    setState(() {});
    return true;
  }

  void _scrollToRead() {
    if (book.history != null) {
      final history = book.chapters
          .firstWhere((chapter) => chapter.cid == book.history.cid);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
            WidgetChapter.height * chapters.indexOf(history).toDouble(),
            duration: Duration(milliseconds: 500),
            curve: Curves.linear);
      });
    }
  }

  _openChapter(Chapter chapter) {
    setState(() {
      book.history = History(cid: chapter.cid, cname: chapter.cname, time: 0);
      openChapter(context, book, chapter);
    });
  }

  favoriteBook() {
    widget.book.favorite();
    isFavorite = !isFavorite;
    setState(() {});
  }

  void _sort() {
    setState(() {
      _reverse = !_reverse;
      chapters = chapters.reversed.toList();
      _scrollToRead();
    });
  }

  List<Widget> chapterWidgets() {
    final book = this.book ?? widget.book;
    List<Widget> list = [];
    chapters.forEach((chapter) {
      final isRead = chapter.cid == book.history?.cid;
      list.add(WidgetChapter(
        chapter: chapter,
        onTap: _openChapter,
        read: isRead,
      ));
    });
    return list;
  }

  Widget buildChapter(BuildContext context, int index) {
    final book = this.book ?? widget.book;
    final chapter = chapters[index];
    final isRead = chapter.cid == book.history?.cid;
    if (index < chapters.length - 1) {
      return DecoratedBox(
        decoration: _border,
        child: WidgetChapter(
          chapter: chapter,
          onTap: _openChapter,
          read: isRead,
        ),
      );
    }
    return WidgetChapter(
      chapter: chapter,
      onTap: _openChapter,
      read: isRead,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_border == null)
      _border = BoxDecoration(
          border: Border(
              bottom: Divider.createBorderSide(context, color: Colors.grey)));
    Color color = isFavorite ? Colors.red : Colors.white;
    IconData icon = isFavorite ? Icons.favorite : Icons.favorite_border;
    final book = this.book ?? widget.book;
    return Scaffold(
      body: PullToRefreshNotification(
        key: _refresh,
        onRefresh: loadBook,
        maxDragOffset: kToolbarHeight * 2,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              title: Text(widget.book.name),
              expandedHeight: 200,
              actions: <Widget>[
                IconButton(
                    onPressed: _sort,
                    icon: Icon(_reverse
                        ? FontAwesomeIcons.sortNumericDown
                        : FontAwesomeIcons.sortNumericDownAlt)),
                IconButton(
                    onPressed: favoriteBook, icon: Icon(icon, color: color))
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            top: 50, left: 20, right: 10, bottom: 20),
                        height: 160,
                        child: Hero(
                          tag: widget.heroTag,
                          child:
                              Image(image: NetworkImageSSL(widget.book.avatar)),
                        ),
                      ),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.only(top: 50, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '作者：' + (book.author ?? ''),
                              style: TextStyle(color: Colors.white),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                            ),
                            Text(
                              '简介：\n' + (book.description ?? ''),
                              softWrap: true,
                              style:
                                  TextStyle(color: Colors.white, height: 1.2),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
            PullToRefreshContainer((info) => SliverPullToRefreshHeader(
                  info: info,
                  onTap: () => _refresh.currentState
                      .show(notificationDragOffset: kToolbarHeight * 2),
                )),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                buildChapter,
                childCount: book.chapters.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
