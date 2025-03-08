import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key, this.verticalPadding = 15.0});
  
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Divider(
        color: Colors.grey[400],
        thickness: 1.2,
        height: 20,
      ),
    );
  }
}
