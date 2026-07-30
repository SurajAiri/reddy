import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.widthRatio = 0.6,
    this.backgroundColor = Colors.green,
    this.foregroundColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
    this.radius = 16,
    this.reverseStyle = false,
    this.isLoading = false,
  });
  final Function() onPressed;
  final String title;
  final double widthRatio;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsets padding;
  final double radius;
  final bool reverseStyle;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: reverseStyle ? foregroundColor : backgroundColor,
        foregroundColor: reverseStyle ? backgroundColor : foregroundColor,
        minimumSize: Size(MediaQuery.of(context).size.width * widthRatio, 25),
        padding: padding,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      child: isLoading
          ? const CircularProgressIndicator()
          : Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
    );
  }
}
