import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'book.dart';

class Data {
  static SharedPreferences instance;
  static final favoriteBooksKey = 'favorite_books';
  static final viewHistoryKey = 'view_history';
  static final quickKey = 'quick_list';

  static Future init() async {
    instance = await SharedPreferences.getInstance();
  }

  static set<T>(String key, T value) {
    if (value is String) {
      instance.setString(key, value);
    } else if (value is int) {
      instance.setInt(key, value);
    } else if (value is bool) {
      instance.setBool(key, value);
    } else if (value is List<String>) {
      instance.setStringList(key, value);
    } else if (value is double) {
      instance.setDouble(key, value);
    } else if (value is Map) {
      instance.setString(key, json.encode(value));
    }
  }

  static dynamic get(String key) {
    return instance.get(key);
  }

  static Map<String, Book> getFavorites() {
    if (has(favoriteBooksKey)) {
      final String str = instance.getString(favoriteBooksKey);
      Map<String, Object> data = jsonDecode(str);
      Map<String, Book> res = {};
      data.keys.forEach((key) {
        res[key] = Book.fromJson(data[key]);
      });
      return res;
    }
    return {};
  }

  static void addFavorite(Book book) {
    var books = getFavorites();
    books[book.aid] = book;
    set<Map>(favoriteBooksKey, books);
  }

  static void removeFavorite(Book book) {
    var books = getFavorites();
    if (books.containsKey(book.aid)) {
      books.remove(book.aid);
      set<Map>(favoriteBooksKey, books);
      reQuick();
    }
  }

  static clear() {
    instance.clear();
  }

  static bool has(String key) {
    return instance.containsKey(key);
  }

  static remove(String key) {
    instance.remove(key);
  }

  static Map<String, Book> getHistories() {
    if (has(viewHistoryKey)) {
      var data =
          jsonDecode(instance.getString(viewHistoryKey)) as Map<String, Object>;
      final Map<String, Book> histories = {};
      data.forEach((key, value) {
        histories[key] = Book.fromJson(value);
      });
      return histories;
    }
    return {};
  }

  static addHistory(Book book, Chapter chapter) {
    book.history = History(
        cid: chapter.cid,
        cname: chapter.cname,
        time: DateTime.now().millisecondsSinceEpoch);
    final books = getHistories();
    books[book.aid] = book;
    set(viewHistoryKey, books);
    // print('保存历史\n' + books.toString());
  }

  static removeHistory(bool Function(Book book) isDelete) {
    var books = getHistories();
    books.keys
        .where((key) => isDelete(books[key]))
        .toList()
        .forEach(books.remove);
    set(viewHistoryKey, books);
  }

  static removeHistoryFromBook(Book book) {
    final books = getHistories();
    books.remove(book.aid);
    set(viewHistoryKey, books);
  }

  /// 快速导航 id 列表，内部方法
  static List<String> quickIdList() {
    if (instance.containsKey(quickKey)) {
      return instance.getStringList(quickKey);
    }
    return [];
  }

  /// 快速导航列表
  static List<Book> quickList() {
    final books = getFavorites();
    final ids = books.keys;
    final List<String> quickIds = quickIdList();
    print('快捷 $quickIds');
    return quickIds
        .where((id) => ids.contains(id))
        .map((id) => books[id])
        .toList();
  }

  /// 增加快速导航
  static addQuick(Book book) {
    final list = quickIdList();
    list.add(book.aid);
    instance.setStringList(quickKey, list.toSet().toList());
  }

  static addQuickAll(List<String> id) {
    print('保存qid $id');
    instance.setStringList(quickKey, id.toSet().toList());
  }

  /// 重新整理Quick的id列表
  static reQuick() {
    final books = getFavorites();
    final quickIds = quickIdList();
    instance.setStringList(
        quickKey, quickIds.where(books.keys.contains).toSet().toList());
  }
}
