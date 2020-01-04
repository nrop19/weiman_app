part of '../main.dart';

class QuickBook extends DraggableItem {
  static const heroTag = 'quickBookAvatar';
  Widget child;
  final BuildContext context;
  final Book book;

  QuickBook({@required this.book, @required this.context}) {
    child = GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) => ActivityBook(
                      book: book,
                      heroTag: '$heroTag ${book.aid}',
                    )));
      },
      child: Stack(
        children: <Widget>[
          Hero(
            tag: '$heroTag ${book.aid}',
            child: Image(image: NetworkImageSSL(book.avatar)),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 2),
              color: Colors.black.withOpacity(0.5),
              child: Text(
                book.name,
                softWrap: true,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }

  checkUpdate() {
    UserAgentClient.instance.getBook(aid: book.aid);
  }
}

class Quick extends StatefulWidget {
  final double width, height;
  final Function(bool mode) draggableModeChanged;

  const Quick(
      {Key key, this.width, this.height, @required this.draggableModeChanged})
      : super(key: key);

  @override
  QuickState createState() => QuickState();
}

class QuickState extends State<Quick> {
  final int count = 8;
  final List<DraggableItem> _draggableItems = [];
  DraggableItem _addButton;
  GlobalKey<DraggableContainerState> _key = GlobalKey();
  final List<String> id = [];

  void exit() {
    _key.currentState.draggableMode = false;
  }

  _showSelectBookDialog() async {
    final books = Data.getFavorites();
    final list = books.values
        .where((book) => !id.contains(book.aid))
        .map((book) => ListTile(
              title: Text(book.name),
              leading: Image(image: NetworkImageSSL(book.avatar)),
              onTap: () {
                Navigator.pop(context, book);
              },
            ));
    return showDialog<Book>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('将收藏的漫画添加到快速导航'),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: list.isNotEmpty
                  ? ListView(
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: list,
                      ).toList(),
                    )
                  : Center(child: Text('没有了')),
            ),
          );
        });
  }

  QuickState() {
    _addButton = DraggableItem(
      deletable: false,
      fixed: true,
      child: FlatButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.add,
              color: Colors.grey,
            ),
            Text(
              '添加',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            )
          ],
        ),
        onPressed: () async {
          final items = _key.currentState.items;
          final buttonIndex = items.indexOf(_addButton);
          print('add $buttonIndex');
          if (buttonIndex > -1) {
            final book = await _showSelectBookDialog();
            print('选择了 $book');
            if (book == null) return;
            _key.currentState.insteadOfIndex(
                buttonIndex, QuickBook(book: book, context: context),
                force: true);
          }
        },
      ),
    );
  }

  int length() {
    return _key.currentState.items.where((item) => item is QuickBook).length;
  }

  @override
  void initState() {
    super.initState();

    _draggableItems.addAll(Data.quickList().map((book) {
      id.add(book.aid);
      return QuickBook(book: book, context: context);
    }));
    if (_draggableItems.length < count) _draggableItems.add(_addButton);
    for (var i = count - _draggableItems.length; i > 0; i--) {
      _draggableItems.add(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width / 4 - 10;
    final height = (width / 0.7).roundToDouble();
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 8, bottom: 4, left: 8),
          width: widget.width,
          child: Text(
            '快速导航（长按编辑）',
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        DraggableContainer(
          key: _key,
          slotMargin: EdgeInsets.only(bottom: 8, left: 6, right: 6),
          slotSize: Size(width, height),
          slotDecoration: BoxDecoration(color: Colors.grey.withOpacity(0.3)),
          dragDecoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black, blurRadius: 10)]),
          items: _draggableItems,
          onDraggableModeChanged: widget.draggableModeChanged,
          onChanged: (List<DraggableItem> items) {
            id.clear();
            items.forEach((item) {
              if (item is QuickBook) id.add(item.book.aid);
            });
            Data.addQuickAll(id);
            final nullIndex = items.indexOf(null);
            final buttonIndex = items.indexOf(_addButton);
            print('null $nullIndex, button $buttonIndex');
            if (nullIndex > -1 && buttonIndex == -1) {
              _key.currentState
                  .insteadOfIndex(nullIndex, _addButton, triggerEvent: false);
            } else if (nullIndex > -1 &&
                buttonIndex > -1 &&
                nullIndex < buttonIndex) {
              _key.currentState.removeItem(_addButton);
              _key.currentState
                  .insteadOfIndex(nullIndex, _addButton, triggerEvent: false);
            }
          },
        ),
      ],
    );
  }
}
