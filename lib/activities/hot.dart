import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:weiman/widgets/animatedLogo.dart';

import 'package:weiman/crawler/http.dart';
import 'package:weiman/crawler/http18Comic.dart';
import 'package:weiman/db/book.dart';
import 'package:weiman/widgets/book.dart';
import 'package:weiman/widgets/pullToRefreshHeader.dart';

class ActivityRank extends StatefulWidget {
  @override
  _ActivityRank createState() => _ActivityRank();
}

class _ActivityRank extends State<ActivityRank>
    with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('热门漫画'),
        bottom: TabBar(controller: controller, tabs: [
          Tab(text: '韩漫'),
          Tab(text: '全部'),
        ]),
      ),
      body: TabBarView(controller: controller, children: [
        HotTab(http: Http18Comic.instance, type: '/hanman'),
        HotTab(http: Http18Comic.instance, type: ''),
      ]),
    );
  }
}

class SourceList extends LoadingMoreBase<Book> {
  final String type;
  final HttpBook http;
  int page = 1;
  String firstBookId;

  bool hasMore = true;

  SourceList({this.type, this.http});

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    try {
      final books = await http.hotBooks(type, page);
      if (books.isEmpty) {
        hasMore = false;
      } else {
        if (firstBookId == books[0].aid) {
          hasMore = false;
        } else {
          firstBookId = books[0].aid;
          page++;
          this.addAll(books);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) {
    hasMore = true;
    page = 1;
    return super.refresh(notifyStateChanged);
  }
}

class HotTab extends StatefulWidget {
  final String type;
  final HttpBook http;

  const HotTab({Key key, this.type, this.http}) : super(key: key);

  @override
  _HotTab createState() => _HotTab();
}

class _HotTab extends State<HotTab> {
  SourceList sourceList;

  @override
  void initState() {
    sourceList = SourceList(type: widget.type, http: widget.http);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        PullToRefreshContainer(
          (info) => SliverPullToRefreshHeader(info: info),
        ),
        LoadingMoreSliverList(SliverListConfig<Book>(
          sourceList: sourceList,
          indicatorBuilder: indicatorBuilder,
          itemBuilder: (_, book, __) => WidgetBook(
            book,
            subtitle: book.authors?.join('/'),
          ),
        )),
      ],
    );
  }

  Widget book(Book book) {
    return WidgetBook(book, subtitle: book.authors?.join('/'));
  }

  Widget indicatorBuilder(context, IndicatorStatus status) {
    print('indicatorBuilder $status');
    bool isSliver = true;
    Widget widget;
    switch (status) {
      case IndicatorStatus.none:
        widget = SizedBox();
        break;
      case IndicatorStatus.loadingMoreBusying:
        widget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AnimatedLogoWidget(width: 20, height: 30),
            SizedBox(width: 10),
            Text("正在读取")
          ],
        );
        widget = _setbackground(false, widget, 35.0);
        break;
      case IndicatorStatus.fullScreenBusying:
        widget = Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedLogoWidget(width: 25, height: 30),
              Text('读取中'),
            ],
          ),
        );
        if (isSliver) {
          widget = SliverFillRemaining(
            child: widget,
          );
        }
        break;
      case IndicatorStatus.error:
      case IndicatorStatus.fullScreenError:
        widget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '读取失败\n你可能需要用梯子',
              textAlign: TextAlign.center,
            ),
            RaisedButton(
              child: Text('再次重试'),
              onPressed: sourceList.errorRefresh,
            )
          ],
        );
        final height = status == IndicatorStatus.error ? 35.0 : double.infinity;
        widget = _setbackground(false, widget, height);
        if (status == IndicatorStatus.fullScreenError) {
          if (isSliver) {
            widget = SliverFillRemaining(
              child: widget,
            );
          } else {
            widget = CustomScrollView(
              slivers: <Widget>[
                SliverFillRemaining(
                  child: widget,
                )
              ],
            );
          }
        }
        break;
      case IndicatorStatus.noMoreLoad:
        widget = Text("已经显示全部搜索结果");
        widget = _setbackground(false, widget, 35.0);
        break;
      case IndicatorStatus.empty:
        widget = Text(
          '没有内容',
        );
        widget = _setbackground(true, widget, double.infinity);
        if (isSliver) {
          widget = SliverToBoxAdapter(
            child: widget,
          );
        } else {
          widget = CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                child: widget,
              )
            ],
          );
        }
        break;
    }
    return widget;
  }

  Widget _setbackground(bool full, Widget widget, double height) {
    widget = Container(
      width: double.infinity,
      height: kToolbarHeight,
      child: widget,
      alignment: Alignment.center,
    );
    return widget;
  }

  Widget getIndicator(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 2.0,
      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
    );
  }
}
