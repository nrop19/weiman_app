part of '../main.dart';

class FavoriteData extends ChangeNotifier {
  /// -2 在队列中等待检查，-1读取错误，0 没有更新，> 0 更新的章节数量
  final Map<String, int> hasNews = {}; // 漫画的状态
  final Map<String, Book> all = {}, // 所有收藏
      inWeek = {}, // 7天内看过的收藏
      other = {}; // 其他收藏
  bool _loading;

  FavoriteData() {
    loadBooksList();
  }

  Future<void> loadBooksList() async {
    all
      ..clear()
      ..addAll(Data.getFavorites());
    calcBookHistory();
  }

  void add(Book book) {
    Data.addFavorite(book);
    all[book.aid] = book;
    calcBookHistory();
  }

  void remove(Book book) {
    Data.removeFavorite(book);
    all.remove(book.aid);
    calcBookHistory();
  }

  void calcBookHistory() {
    inWeek.clear();
    other.clear();
    if (all.isNotEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch;
      all.forEach((aid, book) {
        if (book.history != null && (now - book.history.time) < weekTime) {
          inWeek[aid] = book;
        } else {
          other[aid] = book;
        }
      });
    }
    notifyListeners();
  }

  Future<void> checkNews(AutoCheckLevel level) async {
    if (level == AutoCheckLevel.none) return;
    final _books = level == AutoCheckLevel.onlyInWeek ? inWeek : all;
    final keys = _books.keys;
    hasNews
      ..clear()
      ..addAll(_books.map((aid, book) => MapEntry(aid, -2)));
    notifyListeners();
    Book currentBook, newBook;
    for (var i = 0; i < _books.length; i++) {
      currentBook = _books[keys.elementAt(i)];
      try {
        newBook = await HttpHHMH39.instance
            .getBook(currentBook.aid)
            .timeout(Duration(seconds: 8));
        int different = newBook.chapterCount - currentBook.chapterCount;
        hasNews[currentBook.aid] = different;
        if (different > 0) {
          newBook.history = Data.getHistories()[newBook.aid]?.history;
          Data.addFavorite(newBook);
          newBook.saveBookCache();
        }
      } catch (e) {
        hasNews[currentBook.aid] = -1;
      }
    }
    notifyListeners();
  }
}

class FavoriteList extends StatefulWidget {
  @override
  _FavoriteList createState() => _FavoriteList();
}

class _FavoriteList extends State<FavoriteList> {
  static bool showTip = false;

  static final loadFailTextSpan = TextSpan(
          text: '读取失败，下拉刷新', style: TextStyle(color: Colors.redAccent)),
      waitToCheck =
          TextSpan(text: '等待检查更新', style: TextStyle(color: Colors.grey)),
      unCheck =
          TextSpan(text: '请下拉列表检查更新', style: TextStyle(color: Colors.grey)),
      noUpdate = TextSpan(text: '没有更新', style: TextStyle(color: Colors.grey));

  void _openBook(book) {
    openBook(context, book, 'fb ${book.aid}');
  }

  Widget bookBuilder(Book book, int state) {
    TextSpan _state = unCheck;
    if (state == null) {
      _state = unCheck;
    } else if (state > 0) {
      _state =
          TextSpan(text: '有 $state 章更新', style: TextStyle(color: Colors.green));
    } else if (state == 0) {
      _state = noUpdate;
    } else if (state == -1) {
      _state = loadFailTextSpan;
    } else if (state == -2) {
      _state = waitToCheck;
    }
    return FBookItem(
      book: book,
      subtitle: _state,
      onTap: _openBook,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingData, FavoriteData>(
        builder: (_, setting, favorite, __) {
      if (favorite.all.isEmpty) return Center(child: Text('没有收藏'));
      List<Book> inWeekUpdated = [],
          inWeekUnUpdated = [],
          otherUpdated = [],
          otherUnUpdated = [];
      favorite.inWeek.forEach((aid, book) {
        if (favorite.hasNews.containsKey(book.aid) &&
            favorite.hasNews[book.aid] > 0)
          inWeekUpdated.add(book);
        else
          inWeekUnUpdated.add(book);
      });
      favorite.other.forEach((aid, book) {
        if (favorite.hasNews.containsKey(book.aid) &&
            favorite.hasNews[book.aid] > 0)
          otherUpdated.add(book);
        else
          otherUnUpdated.add(book);
      });
      return Drawer(
        child: RefreshIndicator(
          onRefresh: () async {
            favorite.checkNews(AutoCheckLevel.all);
          },
          child: SafeArea(
              child: CustomScrollView(
            slivers: [
              SliverExpandableGroup(
                title: Text('7天内看过并且有更新的藏书(${inWeekUpdated.length})'),
                expanded: true,
                count: inWeekUpdated.length,
                builder: (ctx, i) => bookBuilder(
                  inWeekUpdated[i],
                  favorite.hasNews[inWeekUpdated[i].aid],
                ),
              ),
              SliverExpandableGroup(
                title: Text('7天内看过的藏书(${inWeekUnUpdated.length})'),
                count: inWeekUnUpdated.length,
                builder: (ctx, i) => bookBuilder(
                  inWeekUnUpdated[i],
                  favorite.hasNews[inWeekUnUpdated[i].aid],
                ),
              ),
              SliverExpandableGroup(
                title: Text('有更新的藏书(${otherUpdated.length})'),
                count: otherUpdated.length,
                builder: (ctx, i) => bookBuilder(
                  otherUpdated[i],
                  favorite.hasNews[otherUpdated[i].aid],
                ),
              ),
              SliverExpandableGroup(
                title: Text('没有更新的藏书(${otherUnUpdated.length})'),
                count: otherUnUpdated.length,
                builder: (ctx, i) => bookBuilder(
                  otherUnUpdated[i],
                  favorite.hasNews[otherUnUpdated[i].aid],
                ),
              ),
            ],
          )),
        ),
      );
    });
  }
}

class FBookItem extends StatelessWidget {
  final Book book;
  final TextSpan subtitle;
  final void Function(Book book) onTap;

  const FBookItem({
    Key key,
    @required this.book,
    @required this.subtitle,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(book),
      leading: Hero(
        tag: 'fb ${book.aid}',
        child: Image(
          image: ExtendedNetworkImageProvider(
            book.avatar,
            cache: true,
          ),
        ),
      ),
      title: Text(book.name, style: Theme.of(context).textTheme.body1),
      subtitle: RichText(text: subtitle),
    );
  }
}
