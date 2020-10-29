import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:provider/provider.dart';
import 'package:weiman/activities/chapter/image.dart';
import 'package:weiman/activities/chapter/viewerSwitcherWidget.dart';
import 'package:weiman/classes/chapter.dart';
import 'package:weiman/crawler/http18Comic.dart';
import 'package:weiman/db/book.dart';
import 'package:weiman/db/setting.dart';
import 'package:weiman/utils.dart';
import 'package:weiman/widgets/animatedLogo.dart';

class ChapterSourceList extends LoadingMoreBase<String> {
  final Book book;
  final Chapter chapter;
  final Function onFirstLoaded;

  bool firstLoad = true;
  bool hasMore = true;
  bool isMultiPage = false;
  int page = 1;

  ChapterSourceList({
    this.book,
    this.chapter,
    this.onFirstLoaded,
  });

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    final chapterContent = await Http18Comic.instance.getChapterContent(
      book,
      chapter,
      page: page,
    );
    print(chapterContent.toString());
    hasMore = chapterContent.hasNextPage;
    this.addAll(chapterContent.images);
    if (firstLoad) {
      firstLoad = false;
      isMultiPage = hasMore;
    }
    page++;
    return true;
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) {
    firstLoad = true;
    hasMore = true;
    page = 1;
    return super.refresh(notifyStateChanged);
  }
}

class ChapterTab extends StatefulWidget {
  final Book book;
  final Chapter chapter;
  final List<Widget> actions;

  const ChapterTab({Key key, this.book, this.chapter, this.actions})
      : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<ChapterTab> {
  ChapterSourceList sourceList;
  ScrollController scrollController;

  @override
  initState() {
    scrollController = ScrollController();
    sourceList = ChapterSourceList(
      book: widget.book,
      chapter: widget.chapter,
    );
    widget.book.setHistory(widget.chapter);
    super.initState();

    // 隐藏/显示 状态栏
    final setting = Provider.of<Setting>(context, listen: false);
    final hide = setting.getHideOption();
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
  }

  @override
  dispose() {
    widget.book.setHistory(widget.chapter);
    scrollController?.dispose();
    super.dispose();
  }

  Widget imageBuilder(ctx, String image, int index) {
    index += 1;
    bool reDraw = false;
    try {
      int cid = int.parse(widget.chapter.cid);
      reDraw = cid >= 220980;
      // print('创建图片 cid $cid， reDraw $reDraw');
    } catch (e) {}
    return ImageWidget(
      image: image,
      index: index,
      total: sourceList.length,
      reSort: reDraw,
    );
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
        widget = Container(
          width: double.infinity,
          height: kToolbarHeight,
          child: widget,
          alignment: Alignment.center,
        );
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
        widget = Container(
          width: double.infinity,
          height: kToolbarHeight,
          child: widget,
          alignment: Alignment.center,
        );
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
        widget = SizedBox();
        break;
      case IndicatorStatus.empty:
        widget = Text(
          '没有图片',
        );
        widget = Container(
          width: double.infinity,
          height: kToolbarHeight,
          child: widget,
          alignment: Alignment.center,
        );
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverAppBar(
          snap: true,
          floating: true,
          title: Text(widget.chapter.cname),
          actions: [
            ViewerSwitcherWidget(),
            IconButton(
              icon: Icon(Icons.vertical_align_top),
              onPressed: () => scrollController.jumpTo(0.0),
            ),
            ...widget.actions,
          ],
        ),
        LoadingMoreSliverList(
          SliverListConfig(
            sourceList: sourceList,
            itemBuilder: imageBuilder,
            addSemanticIndexes: true,
            semanticIndexOffset: 10,
            autoLoadMore: true,
            indicatorBuilder: indicatorBuilder,
          ),
        ),
      ],
    );
  }
}
