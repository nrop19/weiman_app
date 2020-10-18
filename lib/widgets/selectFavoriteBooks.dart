import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weiman/classes/networkImageSSL.dart';
import 'package:weiman/db/book.dart';
import 'package:weiman/provider/favoriteData.dart';

Future<Book> showFavoriteBooksDialog(BuildContext context) {
  return showDialog<Book>(
    context: context,
    builder: (_) => FavoriteBooksDialog(title: '将藏书添加到快速导航'),
  );
}

class FavoriteBooksDialog extends StatelessWidget {
  final String title;

  const FavoriteBooksDialog({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fav = Provider.of<FavoriteData>(context, listen: false);
    return AlertDialog(
      title: Text(title),
      scrollable: true,
      content: Column(
        children: ListTile.divideTiles(
          context: context,
          tiles: fav.all
              .where((book) => book.quick == null)
              .map(
                (book) => ListTile(
                  title: Text(book.name),
                  leading: ExtendedImage(
                    image: NetworkImageSSL(book.http, book.avatar),
                    fit: BoxFit.cover,
                    width: 40,
                  ),
                  onTap: () => Navigator.pop(context, book),
                ),
              )
              .toList(),
        ).toList(),
      ),
    );
  }
}
