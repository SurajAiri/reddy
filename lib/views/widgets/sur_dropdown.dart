import 'package:flutter/material.dart';

class SurDropdown extends StatefulWidget {
  const SurDropdown({
    super.key,
    this.values = const [],
    this.onChanged,
    this.valueIndex = -1,
    this.hint,
  });
  final Function(int index)? onChanged;
  final List<String> values;
  final int valueIndex;
  final String? hint;

  @override
  State<SurDropdown> createState() => _SurDropdownState();
}

class _SurDropdownState extends State<SurDropdown> {
  List<DropdownMenuItem<String>> items = [];
  String? value = "";
  @override
  void initState() {
    super.initState();
    value = widget.valueIndex < 0 ? null : widget.values[widget.valueIndex];
    items = widget.values.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Center(
          child: Text(
            value,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        dropdownColor: Colors.green[50],
        underline: null,
        items: items,
        value: value,
        hint: Center(
          child: Text(
            widget.hint ?? "Select an option",
          ),
        ),
        isExpanded: true,
        icon: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.keyboard_arrow_down_rounded),
        ),
        onChanged: (v) {
          setState(() {
            if (v == null) return;
            value = v;
            widget.onChanged?.call(widget.values.indexOf(v));
          });
        },
      ),
    );
  }
}
