part of '../main.dart';

class ActivityBook extends StatefulWidget {
  final Book book;
  final String heroTag;

  ActivityBook({@required this.book, @required this.heroTag});

  @override
  BookState createState() => BookState();
}

class BookState extends State<ActivityBook> {
  final GlobalKey<PullToRefreshNotificationState> _refresh = GlobalKey();
  GlobalKey<NestedScrollViewState> _key = GlobalKey<NestedScrollViewState>();

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
        _key.currentState.currentInnerPosition.animateTo(
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

  List<Widget> _headerBuilder(BuildContext context, bool innerBoxIsScrolled) {
    Color color = isFavorite ? Colors.red : Colors.white;
    IconData icon = isFavorite ? Icons.favorite : Icons.favorite_border;
    final book = this.book ?? widget.book;
    return <Widget>[
      SliverAppBar(
        floating: true,
        pinned: true,
        snap: false,
        title: Text(widget.book.name),
        expandedHeight: 200,
        actions: <Widget>[
          IconButton(
              onPressed: _sort,
              icon: Icon(_reverse
                  ? FontAwesomeIcons.sortNumericDown
                  : FontAwesomeIcons.sortNumericDownAlt)),
          IconButton(onPressed: favoriteBook, icon: Icon(icon, color: color))
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin:
                      EdgeInsets.only(top: 50, left: 20, right: 10, bottom: 20),
                  height: 160,
                  child: Hero(
                    tag: widget.heroTag,
                    child: Image.network(
                      widget.book.avatar,
                    ),
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
                        style: TextStyle(color: Colors.white, height: 1.2),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      )
    ];
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
    return WidgetChapter(
      chapter: chapter,
      onTap: _openChapter,
      read: isRead,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color color = isFavorite ? Colors.red : Colors.white;
    IconData icon = isFavorite ? Icons.favorite : Icons.favorite_border;
    final book = this.book ?? widget.book;
    return Scaffold(
      body: PullToRefreshNotification(
        key: _refresh,
        onRefresh: loadBook,
        maxDragOffset: kToolbarHeight * 2,
        child: NestedScrollView(
          key: _key,
          headerSliverBuilder: (_, __) => [],
          physics: AlwaysScrollableClampingScrollPhysics(),
          body: CustomScrollView(
            physics: AlwaysScrollableClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: false,
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
                            child: Image.network(
                              widget.book.avatar,
                            ),
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
              NestedScrollViewInnerScrollPositionKeyWidget(
                Key('0'),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    buildChapter,
                    childCount: book.chapters.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget build1(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    var pinnedHeaderHeight =
        //statusBar height
        statusBarHeight +
            //pinned SliverAppBar height in header
            kToolbarHeight;

    return Scaffold(
      body: NestedScrollViewRefreshIndicator(
        key: _refresh,
        onRefresh: loadBook,
        child: NestedScrollView(
          key: _key,
          pinnedHeaderSliverHeightBuilder: () => pinnedHeaderHeight,
          headerSliverBuilder: _headerBuilder,
          body: LayoutBuilder(
            builder: (_, __) {
              if (isLoading)
                return Container();
              else if (isSuccess) {
                return ListView(
                    children: ListTile.divideTiles(
                            context: context,
                            color: Colors.grey,
                            tiles: chapterWidgets())
                        .toList());
              }
              return Container(
                constraints: BoxConstraints.expand(),
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    '读取失败，下拉刷新\n如果多次失败，请检查网络',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _key.currentState.currentInnerPosition.animateTo(0,
              duration: Duration(milliseconds: 100), curve: Curves.linear);
        },
        child: Icon(FontAwesomeIcons.angleDoubleUp),
      ),
    );
  }
}
