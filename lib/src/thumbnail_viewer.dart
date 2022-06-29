import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailViewer extends StatelessWidget {
  final File videoFile;
  final int videoDuration;
  final double thumbnailHeight;
  final BoxFit fit;
  final int numberOfThumbnails;
  final int quality;
  final double width;
  final VideoPlayerController controller;
  /// For showing the thumbnails generated from the video,
  /// like a frame by frame preview
  const ThumbnailViewer({
    Key? key,
    required this.videoFile,
    required this.controller,
    required this.width,
    required this.videoDuration,
    required this.thumbnailHeight,
    required this.numberOfThumbnails,
    required this.fit,
    this.quality = 75,
  }) : super(key: key);

  Stream<List<Uint8List?>> generateThumbnail() async* {
    final multiplier = controller.value.size.height / thumbnailHeight;
    final width = controller.value.size.width / multiplier;

    final String _videoPath = videoFile.path;

    double _eachPart = videoDuration / numberOfThumbnails;

    List<Uint8List?> _byteList = [];

    // the cache of last thumbnail
    Uint8List? _lastBytes;

    for (int i = 1; i <= this.width / width; i++) {
      Uint8List? _bytes;
      _bytes = await VideoThumbnail.thumbnailData(
        video: _videoPath,
        imageFormat: ImageFormat.JPEG,
        timeMs: (_eachPart * i).toInt(),
        quality: 1,
      );

      // if current thumbnail is null use the last thumbnail
      if (_bytes != null) {
        _lastBytes = _bytes;
      } else {
        _bytes = _lastBytes;
      }

      _byteList.add(_bytes);

      yield _byteList;
    }
  }

  @override
  Widget build(BuildContext context) {
    final multiplier = controller.value.size.height / thumbnailHeight;
    final width = controller.value.size.width / multiplier;
    return StreamBuilder<List<Uint8List?>>(
      stream: generateThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Uint8List?> _imageBytes = snapshot.data!;
          return SizedBox(
            width: this.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              child: Row(
                children: _imageBytes.map(
                  (e) => SizedBox(
                    height: thumbnailHeight,
                    width: width,
                    child: Image(
                      image: MemoryImage(e!),
                      fit: fit,
                    ),
                  ),
                ).toList(),
              ),
            ),
          );
        } else {
          return Container(
            color: Color(0xFFEEEEEE),
            height: thumbnailHeight,
            width: double.maxFinite,
          );
        }
      },
    );
  }
}
