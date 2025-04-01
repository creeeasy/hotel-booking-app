import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';

class RangeSliderWidget<T extends num> extends StatefulWidget {
  final RangeValues rangeValues;
  final int? divisions;
  final ValueChanged<RangeValues>? onChanged;
  final String label;
  final RangeValues defaultValues;
  final Color? activeColor;

  const RangeSliderWidget({
    super.key,
    required this.rangeValues,
    required this.label,
    this.divisions,
    this.onChanged,
    this.activeColor,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ThemeColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: ThemeColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                "${_formattedValue(currentRangeValues.start)} - ${_formattedValue(currentRangeValues.end)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              RangeSlider(
                values: currentRangeValues,
                min: widget.rangeValues.start,
                max: widget.rangeValues.end,
                divisions: widget.divisions,
                labels: RangeLabels(
                  _formattedValue(currentRangeValues.start),
                  _formattedValue(currentRangeValues.end),
                ),
                activeColor: widget.activeColor ?? ThemeColors.primary,
                inactiveColor: ThemeColors.grey300,
                onChanged: (RangeValues newValues) {
                  setState(() {
                    currentRangeValues = newValues;
                  });
                  widget.onChanged?.call(newValues);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formattedValue(double value) {
    return T == int ? value.round().toString() : value.toStringAsFixed(1);
  }
}
