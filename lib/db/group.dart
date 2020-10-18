import 'package:hive/hive.dart';

import 'book.dart';

part 'group.g.dart';

const GroupName = 'group';

@HiveType(typeId: 0)
class Group extends HiveObject {
  static Box<Group> groupBox;
  static Box<Book> bookBox;

  @HiveField(0)
  String name;

  @HiveField(1)
  bool expended;

  Group(this.name, [this.expended = false]);

  List<Book> get books => bookBox.values
      .where((book) => book.favorite && book.groupId == this.key)
      .toList();

  @override
  String toString() {
    return 'Group:${{'key': key, 'name': name, 'books': books.length}}';
  }

  @override
  Future<void> save() {
    if (!isInBox) return groupBox.add(this);
    return super.save();
  }
}
