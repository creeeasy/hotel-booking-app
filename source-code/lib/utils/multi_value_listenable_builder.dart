import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MultiValueListenableBuilder<T1, T2, T3> extends StatelessWidget {
  final ValueListenable<T1> valueListenable1;
  final ValueListenable<T2> valueListenable2;
  final ValueListenable<T3> valueListenable3;
  final Widget Function(BuildContext, T1, T2, T3) builder;

  const MultiValueListenableBuilder({
    super.key,
    required this.valueListenable1,
    required this.valueListenable2,
    required this.valueListenable3,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T1>(
      valueListenable: valueListenable1,
      builder: (context, value1, _) {
        return ValueListenableBuilder<T2>(
          valueListenable: valueListenable2,
          builder: (context, value2, _) {
            return ValueListenableBuilder<T3>(
              valueListenable: valueListenable3,
              builder: (context, value3, _) {
                return builder(context, value1, value2, value3);
              },
            );
          },
        );
      },
    );
  }
}
