import 'package:flutter/material.dart';

class DrawerElement extends StatelessWidget {
  const DrawerElement({
    super.key,
    required this.title,
    required this.iconData,
    required this.onPressed,
  });

  final String title;
  final IconData iconData;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    MaterialColor bg = Colors.red;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            width: 1,
            color: bg[200]!,
          ),
        ),
        textColor: bg[400],
        iconColor: bg[400],
        tileColor: Colors.white,
        selectedColor: bg[500],
        hoverColor: bg[500],
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        leading: Icon(
          iconData,
        ),
        onTap: onPressed,
      ),
    );
  }
}
