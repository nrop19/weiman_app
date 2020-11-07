import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:oktoast/oktoast.dart';

import 'package:weiman/classes/networkImageSSL.dart';
import 'package:weiman/db/book.dart';
import 'package:weiman/utils.dart';
import 'package:weiman/widgets/sliverExpandableGroup.dart';
import 'package:weiman/widgets/utils.dart';

class Histories extends StatefulWidget {
  @override
  _Histories createState() => _Histories();
}

class _Histories extends State<Histories> {
  static bool _showTips = true;
  final List<Book> inWeek = [], other = [];

  @override
  void initState() {
    super.initState();
    loadBook();
    if (_showTips)
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _showTips = false;
        showToast(
          '阅读记录和时间分组\n往左滑显示更多操作',
          textPadding: EdgeInsets.all(10),
          duration: Duration(seconds: 4),
        );
      });
  }

  void loadBook() {
    inWeek.clear();
    other.clear();
    final list =
        Book.bookBox.values.where((book) => book.history != null).toList();
    final now = DateTime.now().millisecondsSinceEpoch;
    list.sort((a, b) => b.history.time.compareTo(a.history.time));
    list.forEach((book) {
      if ((now - book.history.time.millisecondsSinceEpoch) < weekTime) {
        inWeek.add(book);
      } else {
        other.add(book);
      }
    });
  }

  void clear(bool inWeek) async {
    final title = '确认清空 ' + (inWeek ? '7天内的' : '更早的') + '浏览记录 ?';
    final res = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(title),
              actions: [
                FlatButton(
                  textColor: Colors.grey,
                  child: Text('取消'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  child: Text('确认'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ));
    print('清理历史 $inWeek $res');
    if (res == false) return;
    List<Book> list = inWeek ? this.inWeek : this.other;
    await Future.wait(list.map((book) => book.setHistory(null)));
    setState(() {
      loadBook();
    });
  }

  Widget book(List array, int index) {
    final Book book = array[index];
    return Slidable(
      child: ListTile(
        leading: book.http == null
            ? oldBookAvatar(text: '旧\n书', width: 50.0, height: 80.0)
            : ExtendedImage(
                image: NetworkImageSSL(book.http, book.avatar),
                width: 50.0,
                height: 80.0),
        title: Text(book.name),
        subtitle: Text(book.history.cname),
        onTap: () => openBook(context, book, 'fb ${book.aid}'),
      ),
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        IconSlideAction(
          caption: '删除',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () async {
            await book.setHistory(null);
            setState(() {
              array.remove(book);
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRect(
        child: CustomScrollView(
          slivers: [
            SliverExpandableGroup(
              title: Text('7天内的浏览历史 (${inWeek.length})'),
              expanded: true,
              count: inWeek.length,
              builder: (ctx, i) => book(inWeek, i),
              slideActions: [
                IconSlideAction(
                  caption: '清空',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () => clear(true),
                ),
              ],
            ),
            SliverExpandableGroup(
              title: Text('更早的浏览历史 (${other.length})'),
              count: other.length,
              builder: (ctx, i) => book(other, i),
              slideActions: [
                IconSlideAction(
                  caption: '清空',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () => clear(false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
