import 'dart:io';
import 'dart:math';

import 'package:gallery/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final File videoFile;
  final void Function() onVideoFinished;

  VideoWidget(
      {Key? key, required this.videoFile, required this.onVideoFinished})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  late String lastPath = widget.videoFile.path;
  static bool muted = false;
  static bool shouldCallback = true;

  @override
  Widget build(BuildContext context) {
    if (lastPath != widget.videoFile.path) {
      lastPath = widget.videoFile.path;
      _initController();
    }
    return Consumer<MediaFileProvider>(
        builder: (context, model, child) => ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, VideoPlayerValue value, child) =>
                  Column(children: [
                Expanded(
                  child: Center(
                    child: value.isInitialized
                        ? AspectRatio(
                            aspectRatio: value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                        : const CircularProgressIndicator(),
                  ),
                ),
                if (!model.noControls) _infoRow(value),
                if (!model.noControls)
                  Slider(
                      value: value.position.inMilliseconds.toDouble(),
                      min: 0,
                      max: value.duration.inMilliseconds.toDouble(),
                      onChanged: (double timestamp) {
                        setState(() {
                          _controller.seekTo(Duration(
                              milliseconds: min(value.duration.inMilliseconds,
                                  timestamp.toInt())));
                        });
                      })
              ]),
            ));
  }

  Row _infoRow(VideoPlayerValue value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(_formatTime(value.position) + "/" + _formatTime(value.duration),
            maxLines: 1),
        InkWell(
          child: Icon(
            value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          onTap: () {
            setState(() {
              value.isPlaying ? _controller.pause() : _controller.play();
            });
          },
        ),
        InkWell(
          child: Icon(
            muted ? Icons.volume_off : Icons.volume_up,
          ),
          onTap: () {
            _controller.setVolume(muted ? 1 : 0);
            setState(() {
              muted = !muted;
            });
          },
        ),
      ]
          .map((e) => Container(
                child: e,
                width: 100,
              ))
          .toList(),
    );
  }

  String _formatTime(Duration dur) {
    return dur.toString().substring(3, 7);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _initController();
    super.initState();
  }

  void _initController() {
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        _controller.setVolume(muted ? 0 : 1);
        _controller.play();
        shouldCallback = true;
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        // detect end of video
        _controller.addListener(() {
          if (!_controller.value.isPlaying &&
              _controller.value.isInitialized &&
              _controller.value.duration == _controller.value.position &&
              shouldCallback) {
            shouldCallback = false;
            // update play button
            widget.onVideoFinished();
          }
        });
      });
  }
}
