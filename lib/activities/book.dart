import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

import '../classes/book.dart';
import '../classes/data.dart';
import '../classes/networkImageSSL.dart';
import '../main.dart';
import '../utils.dart';
import '../widgets/book.dart';
import '../widgets/favorites.dart';
import '../widgets/pullToRefreshHeader.dart';

class ActivityBook extends StatefulWidget {
  final Book book;
  final String heroTag;

  ActivityBook({@required this.book, @required this.heroTag});

  @override
  _ActivityBook createState() => _ActivityBook();
}

class _ActivityBook extends State<ActivityBook> {
  final GlobalKey<PullToRefreshNotificationState> _refresh = GlobalKey();
  ScrollController _scrollController;

  bool _reverse = false;
  Book book;

  @override
  void initState() {
    book = widget.book;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refresh.currentState
          .show(notificationDragOffset: SliverPullToRefreshHeader.height);
    });
    _scrollController = ScrollController();
    print('${widget.book.toJson()}');
    super.initState();
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> loadBook() async {
    book = await book.http.getBook(book.aid);
    book.history = Data.getHistories()[book.aid]?.history;
    if (mounted) setState(() {});
    return true;
  }

  _openChapter(Chapter chapter) {
    setState(() {
      book.history = History(cid: chapter.cid, cname: chapter.cname, time: 0);
      openChapter(context, book, chapter);
    });
  }

  favoriteBook() async {
    final fav = Provider.of<FavoriteData>(context, listen: false);
    if (book.isFavorite()) {
      final sure = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('确认取消收藏？'),
                // content: Text('删除这本藏书后，首页的快速导航也会删除这本藏书'),
                actions: [
                  FlatButton(
                    child: Text('确认'),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                  RaisedButton(
                    child: Text('取消'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ));
      if (sure == true) {
        final inQuickList = Data.quickIdList().contains(book.aid);
        if (inQuickList) {}
        fav.remove(book);
      }
    } else {
      fav.add(book);
    }
    setState(() {});
  }

  List<Chapter> _sort() {
    final List<Chapter> list = List.from(book.chapters);
    if (_reverse) return list.reversed.toList();
    return list;
  }

  IndexedWidgetBuilder buildChapters(List<Chapter> chapters) {
    IndexedWidgetBuilder builder = (BuildContext context, int index) {
      final chapter = chapters[index];
      Widget child = WidgetChapter(
        chapter: chapter,
        onTap: _openChapter,
        read: chapter.cid == book.history?.cid,
      );
      if (index < chapters.length - 1)
        child = DecoratedBox(
          decoration: border,
          child: child,
        );
      return child;
    };
    return builder;
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = book.isFavorite();
    Color color = isFavorite ? Colors.red : Colors.white;
    IconData icon = isFavorite ? Icons.favorite : Icons.favorite_border;
    final List<Chapter> chapters = _sort();
    final history = <Widget>[];
    if (book.history != null && book.chapters.length > 0) {
      final chapter = book.chapters
          .firstWhere((chapter) => chapter.cid == book.history.cid);
      history.add(ListTile(title: Text('阅读历史')));
      history.add(WidgetChapter(
        chapter: chapter,
        onTap: _openChapter,
        read: true,
      ));
      history.add(ListTile(title: Text('下一章')));
      final nextIndex = book.chapters.indexOf(chapter) + 1;
      if (nextIndex < book.chapterCount) {
        history.add(WidgetChapter(
          chapter: book.chapters[nextIndex],
          onTap: _openChapter,
          read: false,
        ));
      } else {
        history.add(ListTile(subtitle: Text('没有了')));
      }
      history.add(SizedBox(height: 20));
    }
    history.add(ListTile(title: Text('章节列表')));

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
              title: Text(book.name),
              expandedHeight: 200,
              actions: <Widget>[
                IconButton(
                    onPressed: () {
                      setState(() {
                        _reverse = !_reverse;
                        setState(() {});
                      });
                    },
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
                          child: ExtendedImage(
                            width: 100,
                            image: NetworkImageSSL(
                              widget.book.http,
                              widget.book.avatar,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.only(top: 50, right: 20),
                        child: ListView(
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
                  onTap: () => _refresh.currentState.show(
                      notificationDragOffset: SliverPullToRefreshHeader.height),
                )),
            SliverToBoxAdapter(
              child: Column(
                children: history,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                buildChapters(chapters),
                childCount: chapters.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
