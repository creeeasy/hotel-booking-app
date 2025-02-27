import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  const SearchInput({
    Key? key,
    this.onChange,
    this.hintText,
    this.initialValue,
    this.inputTextKey,
  }) : super(key: key);

  final ValueChanged<String>? onChange;
  final String? hintText;
  final String? initialValue;
  final Key? inputTextKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: VisitorThemeColors.lightGrayColor,
        borderRadius: BorderRadius.all(Radius.circular(38)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 48,
          child: Center(
            child: TextFormField(
              key: inputTextKey,
              initialValue: initialValue ?? '',
              maxLines: 1,
              onChanged: (String txt) {
                if (onChange != null) onChange!(txt);
              },
              style: const TextStyle(
                fontSize: 16,
                color: VisitorThemeColors.blackColor,
              ),
              cursorColor: VisitorThemeColors.primaryColor,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText ?? '',
                hintStyle: const TextStyle(
                  color: VisitorThemeColors.secondaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
