part of '../main.dart';

class MyHttpClient {
  static Future init() async {
    final ca = await rootBundle.load('assets/ca.crt');
    final SecurityContext context = SecurityContext.defaultContext;
    context.setTrustedCertificatesBytes(ca.buffer.asUint8List());

    final version = Random().nextInt(10) + 72;
    final userAgent =
        'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/$version.0.4056.3 Mobile Safari/537.36';

    final ioClient = new HttpClient()
      ..badCertificateCallback = (_, __, ___) => true;
    ioClient.userAgent = userAgent;
    final client = IOClient(ioClient);
  }
}

abstract class UserAgentClient extends http.BaseClient {
  final http.Client inner;

  UserAgentClient(this.inner);

  Future<List<Book>> searchBook(String name);

  Future<Book> getBook(String aid);

  Future<List<String>> getChapterImages(Book book, Chapter chapter);
}
