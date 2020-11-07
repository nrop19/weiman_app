import 'package:flutter/material.dart';
import 'package:weiman/db/book.dart';

class ActivityCheckDB extends StatefulWidget {
  @override
  _State createState() => _State();
}

enum CheckState {
  Uncheck,
  Pass,
  Fail,
}

class _State extends State<ActivityCheckDB> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('收藏数据检修'),
      ),
      body: ListView(children: [
        ListTile(
          title: Text('所有藏书章节数量归零'),
          onTap: () async {
            for (final book in Book.bookBox.values) {
              book.chapterCount = 0;
              await book.save();
            }
          },
        ),
        ListTile(
          title: Text('清空漫画数据'),
          subtitle: Text('有 ${Book.bookBox.length} 本'),
          onTap: () async {
            await Book.bookBox.clear();
          },
        ),
      ]),
    );
  }
}
