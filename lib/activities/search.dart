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

enum _SearchState {
  None,
  Searching,
  Done,
  Error,
}

class SearchState extends State<Search> {
  Future<List<Book>> search;
  TextEditingController _controller = TextEditingController();
  CancelableOperation _searcher;
  _SearchState _state = _SearchState.None;
  final List<Book> _books = [];

  void startSearch() {
    print('搜索漫画: ' + _controller.text);
    if (_searcher != null) _searcher.cancel();
    _books.clear();
    setState(() {
      _state = _SearchState.Searching;
    });
    _searcher = CancelableOperation.fromFuture(
            UserAgentClient.instance.searchBook(_controller.text))
        .then((books) {
      setState(() {
        print('搜索完成: ' + books.length.toString());
        _books.addAll(books);
        _state = _SearchState.Done;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    search = null;
    return Scaffold(
      appBar: AppBar(
        title: Text('搜索漫画'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (RawKeyEvent event) {
                    if (event.runtimeType == RawKeyUpEvent &&
                        event.logicalKey.debugName.toLowerCase() == 'enter') {
                      if (_controller.text.isEmpty) return;
                      startSearch();
                    }
                  },
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: '搜索书名', prefixIcon: Icon(Icons.search)),
                    textAlign: TextAlign.left,
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (String name) {
                      print('onSubmitted');
                      startSearch();
                    },
                    keyboardType: TextInputType.text,
                    onEditingComplete: () {
                      print('onEditingComplete');
                      startSearch();
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                switch (_state) {
                  case _SearchState.Searching:
                    return Center(child: CircularProgressIndicator());
                  case _SearchState.None:
                    return Center(
                        child: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ));
                  default:
                    if (_books.length == 0)
                      return Center(
                          child: Text(
                        '一本也找不到',
                        style: TextStyle(color: Colors.blueGrey),
                      ));
                    List<Widget> list = _books
                        .map((book) => WidgetBook(
                              book,
                              subtitle: book.author,
                            ))
                        .toList();
                    return ListView(
                      children:
                          ListTile.divideTiles(context: context, tiles: list)
                              .toList(),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
