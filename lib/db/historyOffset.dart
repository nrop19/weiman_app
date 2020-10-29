import 'package:hive/hive.dart';

const HistoryOffsetName = 'history';

class HistoryOffset {
  static Box box;

  static double get(String cid) {
    print('get $cid');
    return box.get(cid) ?? 0.0;
  }

  static Future<void> save(String cid, double offset) {
    print('save $cid $offset');
    return box.put(cid, offset);
  }
}
