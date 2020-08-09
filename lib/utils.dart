import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './main.dart';
import 'activities/book.dart';
import 'activities/chapter.dart';
import 'activities/search/search.dart';
import 'classes/book.dart';

final weekTime = Duration.millisecondsPerDay * 7;

void openBook(BuildContext context, Book book, String heroTag) {
  print('openBook ${book.name} version:${book.version}');
  if (book.version == null || book.version < version || book.http == null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: '/activity_search/${book.name}'),
        builder: (_) => ActivitySearch(search: book.name),
      ),
    );
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      settings: RouteSettings(name: '/activity_book/${book.name}'),
      builder: (_) => ActivityBook(book: book, heroTag: heroTag),
    ),
  );
}

void openChapter(BuildContext context, Book book, Chapter chapter) {
  Navigator.push(
    context,
    MaterialPageRoute(
      settings: RouteSettings(
          name: '/activity_chapter/${book.name}/${chapter.cname}'),
      builder: (_) => ActivityChapter(book, chapter),
    ),
  );
}

void showStatusBar() {
  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
}

void hideStatusBar() {
  SystemChrome.setEnabledSystemUIOverlays([]);
}
