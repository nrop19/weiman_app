import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../classes/book.dart';
import '../../crawler/http.dart';

class SearchSourceList extends LoadingMoreBase<Book> {
  final HttpBook http;
  String search;
  int page = 1;
  bool hasMore = true;
  String eachPageFirstBookId;

  SearchSourceList({
    @required this.http,
    this.search = '',
  });

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    print('搜书 $search');
    if (search == null || search.isEmpty) return true;
    final list = await http.searchBook(search, page);
    if (list.isEmpty) {
      hasMore = false;
    } else if (list[0].aid == eachPageFirstBookId) {
      hasMore = false;
    } else {
      eachPageFirstBookId = list[0].aid;
      hasMore = true;
      page++;
      this.addAll(list);
    }
    return true;
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) {
    page = 1;
    hasMore = true;
    eachPageFirstBookId = null;
    clear();
    print('refresh $page $hasMore');
    return super.refresh(notifyStateChanged);
  }
}
