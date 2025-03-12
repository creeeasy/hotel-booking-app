// ignore_for_file: prefer_const_constructors

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionBuilder,
}) {
  final options = optionBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: VisitorThemeColors.whiteColor,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: VisitorThemeColors.primaryColor,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: VisitorThemeColors.textGreyColor,
          ),
        ),
        actions: options.keys.map((optionTitle) {
          final value = options[optionTitle];
          return TextButton(
            onPressed: () {
              Navigator.of(context).pop(value);
            },
            style: TextButton.styleFrom(
              backgroundColor:
                  VisitorThemeColors.deepBlueAccent.withOpacity(0.16),
              foregroundColor: VisitorThemeColors.deepBlueAccent,
              textStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(optionTitle),
          );
        }).toList(),
      );
    },
  );
}
