part of '../main.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            builder: (ctx, i) => WidgetBook(
              inWeek[i],
              subtitle: inWeek[i].history.cname,
            ),
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
            builder: (ctx, i) => WidgetBook(
              other[i],
              subtitle: other[i].history.cname,
            ),
          ),
        ],
      ),
    );
  }
}
