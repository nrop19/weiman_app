part of '../main.dart';

class ActivitySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Search();
  }
}

class Search extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchState();
  }
}

class SearchState extends State<Search> {
  TextEditingController _controller = TextEditingController();
  GlobalKey<PullToRefreshNotificationState> _refresh = GlobalKey();
  final List<Book> _books = [];
  bool loading;

  void submit() {
    _refresh.currentState
        .show(notificationDragOffset: SliverPullToRefreshHeader.height);
  }

  Future<bool> startSearch() async {
    print('搜索漫画: ' + _controller.text);
    setState(() {
      loading = true;
    });
    _books.clear();
    try {
      final List<Book> books = await UserAgentClient.instance
          .searchBook(_controller.text)
          .timeout(Duration(seconds: 5));
      _books.addAll(books);
      loading = false;
    } catch (e) {
      loading = false;
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PullToRefreshNotification(
        key: _refresh,
        onRefresh: startSearch,
        child: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true,
            title: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (RawKeyEvent event) {
                print(
                    'is enter: ${LogicalKeyboardKey.enter == event.logicalKey}');
                if (_controller.text.isEmpty) return;
                if (event.runtimeType == RawKeyUpEvent &&
                    LogicalKeyboardKey.enter == event.logicalKey) {
                  print('回车键搜索');
                  submit();
                }
              },
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索书名',
                  prefixIcon: IconButton(
                    onPressed: () {
                      _refresh.currentState.show(
                          notificationDragOffset:
                              SliverPullToRefreshHeader.height);
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
                textAlign: TextAlign.left,
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (String name) {
                  print('onSubmitted');
                  submit();
                },
                keyboardType: TextInputType.text,
                onEditingComplete: () {
                  print('onEditingComplete');
                  submit();
                },
              ),
            ),
          ),
          PullToRefreshContainer((info) => SliverPullToRefreshHeader(
                info: info,
                onTap: submit,
              )),
          SliverLayoutBuilder(
            builder: (_, __) {
              if (loading == null)
                return SliverFillRemaining(
                    child: Center(child: Text('输入关键词搜索')));
              if (loading) return SliverToBoxAdapter();
              if (_books.length == 0) {
                return SliverFillRemaining(child: Center(child: Text('一本也没有')));
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((_, i) {
                  return WidgetBook(
                    _books[i],
                    subtitle: _books[i].author,
                  );
                }, childCount: _books.length),
              );
            },
          ),
        ]),
      ),
    );
  }
}
