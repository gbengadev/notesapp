import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterdemoapp/utility-methods/loading_screens/loading_screen_controller.dart';

class LoadingScreen {
  factory LoadingScreen() => _shared;
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();

  LoadingScreenController? controller;

  void hide() {
    controller?.close();
    controller = null;
  }

  void show({
    required BuildContext context,
    required String text,
  }) {
    //return if the controller's text can be updated
    if (controller?.update(text) ?? false) {
      return;
    }
    //Create a new overlay and assign to controller
    else {
      controller = showOverlay(
        context: context,
        text: text,
      );
    }
  }

  LoadingScreenController showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final overlayText = StreamController<String>();
    overlayText.add(text);

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
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const CircularProgressIndicator(),
                    const SizedBox(
                      height: 20,
                    ),
                    StreamBuilder(
                      stream: overlayText.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data as String,
                            textAlign: TextAlign.center,
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });

    //Add overlay to the entire overlay state managed by flutter
    state.insert(overlay);
    return LoadingScreenController(
      close: () {
        overlayText.close();
        overlay.remove();
        return true;
      },
      update: (text) {
        overlayText.add(text);
        return true;
      },
    );
  }
}
