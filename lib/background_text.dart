
import 'package:flutter/material.dart';

class BackgroundText extends StatelessWidget {

  final Widget background;
  final Text text;

  const BackgroundText({Key key, this.background, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            child: background,
            color: Theme.of(context).primaryColor.withAlpha(122),
          ),
          Center(child: text),
        ],
      ),
    );
  }
}