import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import 'package:weiman/classes/book.dart';
import 'package:weiman/classes/data.dart';
import 'package:weiman/db/book.dart' as newBook;
import 'package:weiman/main.dart';
import 'home.dart';

class ActivityDataConvert extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<ActivityDataConvert> {
  List<Book> quick;
  Map<String, Book> favorites;
  bool selectQ = true, selectH = true;

  @override
  void initState() {
    analytics.setCurrentScreen(screenName: '/activity_data_convert');
    favorites = Data.getFavorites();
    quick = Data.quickList();
    super.initState();
  }

  Future convert() async {
    int quickIndex = 0;
    int skip = 0;
    final awaitList = <Future>[];
    favorites.keys.forEach((id) {
      if (newBook.Book.bookBox.containsKey(id)) return;
      final oldBook = favorites[id];
      final isQuick = selectQ && quick.contains(oldBook.aid);
      final book = new newBook.Book(
        httpId: null,
        aid: oldBook.aid,
        name: oldBook.name,
        avatar: oldBook.avatar,
        description: oldBook.description,
        authors: [oldBook.author],
        chapterCount: oldBook.chapterCount,
        quick: isQuick ? quickIndex : null,
        needUpdate: true,
        favorite: true,
        history: null,
      );
      if (isQuick) quickIndex++;
      awaitList.add(book.save());
    });
    await Future.wait(awaitList);
    showToast(
      '成功转存 ${awaitList.length} 本小说\n跳过了 $skip 本',
      textPadding: EdgeInsets.all(10),
    );
  }

  Future clean() async {
    await Data.instance.remove(Data.favoriteBooksKey);
    await Data.instance.remove(Data.quickKey);
    await Data.instance.remove(Data.viewHistoryKey);
  }

  void gotoHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityHome(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('旧数据转存'),
      ),
      body: ListView(children: [
        ListTile(
            title: Text('从v1.1.2开始，为了实现藏书分组功能，使用了新的数据存储方式'
                '\n【旧书】打开后直接搜索同名漫画。'
                '\n清空旧数据后这个界面不会再次出现。'
                '\n需要将旧的藏书数据转存为新数据吗？'
                '\n旧藏书不多的话，我个人建议直接清空，可以防止产生数据干扰')),
        ListTile(
          title: Text('收藏列表'),
          subtitle: Text('一共有 ${favorites.length} 本'),
          trailing: Checkbox(
            value: true,
            onChanged: null,
          ),
        ),
        ListTile(
          title: Text('快速导航'),
          subtitle: Text('一共有 ${quick.length} 本'),
          trailing: Checkbox(
            value: selectQ,
            onChanged: (value) {
              setState(() {
                selectQ = value;
              });
            },
          ),
        ),
      ]),
      bottomNavigationBar: Row(children: [
        SizedBox(width: 10),
        Expanded(
          child: OutlineButton(
            child: Text('直接清空旧数据'),
            onPressed: () async {
              await clean();
              gotoHome();
            },
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: OutlineButton(
            child: Text('转存并清空旧数据'),
            onPressed: () async {
              await convert();
              await clean();
              gotoHome();
            },
          ),
        ),
        SizedBox(width: 10),
      ]),
    );
  }
}
