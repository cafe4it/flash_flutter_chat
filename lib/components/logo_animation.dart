import 'package:flutter/material.dart';

class LogoAnimation extends StatelessWidget {
  const LogoAnimation({
    Key key,
    @required this.height
  }) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Hero(
        tag: 'logo',
        child: Container(
          child: Image.asset('images/logo.png'),
          height: height,
        ),
      ),
    );
  }
}