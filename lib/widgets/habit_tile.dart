import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onChanged,
    required this.index,
    required this.onDismiss,
    required this.onEdit,
  });

  final String title;
  final bool isCompleted;
  final void Function(bool?) onChanged;
  final int index;
  final VoidCallback? onDismiss;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: themeData.primaryColor,
              icon: Icons.settings,
              borderRadius: BorderRadius.circular(10),
            ),
            SlidableAction(
              onPressed: (_) => onDismiss?.call(),
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(10),
            )
          ],
        ),
        child: GestureDetector(
          onLongPress: onEdit,
          onTap: () => onChanged(!isCompleted),
          child: Container(
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xff74B72E)
                  : themeData.colorScheme.tertiary,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: ListTile(
              title: Text(
                title,
                style: TextStyle(
                  color: isCompleted
                      ? Colors.grey.shade800
                      : themeData.colorScheme.inversePrimary,
                ),
              ),
              leading: Checkbox(
                fillColor: MaterialStateProperty.all(
                  themeData.colorScheme.background,
                ),
                checkColor: themeData.colorScheme.inversePrimary,
                value: isCompleted,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
