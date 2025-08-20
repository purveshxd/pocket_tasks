import 'package:flutter/material.dart';
import 'package:pocket_tasks/providers/task_provider.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final TaskFilter filter;
  final void Function()? onSelected;
  final bool isSelected;
  const CustomChip({
    super.key,
    required this.label,
    required this.filter,
    this.onSelected,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      shape: StadiumBorder(),
      label: Text(
        label[0].toUpperCase() + label.substring(1),
        style: TextStyle(color: Colors.white),
      ),
      side: BorderSide.none,
      backgroundColor: !isSelected
          ? Color.fromARGB(255, 59, 20, 95)
          : Color.fromARGB(255, 76, 33, 122),

      onPressed: onSelected,
    );
  }
}
