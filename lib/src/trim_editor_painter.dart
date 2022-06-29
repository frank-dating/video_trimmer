import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as UI;
import 'package:vector_math/vector_math.dart' as vm;

import 'package:flutter/services.dart';

class TrimEditorPainter extends CustomPainter {
  /// To define the start offset
  final Offset startPos;

  /// To define the end offset
  final Offset endPos;

  /// To define the horizontal length of the selected video area
  final double scrubberAnimationDx;

  /// For specifying a size to the holder at the
  /// two ends of the video trimmer area, while it is `idle`.
  /// By default it is set to `0.5`.
  final double circleSize;

  /// For specifying the width of the border around
  /// the trim area. By default it is set to `3`.
  final double borderWidth;

  /// For specifying the width of the video scrubber
  final double scrubberWidth;

  /// For specifying whether to show the scrubber
  final bool showScrubber;

  /// For specifying a color to the border of
  /// the trim area. By default it is set to `Colors.white`.
  final Color borderPaintColor;

  /// For specifying a color to the circle.
  /// By default it is set to `Colors.white`
  final Color circlePaintColor;

  /// For specifying a color to the video
  /// scrubber inside the trim area. By default it is set to
  /// `Colors.white`.
  final Color scrubberPaintColor;

  /// For drawing the trim editor slider
  ///
  /// The required parameters are [startPos], [endPos]
  /// & [scrubberAnimationDx]
  ///
  /// * [startPos] to define the start offset
  ///
  ///
  /// * [endPos] to define the end offset
  ///
  ///
  /// * [scrubberAnimationDx] to define the horizontal length of the
  /// selected video area
  ///
  ///
  /// The optional parameters are:
  ///
  /// * [circleSize] for specifying a size to the holder at the
  /// two ends of the video trimmer area, while it is `idle`.
  /// By default it is set to `0.5`.
  ///
  ///
  /// * [borderWidth] for specifying the width of the border around
  /// the trim area. By default it is set to `3`.
  ///
  ///
  /// * [scrubberWidth] for specifying the width of the video scrubber
  ///
  ///
  /// * [showScrubber] for specifying whether to show the scrubber
  ///
  ///
  /// * [borderPaintColor] for specifying a color to the border of
  /// the trim area. By default it is set to `Colors.white`.
  ///
  ///
  /// * [circlePaintColor] for specifying a color to the circle.
  /// By default it is set to `Colors.white`.
  ///
  ///
  /// * [scrubberPaintColor] for specifying a color to the video
  /// scrubber inside the trim area. By default it is set to
  /// `Colors.white`.
  ///
  TrimEditorPainter({
    required this.startPos,
    required this.endPos,
    required this.scrubberAnimationDx,
    this.circleSize = 0.5,
    this.borderWidth = 3,
    this.scrubberWidth = 1,
    this.showScrubber = true,
    this.borderPaintColor = Colors.white,
    this.circlePaintColor = Colors.white,
    this.scrubberPaintColor = Colors.white,
  });

  late Size size;

  @override
  void paint(Canvas canvas, Size size) {
    var borderPaint = Paint()
      ..color = borderPaintColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var circlePaint = Paint()
      ..color = circlePaintColor
      ..strokeWidth = 1
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    var scrubberPaint = Paint()
      ..color = scrubberPaintColor
      ..strokeWidth = scrubberWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromPoints(startPos, endPos);

    if (showScrubber) {
      if (scrubberAnimationDx.toInt() > startPos.dx.toInt()) {
        canvas.drawLine(
          Offset(scrubberAnimationDx, 0),
          Offset(scrubberAnimationDx, 0) + Offset(0, endPos.dy),
          scrubberPaint,
        );
      }
    }

    canvas.drawRect(rect, borderPaint);
    canvas.drawCircle(
        startPos + Offset(0, endPos.dy / 2), circleSize, circlePaint);
    canvas.drawCircle(
        endPos + Offset(0, -endPos.dy / 2), circleSize, circlePaint);

    loadUiImage('lib/assets/crop-arrow.png').then((UI.Image codec) {
      canvas.drawImage(codec, size.center(Offset.zero), circlePaint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  Path getPath1() {
    return Path()
      ..addPath(getTopLeftPath2(), Offset(0, 0))
      ..addPath(getTopPath(), Offset(0, 0))
      ..addPath(getTopRightPath1(), Offset(0, 0));
  }

  Path getPath2() {
    return Path()
      ..addPath(getTopRightPath2(), Offset(0, 0))
      ..addPath(getRightPath(), Offset(0, 0))
      ..addPath(getBottomRightPath1(), Offset(0, 0));
  }

  Path getPath3() {
    return Path()
      ..addPath(getBottomRightPath2(), Offset(0, 0))
      ..addPath(getBottomPath(), Offset(0, 0))
      ..addPath(getBottomLeftPath1(), Offset(0, 0));
  }

  Path getPath4() {
    return Path()
      ..addPath(getBottomLeftPath2(), Offset(0, 0))
      ..addPath(getLeftPath(), Offset(0, 0))
      ..addPath(getTopLeftPath1(), Offset(0, 0));
  }

  Path getTopPath() {
    return Path()
      ..moveTo(0 + 0, 0)
      ..lineTo(size.width - 0, 0);
  }

  Path getRightPath() {
    return Path()
      ..moveTo(size.width, 0 + 0)
      ..lineTo(size.width, size.height - 0);
  }

  Path getBottomPath() {
    return Path()
      ..moveTo(size.width - 0, size.height)
      ..lineTo(0 + 0, size.height);
  }

  Path getLeftPath() {
    return Path()
      ..moveTo(0, size.height - 0)
      ..lineTo(0, 0 + 0);
  }

  Path getTopRightPath1() {
    return Path()
      ..addArc(
        Rect.fromLTWH(size.width - (0 * 2), 0, 0 * 2, 0 * 2),
        vm.radians(-45),
        vm.radians(-45),
      );
  }

  Path getTopRightPath2() {
    return Path()
      ..addArc(
        Rect.fromLTWH(size.width - (0 * 2), 0, 0 * 2, 0 * 2),
        vm.radians(0),
        vm.radians(-45),
      );
  }

  Path getBottomRightPath1() {
    return Path()
      ..addArc(
        Rect.fromLTWH(size.width - (0 * 2), size.height - (0 * 2), 0 * 2, 0 * 2),
        vm.radians(45),
        vm.radians(-45),
      );
  }

  Path getBottomRightPath2() {
    return Path()
      ..addArc(
        Rect.fromLTWH(size.width - (0 * 2), size.height - (0 * 2), 0 * 2, 0 * 2),
        vm.radians(90),
        vm.radians(-45),
      );
  }

  Path getBottomLeftPath1() {
    return Path()
      ..addArc(
        Rect.fromLTWH(0, size.height - (0 * 2), 0 * 2, 0 * 2),
        vm.radians(135),
        vm.radians(-45),
      );
  }

  Path getBottomLeftPath2() {
    return Path()
      ..addArc(
        Rect.fromLTWH(0, size.height - (0 * 2), 0 * 2, 0 * 2),
        vm.radians(180),
        vm.radians(-45),
      );
  }

  Path getTopLeftPath1() {
    return Path()
      ..addArc(
        Rect.fromLTWH(0, 0, 0 * 2, 0 * 2),
        vm.radians(225),
        vm.radians(-45),
      );
  }

  Path getTopLeftPath2() {
    return Path()
      ..addArc(
        Rect.fromLTWH(0, 0, 0 * 2, 0 * 2),
        vm.radians(270),
        vm.radians(-45),
      );
  }


  Future<UI.Image> loadUiImage(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<UI.Image> completer = Completer();
    UI.decodeImageFromList(Uint8List.view(data.buffer), (UI.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}
