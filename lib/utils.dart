part of 'main.dart';

final weekTime = Duration.millisecondsPerDay * 7;

void openBook(BuildContext context, Book book, String heroTag) {
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
