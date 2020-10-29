import 'dart:io';

import 'package:dio/dio.dart';
import 'package:weiman/classes/chapter.dart';
import 'package:weiman/classes/chapterContent.dart';
import 'package:weiman/db/book.dart';

import 'http18Comic.dart';

final headers = {
  'user-agent':
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
  'accept':
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
  'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8,zh-HK;q=0.7',
  'cache-control': 'no-cache',
  'pragma': 'no-cache',
};

class MyHttpClient {
  static Map<String, HttpBook> clients = {};

  static init(String proxy, int timeout) {
    Http18Comic.instance = Http18Comic(
      baseUrls.values.first,
      name: baseUrls.keys.first,
      headers: headers,
      timeout: timeout,
    );

    clients[Http18Comic.instance.id] = Http18Comic.instance;

    setGlobalProxy(proxy);
  }
}

abstract class HttpBook {
  final String id;
  final String name;

  final Dio dio;

  HttpBook(this.id, this.name, this.dio);

  Future<List<Book>> searchBook(String name, [int page]);

  Future<Book> getBook(String aid);

  Future<List<String>> getChapterImages(Book book, Chapter chapter);

  Future<ChapterContent> getChapterContent(Book book, Chapter chapter);

  Future<List<int>> getImage(String url, {bool reSort = false});

  Future<List<Book>> hotBooks([String type = '', int page]);
}

class MyProxyHttpOverride extends HttpOverrides {
  final String proxy;

  MyProxyHttpOverride(this.proxy);

  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..findProxy = (uri) {
        return 'PROXY $proxy;';
      }
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void setGlobalProxy(String proxy) {
  print('setGlobalProxy $proxy');
  if (proxy != null)
    HttpOverrides.global = MyProxyHttpOverride(proxy);
  else
    HttpOverrides.global = null;
}
