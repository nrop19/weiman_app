import 'package:draggable_container/draggable_container.dart';
import 'package:flutter/material.dart';

import 'package:weiman/classes/networkImageSSL.dart';
import 'package:weiman/db/book.dart';
import 'package:weiman/utils.dart';
import 'selectFavoriteBooks.dart';
import 'utils.dart';

class QuickBook extends DraggableItem {
  static const heroTag = 'quickBookAvatar';
  Widget child;
  final BuildContext context;
  final Book book;
  final double width, height;

  QuickBook(this.width, this.height,
      {@required this.book, @required this.context}) {
    child = GestureDetector(
      onTap: () {
        openBook(context, book, '$heroTag ${book.aid}');
      },
      child: Stack(
        children: <Widget>[
          book.http == null
              ? oldBookAvatar(width: width, height: height)
              : SizedBox(
                  width: width,
                  height: height,
                  child: Hero(
                    tag: '$heroTag ${book.aid}',
                    child: Image(
                      image: NetworkImageSSL(book.http, book.avatar),
                      fit: BoxFit.cover,
                    ),
                  ),
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
  GlobalKey<DraggableContainerState> _key =
      GlobalKey<DraggableContainerState>();
  double width = 0, height = 0;

  void exit() {
    _key.currentState.draggableMode = false;
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
            final book = await showFavoriteBooksDialog(context);
            print('选择了 $book');
            if (book == null) return;
            book
              ..quick = buttonIndex
              ..save();
            _key.currentState.insteadOfIndex(buttonIndex,
                QuickBook(width, height, book: book, context: context),
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

    width = widget.width / 4 - 10;
    height = (width / 0.7).roundToDouble();
    final list = <Book>[];
    Book.bookBox.values.forEach((book) {
      if (book.quick != null && list.length < count) {
        list.add(book);
      } else {
        book.quick = null;
        book.save();
      }
    });
    print('quick book length ${list.length}');
    list.sort((a, b) => a.quick.compareTo(b.quick));
    _draggableItems.addAll(list.map((book) {
      return QuickBook(width, height, book: book, context: context);
    }));
    if (_draggableItems.length < count) _draggableItems.add(_addButton);
    for (var i = count - _draggableItems.length; i > 0; i--) {
      _draggableItems.add(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('quick build');
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
          onBeforeDelete: (index, item) async {
            if (item is QuickBook) {
              print('on before delete ${item.book.name}');
              item.book.quick = null;
              item.book.save();
            }
            return true;
          },
          onChanged: (List<DraggableItem> items) {
            final nullIndex = items.indexOf(null);
            final buttonIndex = items.indexOf(_addButton);
            print('null $nullIndex, button $buttonIndex');
            if (nullIndex > -1 && buttonIndex == -1) {
              print('显示添加按钮 1');
              _key.currentState.insteadOfIndex(
                  nullIndex, _addButton,
                  triggerEvent: false, force: true);
              print('显示添加按钮 2');
              setState(() {});
            } else if (nullIndex > -1 &&
                buttonIndex > -1 &&
                nullIndex < buttonIndex) {
              _key.currentState.removeItem(_addButton);
              _key.currentState
                  .insteadOfIndex(nullIndex, _addButton, triggerEvent: false);
            }
            var quick = 0;
            items.forEach((item) {
              if (item is QuickBook) {
                item.book
                  ..quick = quick
                  ..save();
                quick++;
              }
            });
          },
        ),
      ],
    );
  }
}
