import 'package:flutter/material.dart';

/// A reusable form label widget with optional required asterisk indicator.
/// Used across registration panels for consistent styling.
class FormLabel extends StatelessWidget {
  const FormLabel({
    super.key,
    required this.text,
    this.showAsterisk = true,
    this.leftPadding = 20.0,
  });

  final String text;
  final bool showAsterisk;
  final double leftPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showAsterisk)
            const Text(
              " *",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}
