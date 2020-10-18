import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weiman/activities/book/book.dart';
import 'package:weiman/activities/chapter/activity.dart';
import 'package:weiman/activities/search/search.dart';
import 'package:weiman/classes/chapter.dart';
import 'package:weiman/db/book.dart';

final weekTime = Duration.millisecondsPerDay * 7;

void openSearch(BuildContext context, String word) {}

Future openBook(BuildContext context, Book book, String heroTag) {
  print('openBook $book');
  if (book.http == null) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: '/activity_search/${book.name}'),
        builder: (_) => ActivitySearch(search: book.name),
      ),
    );
  }
  return Navigator.push(
    context,
    MaterialPageRoute(
      settings: RouteSettings(name: '/activity_book/${book.name}'),
      builder: (_) => ActivityBook(book: book, heroTag: heroTag),
    ),
  );
}

Future<void> openChapter(BuildContext context, Book book, Chapter chapter) {
  return Navigator.push(
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
