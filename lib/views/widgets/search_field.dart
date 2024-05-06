import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.hintText = "Enter search term",
    this.controller,
    this.onEditingComplete,
    this.enabled = true,
    this.focusNode,
  });
  final String hintText;
  final TextEditingController? controller;
  final Function()? onEditingComplete;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xff738CAF),
          width: 0.5,
        ),
      ),
      child: TextFormField(
        // style: context.regularStyle().copyWith(height: 0.9),
        style: const TextStyle(
          height: 0.9,
          // fontSize: 16,
        ),
        focusNode: focusNode,
        onEditingComplete: onEditingComplete,
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(),
          counterText: "",
          hintText: hintText,
          // hintStyle: context.inputHintStyle(),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(6),
          ),
          // suffixIcon: IconButton(
          //   icon: const Icon(Icons.mic),
          //   onPressed: () {},
          // ),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
