import 'package:flutter/material.dart';

class RedDropdown extends StatelessWidget {
  const RedDropdown({
    super.key,
    this.values = const [],
    this.onChanged,
    this.valueIndex = -1,
    this.hint,
  });
  final Function(int value)? onChanged;
  final List<String> values;
  final int valueIndex;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButton<String>(
        underline: const SizedBox(),
        items: values.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Center(
              child: Text(
                value,
              ),
            ),
          );
        }).toList(),
        value: valueIndex < 0 ? null : values[valueIndex],
        // style: context.regularStyle(),
        hint: Center(
          child: Text(
            hint ?? "Select an option",
          ),
        ),
        isExpanded: true,
        icon: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.keyboard_arrow_down_rounded),
        ),
        onChanged: (v) {
          if (v == null) return;
          onChanged?.call(values.indexOf(v));
        },
      ),
    );
  }
}
