import 'package:flutter/material.dart';

class EditableNumber extends StatelessWidget {
  final num value;
  final bool integer;
  final ValueChanged<num> onChanged;

  const EditableNumber({
    super.key,
    required this.value,
    required this.onChanged,
    this.integer = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: integer ? 40 : 60,
      child: TextFormField(
        initialValue:
            integer ? value.round().toString() : value.toStringAsFixed(1),
        keyboardType: TextInputType.numberWithOptions(decimal: !integer),
        textAlign: TextAlign.center,
        decoration: const InputDecoration(isDense: true, border: InputBorder.none),
        onChanged: (val) {
          final parsed = num.tryParse(val);
          if (parsed != null) {
            onChanged(parsed);
          }
        },
      ),
    );
  }
}
