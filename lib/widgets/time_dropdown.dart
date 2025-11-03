import 'package:flutter/material.dart';

class TimeDropdown extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Function(int) onChanged;

  const TimeDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: value,
            underline: const SizedBox(),
            items: List.generate(max + 1, (index) => index)
                .map((i) => DropdownMenuItem(
              value: i,
              child: Text(i.toString().padLeft(2, '0')),
            ))
                .toList(),
            onChanged: (val) => val != null ? onChanged(val) : null,
          ),
        ),
      ],
    );
  }
}