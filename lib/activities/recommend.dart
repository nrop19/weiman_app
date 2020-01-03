part of '../main.dart';

class ActivityRecommend extends StatefulWidget {
  @override
  _ActivityRecommend createState() => _ActivityRecommend();
}

class _ActivityRecommend extends State<ActivityRecommend> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('月排行榜'),
      ),
      body: BookList(),
    );
  }
}

class BookList extends StatefulWidget {
  const BookList({Key key}) : super(key: key);

  @override
  _BookList createState() => _BookList();
}

class _BookList extends State<BookList> {
  final GlobalKey<RefreshIndicatorState> _refresh = GlobalKey();
  final List<Book> books = [];
  bool loadFail = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refresh.currentState.show();
    });
  }

  Future<void> loadBooks() async {
    loadFail = false;
    try {
      final books = await UserAgentClient.instance
          .getMonthList()
          .timeout(Duration(seconds: 5));
      this.books
        ..clear()
        ..addAll(books);
    } catch (e) {
      loadFail = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refresh,
      onRefresh: loadBooks,
      child: loadFail
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Center(child: Text('读取失败，下拉刷新')),
                )
              ],
            )
          : ListView(
              children: ListTile.divideTiles(
                  context: context,
                  tiles: books.map((book) => WidgetBook(
                        book,
                        subtitle: book.author,
                      ))).toList(),
            ),
    );
  }
}
