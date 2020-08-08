import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_widget/focus_widget.dart';

import '../../crawler/http18Comic.dart';
import 'tab.dart';

class ActivitySearch extends StatefulWidget {
  final String search;

  const ActivitySearch({Key key, this.search = ''}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SearchState();
  }
}

class SearchState extends State<ActivitySearch>
    with SingleTickerProviderStateMixin {
  TextEditingController _controller;
  GlobalKey<SearchTabState> key = GlobalKey<SearchTabState>();

  @override
  initState() {
    _controller = TextEditingController(text: widget.search);
    super.initState();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  void search() {
    key.currentState.search = _controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (RawKeyEvent event) {
            print('is enter: ${LogicalKeyboardKey.enter == event.logicalKey}');
            if (_controller.text.isEmpty) return;
            if (event.runtimeType == RawKeyUpEvent &&
                LogicalKeyboardKey.enter == event.logicalKey) {
              print('回车键搜索');
              search();
            }
          },
          child: FocusWidget.builder(
            context,
            builder: (_, focusNode) => TextField(
              focusNode: focusNode,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '搜索书名',
                prefixIcon: IconButton(
                  onPressed: search,
                  icon: Icon(Icons.search, color: Colors.white),
                ),
              ),
              textAlign: TextAlign.left,
              controller: _controller,
              autofocus: widget.search.isEmpty,
              textInputAction: TextInputAction.search,
              onSubmitted: (String name) {
                focusNode.unfocus();
                print('onSubmitted');
                search();
              },
              keyboardType: TextInputType.text,
              onEditingComplete: () {
                focusNode.unfocus();
                print('onEditingComplete');
                search();
              },
            ),
          ),
        ),
      ),
      body: SearchTab(
        name: Http18Comic.instance.name,
        http: Http18Comic.instance,
        search: _controller.text,
        key: key,
      ),
    );
  }
}
