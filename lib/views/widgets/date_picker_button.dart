import 'package:flutter/material.dart';

import '../../config/utils/ui_utility.dart';
import '../../config/utils/utility.dart';

class DatePickerButton extends StatefulWidget {
  const DatePickerButton({
    super.key,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.value,
    this.onValueChanged,
  });

  final bool enabled;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime value)? onValueChanged;

  @override
  State<DatePickerButton> createState() => _DatePickerButtonState();
}

class _DatePickerButtonState extends State<DatePickerButton> {
  DateTime? value;
  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.enabled
          ? () async {
              var v = await UiUtility.showDatePickerDialog(
                context: context,
                firstDate: widget.firstDate ?? DateTime(1900),
                lastDate: widget.lastDate ?? DateTime(2100),
                initialDate: value,
              );
              if (v == null) return;
              setState(() {
                value = v;
              });
              widget.onValueChanged?.call(v);
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Utility.encodeDate(value),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.calendar_month_rounded,
            // color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
