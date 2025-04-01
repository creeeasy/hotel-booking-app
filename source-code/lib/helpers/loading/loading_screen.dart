import 'dart:async';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/helpers/loading/loading_screen_controller.dart';

class LoadingScreen {
  factory LoadingScreen() => _shared;
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();
  LoadingScreenController? controller;

  void show({
    required BuildContext context,
    required String text,
  }) {
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

  LoadingScreenController showOverlays({
    required BuildContext context,
    required String text,
  }) {
    final textController = StreamController<String>();
    textController.add(text);
    final overlayState = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: 60,
                minWidth: size.width * 0.5,
                minHeight: 60,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: ThemeColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: ThemeColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  StreamBuilder<String>(
                    stream: textController.stream,
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColors.textPrimary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlay);

    return LoadingScreenController(
      close: () {
        textController.close();
        overlay.remove();
        return true;
      },
      update: (newText) {
        textController.add(newText);
        return true;
      },
    );
  }
}