import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmerView extends StatefulWidget {
  final File file;

  const TrimmerView(this.file, {Key? key}) : super(key: key);
  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();


    _loadVideo();
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file, isVolumeOn: true);
  }

  @override
  Widget build(BuildContext context) {
    // if(_isPlaying) {
    //   _trimmer.videPlaybackControl(
    //     startValue: _startValue,
    //     endValue: _endValue,
    //   );
    // } else {
    //   _trimmer.videPlaybackControl(
    //     startValue: _startValue,
    //     endValue: _endValue,
    //   );
    // }
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress) {
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Video Trimmer"),
        ),
        body: Builder(
          builder: (context) => Center(
            child: Container(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: VideoViewer(trimmer: _trimmer),
                  ),
                  Center(
                    child: TrimEditor(
                      trimmer: _trimmer,
                      viewerHeight: 46.0,
                      viewerWidth: MediaQuery.of(context).size.width - 50,
                      fit: BoxFit.fitWidth,
                      minVideoLength: const Duration(seconds: 3),
                      scrubberPaintColor: const Color(0xFFA3F3DD),
                      circlePaintColor: const Color(0xFFA3F3DD),
                      borderPaintColor: const Color(0xFFA3F3DD),
                      previewWrapper: (_) {
                        return _;
                      },
                      onChangeStart: (value) {
                        _startValue = value;
                      },
                      onChangeEnd: (value) {
                        _endValue = value;
                      },
                      onClingLeft: () => print('clinged left'),
                      onClingRight: () => print('clinged right'),
                    ),
                  ),
                  TextButton(
                    child: _isPlaying
                        ? const Icon(
                            Icons.pause,
                            size: 80.0,
                            color: Colors.black,
                          )
                        : const Icon(
                            Icons.play_arrow,
                            size: 80.0,
                            color: Colors.black,
                          ),
                    onPressed: () async {
                      bool playbackState = await _trimmer.videPlaybackControl(
                        startValue: _startValue,
                        endValue: _endValue,
                      );
                      setState(() {
                        _isPlaying = playbackState;
                      });
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
