import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weiman/widgets/animatedLogo.dart';

import 'package:weiman/classes/data.dart';
import 'package:weiman/crawler/http18Comic.dart';
import 'package:weiman/db/group.dart';

class ActivityTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('测试'),
      ),
      body: Column(
        children: <Widget>[
          AnimatedLogoWidget(width: 25,height: 30),
          FlatButton(
            onPressed: read,
            child: Text('读取'),
          ),
          FlatButton(
            onPressed: clear,
            child: Text('清空数据'),
          ),
          FlatButton(
            onPressed: httpTest,
            child: Text('Http请求参数测试'),
          ),
          FlatButton(
            onPressed: bookKeys,
            child: Text('Book keys'),
          ),
          FlatButton(
            onPressed: dbClear,
            child: Text('清空收藏'),
          ),
        ],
      ),
    );
  }

  void read() {
    var books = Data.getFavorites();
    print(jsonEncode(books));
  }

  void clear() {
    Data.clear();
  }

  Future<void> httpTest() async {
    final books = await Http18Comic.instance.searchBook('冲突');
    print('搜索漫画 ${books[0].toJson()}');
  }

  Future<void> bookKeys() async {
    final books = Group.bookBox.values.toList();
    print('book keys ${Group.bookBox.keys}');
    print('quick ${books.map((e) => e.quick).join(',')}');
  }

  Future<void> dbClear() async {
    await Group.groupBox.clear();
    await Group.bookBox.clear();
  }
}
