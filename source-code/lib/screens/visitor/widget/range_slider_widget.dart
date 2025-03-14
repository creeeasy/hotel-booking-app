import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:flutter/material.dart';

class RangeSliderWidget<T extends num> extends StatefulWidget {
  final T minValue;
  final T maxValue;
  final int? divisions;
  final ValueChanged<RangeValues>? onChanged;
  final String label;

  const RangeSliderWidget({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.label,
    this.divisions,
    this.onChanged,
  });

  @override
  State<RangeSliderWidget<T>> createState() => _RangeSliderWidgetState<T>();
}

class _RangeSliderWidgetState<T extends num> extends State<RangeSliderWidget<T>> {
  late RangeValues currentRangeValues;

  @override
  void initState() {
    super.initState();
    currentRangeValues = RangeValues(widget.minValue.toDouble(), widget.maxValue.toDouble());
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
          min: widget.minValue.toDouble(),
          max: widget.maxValue.toDouble(),
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