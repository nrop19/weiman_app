import 'dart:convert';

import 'package:flutter/material.dart';

class Chapter {
  final String cid; // 章节cid
  final String cname; // 章节名称
  final DateTime time; // 章节更新时间

  Chapter({
    @required this.cid,
    @required this.cname,
    this.time,
  });

  @override
  String toString() {
    final Map<String, String> data = {
      'cid': cid,
      'cname': cname,
    };
    return jsonEncode(data);
  }
}
