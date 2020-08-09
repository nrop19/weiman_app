import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../classes/book.dart';
import '../classes/data.dart';
import '../classes/networkImageSSL.dart';
import '../utils.dart';
import '../widgets/sliverExpandableGroup.dart';
import '../widgets/utils.dart';

class Histories extends StatefulWidget {
  @override
  _Histories createState() => _Histories();
}

class _Histories extends State<Histories> {
  final List<Book> inWeek = [], other = [];

  @override
  void initState() {
    super.initState();
    loadBook();
  }

  void loadBook() {
    inWeek.clear();
    other.clear();
    final list = Data.getHistories().values.toList();
    final now = DateTime.now().millisecondsSinceEpoch;
    list.sort((a, b) => b.history.time.compareTo(a.history.time));
    list.forEach((book) {
      if ((now - book.history.time) < weekTime) {
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
    list.forEach((book) => Data.removeHistoryFromBook(book));
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
          onTap: () => setState(() {
            array.removeAt(index);
            Data.removeHistoryFromBook(book);
          }),
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
              actions: [
                FlatButton(
                  child: Text('清空'),
                  onPressed: inWeek.length == 0 ? null : () => clear(true),
                ),
              ],
              count: inWeek.length,
              builder: (ctx, i) => book(inWeek, i),
            ),
            SliverExpandableGroup(
              title: Text('更早的浏览历史 (${other.length})'),
              actions: [
                FlatButton(
                  child: Text('清空'),
                  onPressed: other.length == 0 ? null : () => clear(false),
                ),
              ],
              count: other.length,
              builder: (ctx, i) => book(other, i),
            ),
          ],
        ),
      ),
    );
  }
}
