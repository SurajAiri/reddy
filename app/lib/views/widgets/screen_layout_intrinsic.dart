import 'package:flutter/material.dart';

import '../../config/utils/constants.dart';

class ScreenLayoutIntrinsic extends StatelessWidget {
  const ScreenLayoutIntrinsic({
    super.key,
    this.children = const <Widget>[],
    this.crossAxisAlignment = CrossAxisAlignment.start,
    EdgeInsets padding = kPagePadding,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: kPagePadding,
                child: Column(
                  crossAxisAlignment: crossAxisAlignment,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
