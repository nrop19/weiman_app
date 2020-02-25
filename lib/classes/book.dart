part of '../main.dart';

class Book {
  static String cachePath;
  final String aid; // 书本ID
  final String name; // 书本名称
  final String avatar; // 书本封面
  final String author; // 画家
  final String description; // 描述
  final List<Chapter> chapters;
  final int chapterCount;
  final bool fromCache;

  History history;

  Book({
    @required this.name,
    @required this.aid,
    @required this.avatar,
    this.author,
    this.description,
    this.chapters: const [],
    this.chapterCount: 0,
    this.fromCache: false,
    this.history,
  });

  static Future<void> initCachePath() async {
    final Directory dir = await getTemporaryDirectory();
    if (!dir.existsSync()) dir.createSync();
    cachePath = path.join(dir.path, 'books');
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  bool isFavorite() {
    var books = Data.getFavorites();
    return books.containsKey(aid);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'aid': aid,
      'name': name,
      'avatar': avatar,
      'author': author,
      'chapterCount': chapterCount,
    };
    if (history != null) data['history'] = history.toJson();
    return data;
  }

  static Book fromJson(Map<String, dynamic> json) {
    final book = Book(
      aid: json['aid'],
      name: json['name'],
      avatar: json['avatar'],
      author: json['author'],
      description: json['description'],
      chapterCount: json['chapterCount'] ?? 0,
    );
    if (json.containsKey('history'))
      book.history = History.fromJson(json['history']);
    return book;
  }

  Future<void> saveBookCache() async {
    final file = File(path.join(cachePath, '$aid.json'));
    if (!file.existsSync()) file.createSync(recursive: true);
    await file.writeAsString(
      jsonEncode(
        {
          'aid': aid,
          'name': name,
          'author': author,
          'avatar': avatar,
          'description': description,
          'chapters':
              chapters.map<String>((chapter) => chapter.toString()).toList(),
        },
      ),
    );
  }

  static Future<Book> loadBookCache(String aid) async {
    final file = File(path.join(cachePath, '$aid.json'));
    print('loadBookCache ${file.path}');
    if (file.existsSync()) {
      final json = jsonDecode(await file.readAsString());
      final List<dynamic> chapters = json['chapters'] ?? [];
      print('chapters ${json['chapters'][0]}');
      return Book(
        aid: json['aid'],
        name: json['name'],
        avatar: json['avatar'],
        description: json['description'],
        author: json['author'],
        fromCache: true,
        chapters: chapters.map((str) => Chapter.fromJsonString(str)).toList(),
        chapterCount: chapters.length,
        history: json['history'] == null
            ? null
            : History.fromJson(jsonDecode(json['history'])),
      );
    }
    return null;
  }
}

class Chapter {
  final String cid; // 章节cid
  final String cname; // 章节名称
  final String avatar; // 章节封面

  Chapter({
    @required this.cid,
    @required this.cname,
    @required this.avatar,
  });

  @override
  String toString() {
    final Map<String, String> data = {
      'cid': cid,
      'cname': cname,
      'avatar': avatar,
    };
    return jsonEncode(data);
  }

  static Chapter fromJsonString(String str) {
    return fromJson(jsonDecode(str));
  }

  static List<String> fromCache(Book book, Chapter chapter) {
    final file =
        File(path.join(Book.cachePath, '${book.aid}_${chapter.cid}.json'));
    if (file.existsSync()) return  List<String>.from(jsonDecode(file.readAsStringSync()));
    return null;
  }

  static Future<void> saveCache(
      Book book, Chapter chapter, List<String> images) async {
    print('chapter save cache ${chapter.cid}');
    final file =
        File(path.join(Book.cachePath, '${book.aid}_${chapter.cid}.json'));
    if (file.existsSync() == false) file.createSync();
    return file.writeAsString(jsonEncode(images));
  }

  static fromJson(data) {
    return Chapter(
      cid: data['cid'],
      cname: data['cname'],
      avatar: data['avatar'],
    );
  }
}

class History {
  final String cid;
  final String cname;
  final int time;

  History({@required this.cid, @required this.cname, @required this.time});

  @override
  String toString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      'cname': cname,
      'time': time,
    };
  }

  static History fromJson(Map<String, dynamic> json) {
    return History(cid: json['cid'], cname: json['cname'], time: json['time']);
  }

  static History fromChapter(Chapter chapter) {
    return History(
      cid: chapter.cid,
      cname: chapter.cname,
      time: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
