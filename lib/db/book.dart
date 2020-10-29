import 'package:hive/hive.dart';

import 'package:weiman/classes/chapter.dart';
import 'package:weiman/classes/history.dart';
import 'package:weiman/crawler/http.dart';
import 'package:weiman/db/group.dart';

part 'book.g.dart';

const BookName = 'book';
enum BookUpdateStatus {
  not, // 不检查更新
  no, // 没有更新
  had, // 有更新
  fail, // 检查更新失败
  wait, // 检查更新的队列中
  loading, // 正在检查更新
  old, // 旧藏书，不检查更新
}

@HiveType(typeId: 1)
class Book extends HiveObject {
  static Box<Book> bookBox;

  @HiveField(0)
  String aid;

  @HiveField(1)
  String name;

  @HiveField(2)
  String avatar;

  @HiveField(3)
  List<String> authors;

  @HiveField(4)
  String description;

  @HiveField(5)
  int chapterCount;

  // [新章节数量]减[旧章节数量]得到的差值
  int newChapterCount;

  BookUpdateStatus status;

  List<Chapter> chapters;

  List<String> tags;

  @HiveField(6)
  bool favorite;

  @HiveField(7)
  bool needUpdate;

  @HiveField(8)
  bool hasUpdate;

  @HiveField(9)
  DateTime updatedAt;

  // 首页快速导航
  @HiveField(10)
  int quick;

  @HiveField(11)
  Map<String, dynamic> _history;

  @HiveField(12)
  int groupId;

  @HiveField(13)
  String httpId;

  bool look = false;

  Group get group =>
      groupId == null ? null : Group.groupBox.get(groupId, defaultValue: null);

  HttpBook get http => MyHttpClient.clients[httpId];

  History get history => History.fromJson(_history);

  Future setFavorite(bool value) {
    favorite = value;
    return save();
  }

  Future setHistory(Chapter value) {
    if (value == null) {
      _history = null;
    } else {
      _history = History.fromChapter(value).toJson();
    }
    return save();
  }

  Book({
    this.httpId,
    this.aid,
    this.name,
    this.groupId,
    this.avatar,
    this.authors,
    this.description,
    this.chapterCount,
    this.favorite = false,
    this.needUpdate = false,
    this.quick,
    this.chapters = const [],
    this.tags = const [],
    Map<String, dynamic> history,
  }) : _history = history;

  @override
  String toString() {
    return 'Book:${toJson()}';
  }

  toJson() {
    return {
      'key': key,
      'aid': aid,
      'name': name,
      'httpId': httpId,
      'groupId': groupId,
      'favorite': favorite,
      'history': _history,
      'status': status,
      'chapterCount': chapterCount,
    };
  }

  bool needToSave() {
    return favorite == true || _history != null || quick != null;
  }

  @override
  Future<void> save() {
    if (needToSave()) {
      return bookBox.put(aid, this);
    }
    return bookBox.delete(aid);
  }

  Future<bool> load() async {
    if (httpId == null) return false;
    final newBook = await this.http.getBook(aid);
    print('load newBook:${newBook.httpId}');
    chapters = newBook.chapters;
    chapterCount = newBook.chapterCount;
    authors = newBook.authors;
    description = newBook.description;
    httpId = newBook.httpId;
    tags = newBook.tags;
    print('book httpId $httpId');
    return true;
  }

  Future<List<String>> loadChapter(Chapter chapter) async {
    if (httpId == null) return null;
    return this.http.getChapterImages(this, chapter);
  }

  Future<void> update() async {
    try {
      final newBook = await this.http.getBook(aid);
      print('$name 旧$chapterCount 新${newBook.chapterCount}');
      newChapterCount = newBook.chapterCount - chapterCount;
      status = newChapterCount > 0 ? BookUpdateStatus.had : BookUpdateStatus.no;
    } catch (e) {
      status = BookUpdateStatus.fail;
    }
    print('book update $status');
  }
}
