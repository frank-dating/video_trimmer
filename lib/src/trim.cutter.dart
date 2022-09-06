import 'package:flutter/material.dart';

class TrimCutter extends StatefulWidget {
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
  const TrimCutter({
    Key? key,
    required this.startPos,
    required this.endPos,
    this.scrubberPaintColor = Colors.white,
    required this.width,
    required this.borderPaintColor,
    required this.onClingLeft,
    required this.onClingRight,
    required this.isArrowsVisible,
  }) : super(key: key);

  /// To define the start offset
  final Offset startPos;

  /// To define the end offset
  final Offset endPos;

  final double width;

  /// For specifying a color to the border of
  /// the trim area. By default it is set to `Colors.white`.
  final Color borderPaintColor;

  /// For specifying a color to the video
  /// scrubber inside the trim area. By default it is set to
  /// `Colors.white`.
  final Color scrubberPaintColor;

  final VoidCallback? onClingLeft;
  final VoidCallback? onClingRight;

  final bool isArrowsVisible;

  @override
  State<TrimCutter> createState() => _TrimCutterState();
}

class _TrimCutterState extends State<TrimCutter> {
  bool isLeftClinged = true;
  bool isRightClinged = true;

  double lastLeftPos = 0.0;
  double lastRightPos = 0.0;

  bool isFirstBuild = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isFirstBuild = false;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var rightPos = (widget.width - widget.endPos.dx).clamp(.0, double.infinity);
    var leftPos = widget.startPos.dx.clamp(.0, double.infinity);

    setClingListeners(leftPos, rightPos);

    lastLeftPos = leftPos;
    lastRightPos = rightPos;

    final isFullWidth = isFirstBuild || leftPos == 0 && rightPos == 0;
    return Container(
      height: double.infinity,
      margin: EdgeInsets.only(left: leftPos, right: rightPos),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: isFullWidth
                      ? const Color(0xFF252525)
                      : widget.borderPaintColor,
                  width: 8,
                ),
                vertical: BorderSide(
                  color: isFullWidth
                      ? const Color(0xFF252525)
                      : widget.borderPaintColor,
                  width: 18,
                ),
              ),
            ),
          ),
          if(widget.isArrowsVisible) Positioned(
            right: 5,
            child: RotatedBox(
              quarterTurns: 2,
              child: Image.asset(
                'assets/crop-arrow.png',
                package: 'video_trimmer',
                width: 6,
                height: 12,
                color: isFullWidth ? Colors.white : const Color(0xFF252525),
              ),
            ),
          ),
          if(widget.isArrowsVisible) Positioned(
            left: 5,
            child: Image.asset(
              'assets/crop-arrow.png',
              package: 'video_trimmer',
              width: 6,
              height: 12,
              color: isFullWidth ? Colors.white : const Color(0xFF252525),
            ),
          ),
        ],
      ),
    );
  }

  void setClingListeners(double leftPos, double rightPos) {
    if (isFirstBuild) return;

    if (leftPos == 0.0 && leftPos != lastLeftPos) {
      widget.onClingLeft?.call();
    }

    if (rightPos == 0.0 &&
        rightPos != lastRightPos &&
        lastRightPos != widget.width) {
      widget.onClingRight?.call();
    }
  }
}
