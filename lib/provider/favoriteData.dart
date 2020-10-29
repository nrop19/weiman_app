import 'package:flutter/material.dart';
import 'package:weiman/db/book.dart';
import 'package:weiman/db/group.dart';

class FavoriteData extends ChangeNotifier {
  final List<Book> all = [], others = [];
  final Map<Group, List<Book>> groups = {};

  FavoriteData() {
    loadBooksList();
  }

  Future<void> loadBooksList([notify = false]) async {
    final groupList = Group.groupBox.values.toList();
    final groupMap = {for (final group in groupList) group.key: group};
    groups.clear();
    groupList.forEach((group) {
      groups[group] = [];
    });

    all.clear();
    others.clear();

    // if(isDevMode){
    //   final temp = [
    //     Book(
    //       aid: '180454',
    //       name: '朋友，女朋友',
    //       avatar:
    //       'https://cdn-msp.18comic.org/media/albums/206567.jpg',
    //       chapterCount: 0,
    //       httpId: '18',
    //       needUpdate: false,
    //       authors: [],
    //     ),
    //     Book(
    //       aid: '206567',
    //       name: '抑欲人妻',
    //       avatar:
    //       'https://cdn-msp.18comic.org/media/albums/206567.jpg',
    //       chapterCount: 0,
    //       httpId: '18',
    //       needUpdate: true,
    //       authors: [],
    //     ),
    //     Book(
    //       aid: '147335',
    //       name: '亲爱的大叔',
    //       avatar:
    //       'https://cdn-msp.msp-comic.xyz/media/albums/147335.jpg',
    //       chapterCount: 0,
    //       httpId: '18',
    //       needUpdate: true,
    //       authors: [],
    //     ),
    //   ];
    //   all.addAll(temp);
    //   others.addAll(temp);
    // }

    Book.bookBox.values.forEach((book) {
      if (book.favorite != true) return;
      all.add(book);
      if (groupMap.containsKey(book.groupId)) {
        //有分组的藏书
        groups[groupMap[book.groupId]].add(book);
      } else {
        //没有分组的藏书
        others.add(book);
      }
    });

    print({'all': all.length, 'other': others.length});

    if (notify) notifyListeners();
  }

  Future<int> checkUpdate() async {
    final groupList = [others, ...groups.values];
    for (final array in groupList) {
      for (final book in array) {
        if (book.httpId == null) {
          book.status = BookUpdateStatus.old;
        } else if (book.needUpdate != true) {
          book.status = BookUpdateStatus.not;
        } else {
          book.status = BookUpdateStatus.wait;
        }
        notifyListeners();
        if (book.status != BookUpdateStatus.wait) continue;
        book.status = BookUpdateStatus.loading;
        notifyListeners();
        await book.update();
        if (book.status == BookUpdateStatus.had) sort(array, book);
        notifyListeners();
      }
    }
    return all.where((book) => book.status == BookUpdateStatus.had).length;
  }

  /// 显示在前排
  void sort(List<Book> array, Book book) {
    print('sort ${book.name}');
    array.remove(book);
    array.insert(0, book);
  }

  Future<void> deleteBook(Book book) async {
    book.favorite = false;
    await book.save();
    // print('删书 ${book.name} 成功');
    loadBooksList(true);
  }

  Future<void> deleteGroup(Group group, [bool deleteBooks = false]) async {
    if (deleteBooks && groups.containsKey(group)) {
      await Future.wait(groups[group].map((book) => book.setFavorite(false)));
    }
    await Group.groupBox.delete(group.key);
    await loadBooksList(true);
  }

  Future<void> addGroup(Group group) async {
    group.save();
    await loadBooksList(true);
  }

  Future<void> addBook(Book book) async {
    book.favorite = true;
    await book.save();
    loadBooksList(true);
  }
}
