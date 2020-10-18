import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weiman/db/setting.dart';

class ViewerSwitcherWidget extends StatefulWidget {
  @override
  ViewerSwitcherState createState() => ViewerSwitcherState();
}

class ViewerSwitcherState extends State<ViewerSwitcherWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Setting>(builder: (_, data, __) {
      final icon = data.getViewerSwitch()
          ? Icons.check_box_outlined
          : Icons.check_box_outline_blank;
      return
        TextButton.icon(
          icon: Icon(icon),
          label: Text('看图'),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            overlayColor:
            MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.3)),
            visualDensity: VisualDensity.compact,
          ),
          onPressed: () {
            data.setViewerSwitch(!data.getViewerSwitch());
            setState(() {});
          },
        );
    });
  }
}
