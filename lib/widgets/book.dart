part of '../main.dart';

class WidgetBook extends StatelessWidget {
  final Book book;
  final String subtitle;
  final Function(Book) onTap;

  const WidgetBook(
    this.book, {
    Key key,
    @required this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isLiked = book.isFavorite();
    return ListTile(
      title: Text(
        book.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      dense: true,
      leading: Hero(
          tag: 'bookAvatar${book.aid}',
          child: Image.network(
            book.avatar,
            height: 200,
            fit: BoxFit.scaleDown,
          )),
      trailing: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.grey,
        size: 12,
      ),
      onTap: () {
        if (onTap != null) onTap(book);
        openBook(context, book, 'bookAvatar${book.aid}');
      },
    );
  }
}

class WidgetChapter extends StatelessWidget {
  static final double height = 56;
  final Chapter chapter;
  final Function(Chapter) onTap;
  final bool read;

  WidgetChapter({
    Key key,
    this.chapter,
    this.onTap,
    this.read,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <InlineSpan>[TextSpan(text: chapter.cname)];
    if (read) {
      children.insert(
          0,
          TextSpan(
            text: '[已看]',
            style: TextStyle(color: Colors.orange),
          ));
    }
    return ListTile(
      onTap: () {
        if (onTap != null) onTap(chapter);
      },
      title: RichText(
        text: TextSpan(
          children: children,
          style: Theme.of(context).textTheme.body1,
        ),
        softWrap: true,
        maxLines: 2,
      ),
      leading: Image.network(
        chapter.avatar,
        fit: BoxFit.fitWidth,
        width: 100,
      ),
    );
  }
}

class WidgetHistory extends StatelessWidget {
  final Book book;
  final Function(Book book) onTap;

  WidgetHistory(this.book, this.onTap);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListTile(
        onTap: () {
          if (onTap != null) onTap(book);
        },
        title: Text(book.name),
        leading: Image.network(
          book.avatar,
          fit: BoxFit.fitHeight,
        ),
        subtitle: Text(book.history.cname),
      ),
    );
  }
}

class WidgetBookCheckNew extends StatefulWidget {
  final Book book;

  const WidgetBookCheckNew({Key key, this.book}) : super(key: key);

  @override
  _WidgetBookCheckNew createState() => _WidgetBookCheckNew();
}

class _WidgetBookCheckNew extends State<WidgetBookCheckNew> {
  bool loading = true, hasError = false;
  int news;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    loading = true;
    try {
      final book = await UserAgentClient.instance
          .getBook(aid: widget.book.aid)
          .timeout(Duration(seconds: 2));
      news = book.chapterCount - widget.book.chapterCount;
      hasError = false;
    } catch (e) {
      hasError = true;
    }
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (widget.book.history != null)
      children.add(Text(
        widget.book.history.cname,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ));

    if (loading)
      children.add(Text('检查更新中'));
    else if (hasError)
      children.add(Text('网络错误'));
    else if (news > 0)
      children.add(Text('有 $news 章更新'));
    else
      children.add(Text('没有更新'));
    return ListTile(
      onTap: () =>
          openBook(context, widget.book, 'checkBook${widget.book.aid}'),
      leading: Hero(
        tag: 'checkBook${widget.book.aid}',
        child: Image.network(widget.book.avatar),
      ),
      dense: true,
      isThreeLine: true,
      title: Text(widget.book.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
