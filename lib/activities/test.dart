part of '../main.dart';

class ActivityTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('asd'),
      ),
      body: Column(
        children: <Widget>[
          FlatButton(
            onPressed: save,
            child: Text('保存'),
          ),
          FlatButton(
            onPressed: read,
            child: Text('读取'),
          ),
          FlatButton(
            onPressed: clear,
            child: Text('清空数据'),
          ),
        ],
      ),
    );
  }

  void save() {
    Data.addFavorite(Book(
        aid: '123',
        name: 'name',
        avatar: 'avatar',
        description: '',
        author: ''));
  }

  void read() {
    var books = Data.getFavorites();
    print(jsonEncode(books));
  }

  void clear() {
    Data.clear();
  }
}
