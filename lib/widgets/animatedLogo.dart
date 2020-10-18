import 'package:flutter/material.dart';
import 'package:sa_anicoto/sa_anicoto.dart';

class AnimatedLogoWidget extends StatefulWidget {
  final double width, height;

  const AnimatedLogoWidget({
    Key key,
    @required this.width,
    @required this.height,
  }) : super(key: key);

  @override
  _AnimatedLogoWidget createState() => _AnimatedLogoWidget();
}

class _AnimatedLogoWidget extends State<AnimatedLogoWidget>
    with AnimationMixin {
  Animation<double> size; // Declare animation variable

  @override
  void initState() {
    size = Tween<double>(begin: 0, end: widget.height - 20).animate(controller);
    controller.mirror(
        duration: Duration(seconds: 1)); // Start the animation playback
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size.value,
            child: Image.asset(
              'assets/logo.png',
              width: 20,
              height: 20,
            ),
          ),
        ],
      ),
    );
  }
}
