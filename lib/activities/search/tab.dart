import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:weiman/activities/search/source.dart';
import 'package:weiman/crawler/http.dart';
import 'package:weiman/db/book.dart';
import 'package:weiman/widgets/book.dart';

class SearchTab extends StatefulWidget {
  final HttpBook http;
  final String search;

  const SearchTab({
    Key key,
    @required this.http,
    this.search,
  }) : super(key: key);

  @override
  SearchTabState createState() => SearchTabState();
}

class SearchTabState extends State<SearchTab>
    with AutomaticKeepAliveClientMixin {
  SearchSourceList sourceList;

  @override
  void initState() {
    sourceList = SearchSourceList(http: widget.http, search: widget.search);
    super.initState();
  }

  Widget book(Book book) {
    return WidgetBook(book, subtitle: book.authors.join('/'));
  }

  Future<bool> refresh() async {
    return sourceList.refresh(true);
  }

  get search => sourceList.search;

  set search(String value) {
    print('tab search $value');
    sourceList.search = value;
    sourceList.refresh(true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LoadingMoreList(
      ListConfig(
        sourceList: sourceList,
        itemBuilder: (_, item, index) => book(item),
        autoLoadMore: true,
        indicatorBuilder: indicatorBuilder,
      ),
    );
  }

  Widget indicatorBuilder(context, IndicatorStatus status) {
    bool isSliver = false;
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
            Container(
              margin: EdgeInsets.only(right: 5.0),
              height: 15.0,
              width: 15.0,
              child: getIndicator(context),
            ),
            Text("正在读取")
          ],
        );
        widget = _setbackground(false, widget, 35.0);
        break;
      case IndicatorStatus.fullScreenBusying:
        widget = widget = _setbackground(
            false,
            Text(
              '正在读取',
            ),
            35.0);
        if (isSliver) {
          widget = SliverFillRemaining(
            child: widget,
          );
        }
        break;
      case IndicatorStatus.error:
        widget = _setbackground(
            false,
            Text(
              '网络错误\n点击重试',
            ),
            35.0);

        widget = GestureDetector(
          onTap: () {
            sourceList.errorRefresh();
          },
          child: widget,
        );
        break;
      case IndicatorStatus.fullScreenError:
        widget = Text(
          '读取失败，如果失败的次数太多可能需要用梯子',
        );
        widget = _setbackground(true, widget, double.infinity);
        widget = GestureDetector(
          onTap: () {
            sourceList.errorRefresh();
          },
          child: widget,
        );
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
        break;
      case IndicatorStatus.noMoreLoad:
        widget = Text("已经显示全部搜索结果");
        widget = _setbackground(false, widget, 35.0);
        break;
      case IndicatorStatus.empty:
        widget = Text(
          sourceList.search.isEmpty ? '请输入搜索内容' : '搜索不到任何内容',
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

  @override
  bool get wantKeepAlive => true;
}
