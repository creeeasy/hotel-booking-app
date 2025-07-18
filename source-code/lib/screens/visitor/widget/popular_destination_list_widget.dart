import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/enum/hotel_entity.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/screens/visitor/widget/popular_destination_row_widget.dart';
import 'package:flutter/material.dart';

class PopularDestinationListWidget extends StatefulWidget {
  final Function(int)? callBack;
  final AnimationController? animationController;

  const PopularDestinationListWidget(
      {Key? key, this.callBack, this.animationController})
      : super(key: key);

  @override
  _PopularDestinationListWidgetState createState() =>
      _PopularDestinationListWidgetState();
}

class _PopularDestinationListWidgetState
    extends State<PopularDestinationListWidget> with TickerProviderStateMixin {
  final popularList = HotelEntity.popularList;
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    super.initState();
  }

  Future<bool> getData() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animationController!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 40 * (1.0 - widget.animationController!.value), 0.0),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: FutureBuilder(
                future: getData(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return NoDataWidget(
                      message: L10n.of(context).noPopularDestinationsAvailable,
                    );
                  }
                  if (snapshot.hasError) {
                    return ErrorWidgetWithRetry(
                      errorMessage: '${L10n.of(context).error}: ${snapshot.error}',
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                          top: 0, bottom: 0, right: 24, left: 8),
                      itemCount: popularList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        var count =
                            popularList.length > 10 ? 10 : popularList.length;
                        var animation = Tween(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                                parent: animationController!,
                                curve: Interval((1 / count) * index, 1.0,
                                    curve: Curves.fastOutSlowIn)));
                        animationController!.forward();
                        return PopularDestinationRowWidget(
                          popularList: popularList[index],
                          animation: animation,
                          animationController: animationController,
                          callback: () {
                            widget.callBack!(index);
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}