import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../classes/data.dart';
import '../crawler/http18Comic.dart';

class ActivityTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('测试'),
      ),
      body: Column(
        children: <Widget>[
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
}
