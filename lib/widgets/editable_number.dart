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
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final delta = details.primaryDelta ?? 0;
        num newValue = value + delta / 2;
        if (integer) newValue = newValue.round();
        onChanged(newValue);
      },
      child: Text(
        integer ? value.round().toString() : value.toStringAsFixed(1),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
