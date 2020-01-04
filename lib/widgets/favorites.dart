part of '../main.dart';

class FavoriteList extends StatefulWidget {
  @override
  _FavoriteList createState() => _FavoriteList();
}

class _FavoriteList extends State<FavoriteList> {
  static final Map<String, int> hasNews = {};
  static final List<Book> all = [], // 所有收藏
      inWeek = [], // 7天看过的收藏
      other = []; // 其他收藏
  static bool showTip = false;

  static final loadFailTextSpan = TextSpan(
          text: '读取失败，下拉刷新', style: TextStyle(color: Colors.redAccent)),
      waitToCheck =
          TextSpan(text: '等待检查更新', style: TextStyle(color: Colors.grey)),
      unCheck =
          TextSpan(text: '请下拉列表检查更新', style: TextStyle(color: Colors.grey)),
      noUpdate = TextSpan(text: '没有更新', style: TextStyle(color: Colors.grey));

  static void getBooks() {
    all.clear();
    inWeek.clear();
    other.clear();
    all.addAll(Data.getFavorites().values);
    if (all.isNotEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch;
      all.forEach((book) {
        if (book.history != null && (now - book.history.time) < weekTime) {
          inWeek.add(book);
        } else {
          other.add(book);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getBooks();
    if (all.isNotEmpty) {
      if (showTip == false) {
        showTip = true;
        Fluttertoast.showToast(
          msg: '下拉列表可以检查漫画更新',
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black.withOpacity(0.5),
        );
      }
    }
  }

  void _openBook(book) {
    openBook(context, book, 'fb ${book.aid}');
  }

  static Future<void> checkNews() async {
    hasNews.clear();
    Book currentBook, newBook;
    int different;
    for (var i = 0; i < all.length; i++) {
      currentBook = all[i];
      try {
        newBook = await UserAgentClient.instance
            .getBook(aid: currentBook.aid)
            .timeout(Duration(seconds: 2));
        different = newBook.chapterCount - currentBook.chapterCount;
        hasNews[currentBook.aid] = different;
      } catch (e) {
        hasNews[currentBook.aid] = -1;
      }
    }
  }

  Widget bookBuilder(Book book) {
    TextSpan state;
    if (hasNews.isEmpty) {
      state = unCheck;
    } else {
      if (hasNews.containsKey(book.aid)) {
        if (hasNews[book.aid] > 0) {
          state = TextSpan(
              text: '有 ${hasNews[book.aid]} 章更新',
              style: TextStyle(color: Colors.green));
        } else if (hasNews[book.aid] == -1) {
          state = loadFailTextSpan;
        } else if (hasNews[book.aid] == 0) {
          state = noUpdate;
        }
      } else {
        state = waitToCheck;
      }
    }
    return FBookItem(
      book: book,
      subtitle: state,
      onTap: _openBook,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Book> inWeekUpdated = [],
        inWeekUnUpdated = [],
        otherUpdated = [],
        otherUnUpdated = [];
    inWeek.forEach((book) {
      if (hasNews.containsKey(book.aid) && hasNews[book.aid] > 0)
        inWeekUpdated.add(book);
      else
        inWeekUnUpdated.add(book);
    });
    other.forEach((book) {
      if (hasNews.containsKey(book.aid) && hasNews[book.aid] > 0)
        otherUpdated.add(book);
      else
        otherUnUpdated.add(book);
    });
    return Drawer(
      child: RefreshIndicator(
        onRefresh: () async {
          await checkNews();
          setState(() {});
        },
        child: all.isEmpty
            ? Center(child: Text('没有收藏'))
            : SafeArea(
                child: CustomScrollView(
                slivers: [
                  SliverExpandableGroup(
                    title: Text('7天内看过并且有更新的藏书(${inWeekUpdated.length})'),
                    expanded: true,
                    count: inWeekUpdated.length,
                    builder: (ctx, i) => bookBuilder(inWeekUpdated[i]),
                  ),
                  SliverExpandableGroup(
                    title: Text('7天内看过的藏书(${inWeekUnUpdated.length})'),
                    count: inWeekUnUpdated.length,
                    builder: (ctx, i) => bookBuilder(inWeekUnUpdated[i]),
                  ),
                  SliverExpandableGroup(
                    title: Text('有更新的藏书(${otherUpdated.length})'),
                    count: otherUpdated.length,
                    builder: (ctx, i) => bookBuilder(otherUpdated[i]),
                  ),
                  SliverExpandableGroup(
                    title: Text('没有更新的藏书(${otherUnUpdated.length})'),
                    count: otherUnUpdated.length,
                    builder: (ctx, i) => bookBuilder(otherUnUpdated[i]),
                  ),
                ],
              )),
      ),
    );
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
      leading: Hero(tag: 'fb ${book.aid}', child: Image(image:NetworkImageSSL(book.avatar))),
      title: Text(book.name, style: Theme.of(context).textTheme.body1),
      subtitle: RichText(text: subtitle),
    );
  }
}
