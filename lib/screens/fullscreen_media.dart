import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery/config.dart';
import 'package:gallery/model.dart';
import 'package:gallery/widgets/video_player.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class MediaScreen extends StatefulWidget {
  final int startIndex;
  final bool slide;

  const MediaScreen({Key? key, required this.startIndex, required this.slide})
      : super(key: key);

  @override
  _MediaScreenState createState() => _MediaScreenState(startIndex, slide);
}

class _MediaScreenState extends State<MediaScreen> with WidgetsBindingObserver {
  final PageController controller;
  bool sliding;
  Timer? _timer;

  _MediaScreenState(int index, this.sliding)
      : controller = PageController(initialPage: index);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<MediaFileProvider>(
        builder: (context, model, child) {
          return PageView.builder(
            controller: controller,
            itemCount: model.files.length,
            itemBuilder: (BuildContext context, int index) {
              MediaFile currentFile = model.files.elementAt(index);
              _checkStartingTimer(currentFile.isImage);
              return model.noControls
                  ? Scaffold(
                      backgroundColor: Colors.black,
                      body: buildTappableImage(model, currentFile),
                    )
                  : Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        title: Row(
                          children: [
                            Flexible(
                                child: Text(basename(currentFile.file.path))),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _changeName(currentFile, model),
                            ),
                          ],
                        ),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                      ),
                      body: buildTappableImage(model, currentFile),
                      bottomNavigationBar: BottomAppBar(
                        color: Colors.transparent,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.navigate_before),
                                onPressed: () => _swipe(right: false),
                              ),
                              IconButton(
                                icon: Icon(sliding
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline),
                                onPressed: () => setState(() {
                                  sliding = !sliding;
                                  _checkStartingTimer(currentFile.isImage);
                                }),
                              ),
                              IconButton(
                                icon: const Icon(Icons.navigate_next),
                                onPressed: () => _swipe(right: true),
                              ),
                            ]),
                      ),
                    );
            },
          );
        },
      );

  Widget buildTappableImage(MediaFileProvider model, MediaFile currentFile) {
    return InteractiveViewer(
        minScale: 1,
        maxScale: 3,
        child: GestureDetector(
          onTap: () => model.toggleControls(),
          child: currentFile.isImage
              ? Center(child: Image.file(currentFile.file))
              : VideoWidget(
                  videoFile: currentFile.file, onVideoFinished: _checkSwipe),
        ));
  }

  void _swipe({bool right = true}) {
    if (right) {
      controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Config.slideAnimation,
      );
    } else {
      controller.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Config.slideAnimation,
      );
    }
  }

  void _checkStartingTimer(bool isImage) {
    _timer?.cancel();
    if (sliding && isImage) {
      _timer = Timer(
          Duration(
              seconds: Config.slideDuration.floor(),
              milliseconds: Config.slideDuration % 1 == 0.5 ? 500 : 0),
          () => _checkSwipe());
    }
  }

  void _checkSwipe() {
    if (sliding) _swipe();
  }

  void _changeName(MediaFile currentFile, MediaFileProvider model) {
    showDialog(
        context: this.context,
        builder: (context) {
          final controller =
              TextEditingController(text: basename(currentFile.file.path));
          return AlertDialog(
            title: const Text('Set new Filename'),
            content: TextFormField(
              controller: controller,
              autofocus: true,
              enableIMEPersonalizedLearning: false,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter
              ],
            ),
            actions: [
              TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context)),
              TextButton(
                  child: const Text('Change'),
                  onPressed: () async {
                    // rename file
                    File newFile = await currentFile.file.rename(
                        join(currentFile.file.parent.path, controller.text));
                    setState(() {
                      currentFile.file = newFile;
                    });
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }
}
