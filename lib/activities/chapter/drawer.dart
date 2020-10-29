import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:weiman/classes/chapter.dart';
import 'package:weiman/db/book.dart';
import 'package:weiman/widgets/book.dart';

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
