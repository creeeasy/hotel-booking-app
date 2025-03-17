// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

class RangeSliderWidget<T extends num> extends StatefulWidget {
  final RangeValues rangeValues;
  final int? divisions;
  final ValueChanged<RangeValues>? onChanged;
  final String label;
  final RangeValues defaultValues;

  const RangeSliderWidget({
    super.key,
    required this.rangeValues,
    required this.label,
    this.divisions,
    this.onChanged,
    RangeValues? defaultValues,
  }) : defaultValues = defaultValues ?? rangeValues;

  @override
  State<RangeSliderWidget<T>> createState() => _RangeSliderWidgetState<T>();
}

class _RangeSliderWidgetState<T extends num>
    extends State<RangeSliderWidget<T>> {
  late RangeValues currentRangeValues;

  @override
  void initState() {
    super.initState();
    currentRangeValues = widget.defaultValues;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${widget.label}: ${_formattedValue(currentRangeValues.start)} - ${_formattedValue(currentRangeValues.end)}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        RangeSlider(
          values: currentRangeValues,
          min: widget.rangeValues.start,
          max: widget.rangeValues.end,
          divisions: widget.divisions,
          labels: RangeLabels(
            _formattedValue(currentRangeValues.start),
            _formattedValue(currentRangeValues.end),
          ),
          activeColor: VisitorThemeColors.primaryColor,
          inactiveColor: VisitorThemeColors.greyColor,
          onChanged: (RangeValues newValues) {
            setState(() {
              currentRangeValues = newValues;
            });
            widget.onChanged?.call(newValues);
          },
        ),
      ],
    );
  }

  String _formattedValue(double value) {
    return T == int ? value.round().toString() : value.toStringAsFixed(1);
  }
}
