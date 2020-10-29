import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:weiman/classes/networkImageSSL.dart';
import 'package:weiman/db/book.dart';
import 'package:weiman/db/group.dart';
import 'package:weiman/provider/favoriteData.dart';
import 'package:weiman/utils.dart';
import 'package:weiman/widgets/bookGroup.dart';
import 'package:weiman/widgets/bookSettingDialog.dart';
import 'package:weiman/widgets/deleteGroupDialog.dart';
import 'package:weiman/widgets/groupFormDialog.dart';
import 'package:weiman/widgets/sliverExpandableGroup.dart';
import 'package:weiman/widgets/utils.dart';

class FavoriteList extends StatefulWidget {
  @override
  _FavoriteList createState() => _FavoriteList();
}

class _FavoriteList extends State<FavoriteList> {
  static bool showTip = true;

  @override
  initState() {
    super.initState();
    if (showTip) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        showToast(
          '下拉收藏列表检查更新\n分组和藏书左滑显示更多操作',
          textPadding: EdgeInsets.all(10),
          duration: Duration(seconds: 4),
        );
        showTip = false;
      });
    }
  }

  Widget bookBuilder(Book book) {
    return FBookItem(
      book: book,
      onDelete: deleteBook,
    );
  }

  deleteBook(Book book) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('删除藏书 ${book.name} ?'),
        actions: [
          FlatButton(
              child: Text('确认'),
              onPressed: () {
                Navigator.pop(context, true);
              }),
        ],
      ),
    );
    print('删书 $sure');
    if (sure != true) return;

    await Provider.of<FavoriteData>(context, listen: false).deleteBook(book);
  }

  Future<void> deleteGroup(Group group) async {
    await showDeleteGroupDialog(context, group);
    setState(() {});
  }

  Future<void> groupRename(Group group) async {
    await showGroupFormDialog(context, group);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteData>(builder: (_, favorite, __) {
      if (favorite.all.isEmpty && favorite.groups.keys.isEmpty)
        return Center(child: Text('没有收藏'));
      return ClipRect(
        child: RefreshIndicator(
          onRefresh: favorite.checkUpdate,
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                ...favorite.groups.keys.map((group) {
                  final list = favorite.groups[group];
                  return BookGroupHeader(
                    group: group,
                    count: list.length,
                    builder: (ctx, i) => bookBuilder(favorite.groups[group][i]),
                    slideActions: [
                      IconSlideAction(
                        caption: '重命名',
                        color: Colors.blue,
                        icon: Icons.edit,
                        onTap: () => groupRename(group),
                      ),
                      IconSlideAction(
                        caption: '删除',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () => deleteGroup(group),
                      ),
                    ],
                  );
                }),
                SliverExpandableGroup(
                  title: Text('没有分组的藏书(${favorite.others.length})'),
                  expanded: false,
                  count: favorite.others.length,
                  builder: (ctx, i) => bookBuilder(favorite.others[i]),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

final bookStatusWidgets = {
  BookUpdateStatus.loading:
      TextSpan(text: '正在读取网络数据', style: TextStyle(color: Colors.blue)),
  BookUpdateStatus.not:
      TextSpan(text: '该藏书设置为不更新', style: TextStyle(color: Colors.grey)),
  BookUpdateStatus.no:
      TextSpan(text: '该藏书没有新章节', style: TextStyle(color: Colors.grey)),
  BookUpdateStatus.wait:
      TextSpan(text: '处于更新队列，等待更新', style: TextStyle(color: Colors.grey)),
  BookUpdateStatus.old:
      TextSpan(text: '旧藏书不检查更新', style: TextStyle(color: Colors.redAccent)),
  BookUpdateStatus.fail:
      TextSpan(text: '网络问题，检查更新失败', style: TextStyle(color: Colors.redAccent)),
};

class FBookItem extends StatefulWidget {
  final Book book;
  final void Function(Book book) onDelete;

  const FBookItem({
    Key key,
    @required this.book,
    @required this.onDelete,
  }) : super(key: key);

  @override
  _FBookItem createState() => _FBookItem();
}

class _FBookItem extends State<FBookItem> {
  @override
  Widget build(BuildContext context) {
    TextSpan subtitle =
        bookStatusWidgets[widget.book.status ?? BookUpdateStatus.no];
    if (widget.book.status == BookUpdateStatus.had) {
      final _subtitle = '有 ${widget.book.newChapterCount} 章更新';
      subtitle = TextSpan(
        text: _subtitle,
        style: TextStyle(
          color: widget.book.look ? Colors.grey : Colors.green,
        ),
      );
    }
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      closeOnScroll: true,
      actionExtentRatio: 0.25,
      secondaryActions: [
        IconSlideAction(
          caption: '设置',
          color: Colors.blue,
          icon: Icons.settings,
          onTap: () async {
            final before = widget.book.needUpdate;
            await showBookSettingDialog(context, widget.book);
            if (before != widget.book.needUpdate) {
              widget.book.status = widget.book.needUpdate
                  ? BookUpdateStatus.no
                  : BookUpdateStatus.not;
            }
            if (mounted) setState(() {});
          },
        ),
        if (widget.book.status == BookUpdateStatus.had &&
            widget.book.look == false)
          IconSlideAction(
            caption: '已读',
            color: Colors.greenAccent,
            iconWidget: SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                FontAwesomeIcons.bellSlash,
                size: 20,
                color: Colors.white,
              ),
            ),
            foregroundColor: Colors.white,
            onTap: () async {
              widget.book.chapterCount += widget.book.newChapterCount;
              widget.book.look = true;
              await widget.book.save();
              setState(() {});
            },
          ),
        IconSlideAction(
          caption: '删除',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => widget.onDelete(widget.book),
        ),
      ],
      child: ListTile(
        onTap: () async {
          await openBook(context, widget.book, 'fb ${widget.book.aid}');
          setState(() {});
        },
        // onLongPress: () => onDelete(book),
        leading: Hero(
          tag: 'fb ${widget.book.aid}',
          child: widget.book.http == null
              ? oldBookAvatar(text: '旧书', width: 50.0, height: 80.0)
              : ExtendedImage(
                  image: NetworkImageSSL(widget.book.http, widget.book.avatar),
                  width: 50.0,
                  height: 80.0),
        ),
        title: Text(widget.book.name),
        subtitle: RichText(text: subtitle),
      ),
    );
  }
}
