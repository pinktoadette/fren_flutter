import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/widgets/animations/loader.dart';

class FullScreenLoading {
  final BuildContext context;
  OverlayEntry? _overlayEntry;

  FullScreenLoading(this.context);

  // Show full-screen loading
  void show(String message) {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Stack(
          children: [
            ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Frankloader(
                    height: 100,
                  ),
                  DefaultTextStyle(
                    style: const TextStyle(
                        color: APP_ACCENT_COLOR,
                        fontWeight: FontWeight.normal,
                        fontSize: 16),
                    child: Text(message),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Hide full-screen loading
  void hide() {
    debugPrint(context.toString());
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
