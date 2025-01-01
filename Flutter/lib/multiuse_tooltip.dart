import 'package:flutter/material.dart';

class MultiuseTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  const MultiuseTooltip(
      {super.key, required this.child, required this.message});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      waitDuration: const Duration(milliseconds: 100),
      padding: const EdgeInsets.all(12),
      textStyle: const TextStyle(fontSize: 12),
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).dialogBackgroundColor),
      message: (message.isEmpty ? "No data provided" : message).toUpperCase(),
      child: child,
    );
  }
}
