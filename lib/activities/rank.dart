part of '../main.dart';

class ActivityRank extends StatefulWidget {
  @override
  _ActivityRank createState() => _ActivityRank();
}

class _ActivityRank extends State<ActivityRank> {
  final List<Book> books = [];
  int page = 1;
  LoadMoreD _d;

  @override
  void initState() {
    super.initState();
    _d = LoadMoreD(reload);
  }

  void reload() {
    onLoadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('月排行榜')),
      body: Container(
        child: LoadMore(
          isFinish: page >= 10,
          onLoadMore: onLoadMore,
          delegate: _d,
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return WidgetBook(
                books[index],
                subtitle: books[index].author,
              );
            },
            itemCount: books.length,
          ),
        ),
      ),
    );
  }

  Future<bool> onLoadMore() async {
    bool isSuccess = false;
    try {
      books.addAll(await HttpHHMH39.instance.getMonthList(page: page));
      isSuccess = true;
      print('load $page');
      page++;
      setState(() {});
    } catch (e) {
      print('$e $page');
    }
    return isSuccess;
  }
}

class LoadMoreD extends LoadMoreDelegate {
  final void Function() reload;

  LoadMoreD(this.reload);

  @override
  Widget buildChild(LoadMoreStatus status,
      {builder = DefaultLoadMoreTextBuilder.chinese}) {
    Widget widget;
    switch (status) {
      case LoadMoreStatus.idle:
        widget = SizedBox();
        break;
      case LoadMoreStatus.loading:
        widget = SafeArea(child: Center(child: Text('读取中')));
        break;
      case LoadMoreStatus.fail:
        widget = SafeArea(child: Center(child: Text('读取失败，点击再次尝试')));
        break;
      case LoadMoreStatus.nomore:
        widget = SafeArea(child: Center(child: Text('就这些了')));
        break;
    }
    return widget;
  }
}
