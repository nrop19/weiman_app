part of '../main.dart';

const domain = '';

class UserAgentClient extends http.BaseClient {
  http.Client _inner = http.Client();
  String lastKey;
  int lastKeyTime = 0;

  static UserAgentClient instance;

//  UserAgentClient(this.userAgent);

  UserAgentClient(String userAgent, ByteData data) {
  }

  Future<String> getKey() async {
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
  }

  Future<List<String>> getImages(
      {@required String aid, @required String cid}) async {
  }

  Future<Book> getBook({String aid}) async {
  }

  static String _decrypt({String key, String content}) {
  }

  Future<List<Book>> searchBook(String name) async {
  }

  static void init() async {
  }

  Future<http.Response> _get(url, {Map<String, String> headers}) async {
  }

  Future<List<Book>> getMonthList() async {
  }

  Future<List<Book>> getIndexRandomBooks() async {
  }
}
