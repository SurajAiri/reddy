import 'package:flutter/material.dart';
import 'package:reddy/config/utils/constants.dart';

class ScreenLayout extends StatelessWidget {
  const ScreenLayout({
    super.key,
    this.children = const <Widget>[],
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.padding = kPagePadding,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          ),
        ),
      ),
    );
  }
}
