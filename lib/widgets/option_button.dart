import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isRevealed;
  final VoidCallback? onTap;

  const OptionButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isRevealed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData? trailingIcon;

    if (isRevealed) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green.shade800;
        trailingIcon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red.shade800;
        trailingIcon = Icons.cancel;
      } else {
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey.shade700;
        trailingIcon = null;
      }
    } else {
      if (isSelected) {
        backgroundColor = Theme.of(context).primaryColor.withOpacity(0.2);
        textColor = Theme.of(context).primaryColor;
      } else {
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.black87;
      }
      trailingIcon = null;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? textColor : Colors.grey.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: textColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}