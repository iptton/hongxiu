
import 'package:flutter/material.dart';
import 'package:flutter_ebook/background_text.dart';

Widget buildAppBar(BuildContext context,[String title='']) => BackgroundText(
  background: Image.asset(
    'assets/images/logo_banner.png',
    color:Theme.of(context).primaryColor.withOpacity(0.5),
    colorBlendMode: BlendMode.modulate,
  ),
  text: Text(title),
);