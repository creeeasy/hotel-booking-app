import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fatiel/loading/loading_screen_controller.dart';

class LoadingScreen {
  factory LoadingScreen() => _shared;
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();
  LoadingScreenController? controller;
  void show({
    required BuildContext context,
    required String text,
  })
  // async

  {
    if (controller?.update(text) ?? false) {
      return;
    } else {
      controller = showOverlays(
        context: context,
        text: text,
      );
    }
  }

  void hide() {
    controller?.close();
    controller = null;
  }

  LoadingScreenController showOverlays(
      {required BuildContext context, required String text}) {
    final text0 = StreamController<String>();
    text0.add(text);
    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final overlay = OverlayEntry(builder: (context) {
      return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
              child: Container(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.8,
              maxHeight: 50,
              minWidth: size.width * 0.5,
              minHeight: 50,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload),
                    const SizedBox(
                      width: 10,
                    ),
                    StreamBuilder(
                        stream: text0.stream,
                        builder: ((context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return Container();
                          }
                        }))
                  ],
                )),
          )));
    });

    state.insert(overlay);

    return LoadingScreenController(close: () {
      text0.close();
      overlay.remove();
      return true;
    }, update: (text) {
      text0.add(text);
      return true;
    });
  }
}