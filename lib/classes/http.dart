part of '../main.dart';

const domain = '';
final host = Uri.parse(domain).host;

class UserAgentClient extends http.BaseClient {
  final String userAgent;
  http.Client _inner;
  String lastKey;
  int lastKeyTime = 0;

  static UserAgentClient instance;

  UserAgentClient(this.userAgent) {
  }

  Future<String> getKey() async {
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
  }

  Future<List<String>> getImages(
  }

  Future<Book> getBook({String aid}) async {
  }

  static String _decrypt({String key, String content}) {
  }

  Future<List<Book>> searchBook(String name) async {
  }

  static void init(String userAgent) {
  }

  Future<http.Response> _get(url, {Map<String, String> headers}) async {
  }

  Future<List<Book>> getMonthList() async {
  }

  Future<List<Book>> getIndexRandomBooks() async {
  }
}
