import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/src/thumbnail_viewer.dart';
import 'package:video_trimmer/src/trimmer.dart';

import 'trim.cutter.dart';

class TrimEditor extends StatefulWidget {
  /// The Trimmer instance controlling the data.
  final Trimmer trimmer;

  /// For defining the total trimmer area width
  final double viewerWidth;

  /// For defining the total trimmer area height
  final double viewerHeight;

  /// For defining the image fit type of each thumbnail image.
  ///
  /// By default it is set to `BoxFit.fitHeight`.
  final BoxFit fit;

  /// For defining the maximum length of the output video.
  final Duration minVideoLength;

  /// For specifying a size to the holder at the
  /// two ends of the video trimmer area, while it is `idle`.
  ///
  /// By default it is set to `5.0`.
  final double circleSize;

  /// For specifying the width of the border around
  /// the trim area. By default it is set to `3`.
  final double borderWidth;

  /// For specifying the width of the video scrubber
  final double scrubberWidth;

  /// For specifying a size to the holder at
  /// the two ends of the video trimmer area, while it is being
  /// `dragged`.
  ///
  /// By default it is set to `8.0`.
  final double circleSizeOnDrag;

  /// For specifying a color to the circle.
  ///
  /// By default it is set to `Colors.white`.
  final Color circlePaintColor;

  /// For specifying a color to the border of
  /// the trim area.
  ///
  /// By default it is set to `Colors.white`.
  final Color borderPaintColor;

  /// For specifying a color to the video
  /// scrubber inside the trim area.
  ///
  /// By default it is set to `Colors.white`.
  final Color scrubberPaintColor;

  /// For specifying the quality of each
  /// generated image thumbnail, to be displayed in the trimmer
  /// area.
  final int thumbnailQuality;

  /// For showing the start and the end point of the
  /// video on top of the trimmer area.
  ///
  /// By default it is set to `true`.
  final bool showDuration;

  /// For providing a `TextStyle` to the
  /// duration text.
  ///
  /// By default it is set to `TextStyle(color: Colors.white)`
  final TextStyle durationTextStyle;

  /// Callback to the video start position
  ///
  /// Returns the selected video start position in `milliseconds`.
  final Function(double startValue)? onChangeStart;

  /// Callback to the video end position.
  ///
  /// Returns the selected video end position in `milliseconds`.
  final Function(double endValue)? onChangeEnd;

  /// Determines the touch size of the side handles, left and right. The rest, in
  /// the center, will move the whole frame if [maxVideoLength] is inferior to the
  /// total duration of the video.
  final int sideTapSize;

  final Widget Function(Widget) previewWrapper;

  final VoidCallback? onClingLeft;
  final VoidCallback? onClingRight;

  final int clingOffset;

  /// Widget for displaying the video trimmer.
  ///
  /// This has frame wise preview of the video with a
  /// slider for selecting the part of the video to be
  /// trimmed.
  ///
  /// The required parameters are [viewerWidth] & [viewerHeight]
  ///
  /// * [viewerWidth] to define the total trimmer area width.
  ///
  ///
  /// * [viewerHeight] to define the total trimmer area height.
  ///
  ///
  /// The optional parameters are:
  ///
  /// * [fit] for specifying the image fit type of each thumbnail image.
  /// By default it is set to `BoxFit.fitHeight`.
  ///
  ///
  /// * [circleSize] for specifying a size to the holder at the
  /// two ends of the video trimmer area, while it is `idle`.
  /// By default it is set to `5.0`.
  ///
  ///
  /// * [circleSizeOnDrag] for specifying a size to the holder at
  /// the two ends of the video trimmer area, while it is being
  /// `dragged`. By default it is set to `8.0`.
  ///
  ///
  /// * [circlePaintColor] for specifying a color to the circle.
  /// By default it is set to `Colors.white`.
  ///
  ///
  /// * [borderPaintColor] for specifying a color to the border of
  /// the trim area. By default it is set to `Colors.white`.
  ///
  ///
  /// * [scrubberPaintColor] for specifying a color to the video
  /// scrubber inside the trim area. By default it is set to
  /// `Colors.white`.
  ///
  ///
  /// * [thumbnailQuality] for specifying the quality of each
  /// generated image thumbnail, to be displayed in the trimmer
  /// area.
  ///
  ///
  /// * [showDuration] for showing the start and the end point of the
  /// video on top of the trimmer area. By default it is set to `true`.
  ///
  ///
  /// * [durationTextStyle] is for providing a `TextStyle` to the
  /// duration text. By default it is set to
  /// `TextStyle(color: Colors.white)`
  ///
  ///
  /// * [onChangeStart] is a callback to the video start position.
  ///
  ///
  /// * [onChangeEnd] is a callback to the video end position.
  ///
  const TrimEditor({
    Key? key,
    required this.trimmer,
    this.viewerWidth = 50.0 * 8,
    this.viewerHeight = 50,
    this.fit = BoxFit.fitHeight,
    required this.minVideoLength,
    this.circleSize = 5.0,
    this.borderWidth = 3,
    this.scrubberWidth = 1,
    this.circleSizeOnDrag = 8.0,
    this.circlePaintColor = Colors.white,
    this.borderPaintColor = Colors.white,
    this.scrubberPaintColor = Colors.white,
    this.thumbnailQuality = 75,
    this.showDuration = true,
    this.sideTapSize = 24,
    this.durationTextStyle = const TextStyle(color: Colors.white),
    this.onChangeStart,
    this.onChangeEnd,
    required this.previewWrapper,
    this.onClingLeft,
    this.onClingRight,
    this.clingOffset = 1,
  }) : super(key: key);

  @override
  _TrimEditorState createState() => _TrimEditorState();
}

class _TrimEditorState extends State<TrimEditor> with TickerProviderStateMixin {
  File? get _videoFile => widget.trimmer.currentVideoFile;

  double _videoStartPos = 0.0;
  double _videoEndPos = 0.0;

  Offset _startPos = const Offset(0, 0);
  Offset _endPos = const Offset(0, 0);

  double _startFraction = 0.0;
  double _endFraction = 1.0;

  int _videoDuration = 0;
  int _currentPosition = 0;

  double _thumbnailViewerW = 0.0;
  double _thumbnailViewerH = 0.0;

  int _numberOfThumbnails = 0;

  double _minCropWidth = 0;

  double? fraction;
  double? maxLengthPixels;
  Duration maxVideoLength = const Duration(seconds: 0);

  ThumbnailViewer? thumbnailWidget;

  late Tween<double> _linearTween;

  bool isVideoResetInProgress = false;

  /// Quick access to VideoPlayerController, only not null after [TrimmerEvent.initialized]
  /// has been emitted.
  VideoPlayerController get videoPlayerController =>
      widget.trimmer.videoPlayerController!;

  /// Keep track of the drag type, e.g. whether the user drags the left, center or
  /// right part of the frame. Set this in [_onDragStart] when the dragging starts.
  EditorDragType _dragType = EditorDragType.left;

  /// Whether the dragging is allowed. Dragging is ignore if the user's gesture is outside
  /// of the frame, to make the UI more realistic.
  bool _allowDrag = true;

  bool _isVideoTooSmall = false;

  @override
  void initState() {
    super.initState();

    widget.trimmer.eventStream.listen((event) {
      if (event == TrimmerEvent.initialized) {
        if (videoPlayerController.isDisposedOrNotInitialized) return;

        //The video has been initialized, now we can load stuff

        maxVideoLength = videoPlayerController.value.duration;

        _minCropWidth = (widget.viewerWidth / maxVideoLength.inMilliseconds) *
            widget.minVideoLength.inMilliseconds;

        _isVideoTooSmall = widget.minVideoLength.inMilliseconds >
            videoPlayerController.value.duration.inMilliseconds;

        _initializeVideoController();

        videoPlayerController.seekTo(const Duration(milliseconds: 0));
        if (!mounted) return;
        setState(() {
          Duration totalDuration = videoPlayerController.value.duration;

          if (maxVideoLength > const Duration(milliseconds: 0) &&
              maxVideoLength < totalDuration) {
            if (maxVideoLength < totalDuration) {
              fraction =
                  maxVideoLength.inMilliseconds / totalDuration.inMilliseconds;

              maxLengthPixels = _thumbnailViewerW * fraction!;
            }
          } else {
            maxLengthPixels = _thumbnailViewerW;
          }

          _videoEndPos = fraction != null
              ? _videoDuration.toDouble() * fraction!
              : _videoDuration.toDouble();

          widget.onChangeEnd?.call(_videoEndPos);

          _endPos = Offset(
            maxLengthPixels != null ? maxLengthPixels! : _thumbnailViewerW,
            _thumbnailViewerH,
          );

          // Defining the tween points
          _linearTween = Tween(begin: _startPos.dx, end: _endPos.dx);
        });
      }
    });

    _thumbnailViewerH = widget.viewerHeight;

    _numberOfThumbnails = widget.viewerWidth ~/ _thumbnailViewerH;

    _thumbnailViewerW = _numberOfThumbnails * _thumbnailViewerH;
  }

  Future<void> _initializeVideoController() async {
    if (_videoFile != null) {
      videoPlayerController.addListener(() {
        if (videoPlayerController.isDisposedOrNotInitialized) return;

        if (videoPlayerController.value.position ==
            videoPlayerController.value.duration) {
          resetVideo();
        }

        final bool isPlaying = videoPlayerController.value.isPlaying;

        if (isPlaying) {
          if (!mounted) return;
          setState(() {
            _currentPosition =
                videoPlayerController.value.position.inMilliseconds;

            if (_currentPosition > _videoEndPos.toInt()) {
              resetVideo();
            }
          });
        }
      });

      _videoDuration = videoPlayerController.value.duration.inMilliseconds;

      final ThumbnailViewer _thumbnailWidget = ThumbnailViewer(
        videoFile: _videoFile!,
        videoDuration: _videoDuration,
        fit: widget.fit,
        thumbnailHeight: _thumbnailViewerH,
        numberOfThumbnails: _numberOfThumbnails,
        quality: widget.thumbnailQuality,
        width: _thumbnailViewerW,
        controller: videoPlayerController,
        previewWrapper: widget.previewWrapper,
      );
      thumbnailWidget = _thumbnailWidget;
    }
  }

  /// Called when the user starts dragging the frame, on either side on the whole frame.
  /// Determine which [EditorDragType] is used.
  void _onDragStart(DragStartDetails details) {
    debugPrint("_onDragStart");
    debugPrint(details.localPosition.toString());
    debugPrint((_startPos.dx - details.localPosition.dx).abs().toString());
    debugPrint((_endPos.dx - details.localPosition.dx).abs().toString());

    final startDifference = _startPos.dx - details.localPosition.dx;
    final endDifference = _endPos.dx - details.localPosition.dx;

    //First we determine whether the dragging motion should be allowed. The allowed
    //zone is widget.sideTapSize (left) + frame (center) + widget.sideTapSize (right)
    if (startDifference <= widget.sideTapSize &&
        endDifference >= -widget.sideTapSize) {
      _allowDrag = true;
    } else {
      debugPrint("Dragging is outside of frame, ignoring gesture...");
      //_allowDrag = false;
      return;
    }

    //Now we determine which part is dragged
    if (details.localPosition.dx <= _startPos.dx + widget.sideTapSize) {
      _dragType = EditorDragType.left;
    } else if (details.localPosition.dx <= _endPos.dx - widget.sideTapSize) {
      _dragType = EditorDragType.center;
    } else {
      _dragType = EditorDragType.right;
    }
  }

  /// Called during dragging, only executed if [_allowDrag] was set to true in
  /// [_onDragStart].
  /// Makes sure the limits are respected.
  void _onDragUpdate(DragUpdateDetails details) {
    if (widget.viewerWidth - _minCropWidth <= 0) return;
    if (!_allowDrag) return;

    if (_dragType == EditorDragType.left) {
      if ((_startPos.dx + details.delta.dx >= 0) &&
          (_startPos.dx + details.delta.dx <= _endPos.dx) &&
          (_endPos.dx - _startPos.dx - details.delta.dx >= _minCropWidth) &&
          !(_endPos.dx - _startPos.dx - details.delta.dx > maxLengthPixels!)) {
        _updateStartPos(details);
        _onStartDragged();
      }
    } else if (_dragType == EditorDragType.center) {
      if ((_startPos.dx + details.delta.dx >= 0) &&
          (_endPos.dx + details.delta.dx <= _thumbnailViewerW)) {
        _updateBothPos(details);
        _onStartDragged();
        _onEndDragged();
      }
    } else {
      if ((_endPos.dx + details.delta.dx <= _thumbnailViewerW) &&
          (_endPos.dx + details.delta.dx >= _startPos.dx) &&
          (_endPos.dx - _startPos.dx + details.delta.dx >= _minCropWidth) &&
          !(_endPos.dx - _startPos.dx + details.delta.dx > maxLengthPixels!)) {
        _updateEndPos(details);
        _onEndDragged();
      }
    }

    if (!mounted) return;
    setState(() {});
  }

  void _updateBothPos(DragUpdateDetails details) {
    if (_startPos.dx + details.delta.dx < widget.clingOffset) {
      final gap = _startPos - Offset.zero;
      _startPos = Offset.zero;
      _endPos -= gap;
    } else {
      if (_thumbnailViewerW - (_endPos.dx + details.delta.dx) <
          widget.clingOffset) {
        final endPos = Offset(
          maxLengthPixels != null ? maxLengthPixels! : _thumbnailViewerW,
          _thumbnailViewerH,
        );

        final gap = endPos - _endPos;
        _endPos = endPos;
        _startPos += gap;
      } else {
        _endPos += details.delta;
        _startPos += details.delta;
      }
    }
  }

  void _updateStartPos(DragUpdateDetails details) {
    if (_startPos.dx + details.delta.dx < widget.clingOffset) {
      _startPos = Offset.zero;
    } else {
      _startPos += details.delta;
    }
  }

  void _updateEndPos(DragUpdateDetails details) {
    if (_thumbnailViewerW - (_endPos.dx + details.delta.dx) <
        widget.clingOffset) {
      _endPos = Offset(
        maxLengthPixels != null ? maxLengthPixels! : _thumbnailViewerW,
        _thumbnailViewerH,
      );
    } else {
      _endPos += details.delta;
    }
  }

  void _onStartDragged() {
    if (videoPlayerController.isDisposedOrNotInitialized) return;

    videoPlayerController.pause();

    _startFraction = (_startPos.dx / _thumbnailViewerW);
    _videoStartPos = _videoDuration * _startFraction;
    widget.onChangeStart?.call(_videoStartPos);
    videoPlayerController
        .seekTo(Duration(milliseconds: _videoStartPos.toInt()));

    _linearTween.begin = _startPos.dx;
  }

  void _onEndDragged() {
    if (videoPlayerController.isDisposedOrNotInitialized) return;

    _endFraction = _endPos.dx / _thumbnailViewerW;
    _videoEndPos = _videoDuration * _endFraction;
    widget.onChangeEnd?.call(_videoEndPos);
    videoPlayerController
        .seekTo(Duration(milliseconds: _videoStartPos.toInt()));

    _linearTween.end = _endPos.dx;
  }

  /// Drag gesture ended, update UI accordingly.
  void _onDragEnd(DragEndDetails details) {
    if (videoPlayerController.isDisposedOrNotInitialized) return;

    if (!mounted) return;
    setState(() {
      videoPlayerController
          .seekTo(Duration(milliseconds: _videoStartPos.toInt()));

      videoPlayerController.play();
    });
  }

  @override
  void dispose() {
    videoPlayerController.pause();
    if (_videoFile != null) {
      videoPlayerController.setVolume(0.0);
      videoPlayerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: SizedBox(
        height: _thumbnailViewerH,
        width: _thumbnailViewerW,
        child: Stack(
          children: [
            Container(
              color: const Color(0xFF252525),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 17),
              child: Container(
                color: const Color(0xFFEEEEEE),
                child: thumbnailWidget ?? Container(),
              ),
            ),
            TrimCutter(
              startPos: _startPos,
              endPos: _endPos,
              width: _thumbnailViewerW,
              borderPaintColor: widget.borderPaintColor,
              scrubberPaintColor: widget.scrubberPaintColor,
              onClingLeft: widget.onClingLeft,
              onClingRight: widget.onClingRight,
              isArrowsVisible: !_isVideoTooSmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> resetVideo() async {
    if (videoPlayerController.isDisposedOrNotInitialized) return;
    if (isVideoResetInProgress) return;

    isVideoResetInProgress = true;

    await videoPlayerController.pause();
    await videoPlayerController.seekTo(
      Duration(milliseconds: _videoStartPos.toInt()),
    );
    await videoPlayerController.play();

    isVideoResetInProgress = false;
  }
}

enum EditorDragType {
  /// The user is dragging the left part of the frame.
  left,

  /// The user is dragging the whole frame.
  center,

  /// The user is dragging the right part of the frame.
  right
}
