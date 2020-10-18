import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:weiman/crawler/http18Comic.dart';
import 'package:weiman/db/book.dart';

class ActivityTest extends StatefulWidget {
  @override
  _ActivityTest createState() => _ActivityTest();
}

class _ActivityTest extends State<ActivityTest> {
  LoadState state;
  List<Book> books;
  String html;
  String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('测试'),
      ),
      body: ListView(
        children: [
          RaisedButton(
            child: Text('搜索《冲突》(有可能会使用缓存)'),
            onPressed: state != LoadState.loading ? useCache : null,
          ),
          RaisedButton(
            child: Text('搜索《冲突》(不使用缓存)'),
            onPressed: state != LoadState.loading ? noCache : null,
          ),
          if (books != null) Text('成功搜索到 ${books.length} 本漫画'),
          if (html != null) Text('网页内容：\n$html'),
          if (error != null) Text('错误内容：\n$error'),
        ],
      ),
    );
  }

  noCache() {
    final dio = Dio(BaseOptions(baseUrl: 'http://18comic.vip'));
    httpTest(dio);
  }

  useCache() {
    httpTest(Http18Comic.instance.dio);
  }

  httpTest(Dio dio) async {
    setState(() {
      html = null;
      error = null;
      state = LoadState.loading;
      books = null;
    });
    try {
      final res = (await Future.wait([
        dio.get(
          '/search/photos',
          queryParameters: {'page': 1, 'search_query': '冲突'},
          options: buildCacheOptions(Duration(days: 3)),
        ),
        Future.delayed(
          Duration(seconds: 1),
        ),
      ]))[0];
      // print('heades ${res.headers}');
      html = res.data;
      books = Http18Comic.parseBookList(res.data);
    } catch (e) {
      print('$e');
      print('${e.toString()}');
      this.error = e.toString();
    }
    setState(() {
      state = LoadState.completed;
    });
  }
}
