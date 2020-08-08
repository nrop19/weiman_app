import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import '../classes/book.dart';
import 'http18Comic.dart';

class MyHttpClient {
  static Map<String, HttpBook> clients = {};

  static init(String proxy, int timeout, int imageTimeout) {
    final headers = {
      "user-agent":
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36",
      "accept":
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
      "accept-language": "zh-CN,zh;q=0.9,en;q=0.8,zh-HK;q=0.7",
      "cache-control": "no-cache",
      "pragma": "no-cache",
    };

    var http = Http18Comic(
      proxy: proxy,
      headers: headers,
      timeout: timeout,
    );
    clients[http.id] = http;
  }
}

abstract class HttpBook {
  static final DioCacheManager dataCache = DioCacheManager(CacheConfig(
    databaseName: 'data',
    defaultMaxAge: Duration(days: 30),
  ));
  final String id;
  final String name;

  final Dio dio;

  HttpBook(this.id, this.name, this.dio);

  Future<List<Book>> searchBook(String name, [int page]);

  Future<Book> getBook(String aid);

  Future<List<String>> getChapterImages(Book book, Chapter chapter);

  Future<List<int>> getImage(String url);

  Future<List<Book>> hotBooks([String type = '', int page]);
}

void SetProxy(Dio dio, String proxy) {
  if (proxy != null) {
    proxy = 'PROXY $proxy';
    // print('setProxy $proxy');
    final adapter = DefaultHttpClientAdapter();
    adapter.onHttpClientCreate = (HttpClient client) {
      client.findProxy = (uri) {
        //proxy all request to localhost:8888
        return proxy;
      };
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
    dio.httpClientAdapter = adapter;
  }
}
