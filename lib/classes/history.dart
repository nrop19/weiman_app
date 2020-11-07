import 'package:flutter/material.dart';

import 'package:weiman/classes/chapter.dart';

class History extends Chapter {
  DateTime time; // 历史时间

  History({
    @required cid,
    @required cname,
    @required this.time,
  }) : super(cid: cid, cname: cname);

  Map<String, dynamic> toJson() {
    return {'cid': cid, 'cname': cname, 'time': time};
  }

  factory History.fromJson(Map<String, dynamic> map) {
    if (map == null) return null;
    return History(
      cid: map['cid'],
      cname: map['cname'],
      time: map['time'],
    );
  }

  factory History.fromChapter(Chapter chapter) {
    return History(
      cid: chapter.cid,
      cname: chapter.cname,
      time: DateTime.now(),
    );
  }
}
