part of '../main.dart';

class Book {
  final String aid; // 书本ID
  final String name; // 书本名称
  final String avatar; // 书本封面
  final String author; // 画家
  final String description; // 描述
  final List<Chapter> chapters;
  final int chapterCount;

  History history;

  Book({
    @required this.name,
    @required this.aid,
    @required this.avatar,
    this.author,
    this.description,
    this.chapters: const [],
    this.chapterCount: 0,
  });

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  bool isFavorite() {
    var books = Data.getFavorites();
    return books.containsKey(aid);
  }

  favorite() {
    if (isFavorite())
      Data.removeFavorite(this);
    else
      Data.addFavorite(this);
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
}

class Chapter {
  final String cid; // 章节cid
  final String cname; // 章节名称
  final String avatar; // 章节封面

  Chapter({@required this.cid, @required this.cname, @required this.avatar});

  @override
  String toString() {
    return jsonEncode({cid: cid, cname: cname, avatar: avatar});
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
