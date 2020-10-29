import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:weiman/activities/chapter/chapterTab.dart';
import 'package:weiman/activities/chapter/drawer.dart';
import 'package:weiman/classes/chapter.dart';
import 'package:weiman/db/book.dart';
import 'package:weiman/db/setting.dart';
import 'package:weiman/utils.dart';

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
      final hide = Provider.of<Setting>(context, listen: false).getHideOption();
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

  void saveHistory(Chapter chapter) async {
    await widget.book.setHistory(chapter);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Setting>(builder: (_, data, __) {
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
            return ChapterTab(
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
    });
  }
}
