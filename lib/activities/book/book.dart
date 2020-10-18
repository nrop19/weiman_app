import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:weiman/classes/chapter.dart';
import 'package:weiman/classes/networkImageSSL.dart';
import 'package:weiman/db/book.dart';
import 'package:weiman/main.dart';
import 'package:weiman/provider/favoriteData.dart';
import 'package:weiman/utils.dart';
import 'package:weiman/widgets/book.dart';
import 'package:weiman/widgets/bookSettingDialog.dart';
import 'package:weiman/widgets/pullToRefreshHeader.dart';
import 'package:weiman/activities/book/tapToSearch.dart';

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

  @override
  void initState() {
    super.initState();
    widget.book.look = true;
    _scrollController = ScrollController();
    print('${widget.book}');
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _refresh.currentState
          .show(notificationDragOffset: SliverPullToRefreshHeader.height);
    });
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> loadBook() async {
    try {
      final res = await widget.book.load();
      if (mounted && widget.book.needToSave()) {
        await widget.book.save();
        // Provider.of<FavoriteData>(context, listen: false).loadBooksList(true);
      }
      if (mounted) setState(() {});
      return res;
    } catch (e) {
      return false;
    }
  }

  _openChapter(Chapter chapter) async {
    await openChapter(context, widget.book, chapter);
    setState(() {});
  }

  favoriteBook() async {
    final fav = Provider.of<FavoriteData>(context, listen: false);
    if (widget.book.favorite) {
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
        fav.deleteBook(widget.book);
      }
    } else {
      await fav.addBook(widget.book);
      await showBookSettingDialog(context, widget.book);
      if (widget.book.needUpdate == true) {
        widget.book.status = BookUpdateStatus.no;
      } else {
        widget.book.status = BookUpdateStatus.not;
      }
    }
    setState(() {});
  }

  List<Chapter> _sort() {
    final List<Chapter> list = List.from(widget.book.chapters);
    // print('sort ${list.length}');
    if (_reverse) return list.reversed.toList();
    return list;
  }

  IndexedWidgetBuilder buildChapters(List<Chapter> chapters) {
    IndexedWidgetBuilder builder = (BuildContext context, int index) {
      final chapter = chapters[index];
      Widget child = WidgetChapter(
        chapter: chapter,
        onTap: _openChapter,
        read: chapter.cid == widget.book.history?.cid,
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
    Color color = widget.book.favorite ? Colors.red : Colors.white;
    IconData icon =
        widget.book.favorite ? Icons.favorite : Icons.favorite_border;
    final List<Chapter> chapters = _sort();
    final history = <Widget>[];
    if (widget.book.history != null && widget.book.chapters.length > 0) {
      final chapter = widget.book.chapters
          .firstWhere((chapter) => chapter.cid == widget.book.history.cid);
      history.add(ListTile(title: Text('阅读历史')));
      history.add(WidgetChapter(
        chapter: chapter,
        onTap: _openChapter,
        read: true,
      ));
      history.add(ListTile(title: Text('下一章')));
      final nextIndex = widget.book.chapters.indexOf(chapter) + 1;
      if (nextIndex < widget.book.chapterCount) {
        history.add(WidgetChapter(
          chapter: widget.book.chapters[nextIndex],
          onTap: _openChapter,
          read: false,
        ));
      } else {
        history.add(ListTile(subtitle: Text('没有了')));
      }
      history.add(SizedBox(height: 20));
    }
    history.add(
      ListTile(
        title: Row(
          children: [
            Text('章节列表'),
            SizedBox(width: 10),
            TextButton(
              onPressed: () {
                _reverse = !_reverse;
                setState(() {});
              },
              child: Text('倒序'),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: PullToRefreshNotification(
        key: _refresh,
        onRefresh: loadBook,
        maxDragOffset: kToolbarHeight * 2,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            /// 标题栏
            SliverAppBar(
              floating: true,
              pinned: true,
              title: Text(widget.book.name),
              expandedHeight: 200,
              actions: <Widget>[
                IconButton(
                    onPressed: favoriteBook, icon: Icon(icon, color: color))
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      /// 漫画封面
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

                      /// 作者、标签、简介内容
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.only(top: 50, right: 20),
                        child: ListView(
                          children: <Widget>[
                            TapToSearchWidget(
                                leading: '作者', items: widget.book.authors),
                            TapToSearchWidget(
                                leading: '标签', items: widget.book.tags),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                            ),
                            Text(
                              widget.book.description ?? '',
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

            /// 观看历史
            SliverToBoxAdapter(
              child: Column(
                children: history,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),

            /// 章节列表
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
