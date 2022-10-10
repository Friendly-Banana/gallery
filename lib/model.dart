import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

import 'config.dart';

enum SortingBy { Name, Size, Type, LastModified }

class MediaFile {
  final bool isImage;
  File file;

  MediaFile({required this.file, this.isImage = true});
}

class MediaFileProvider with ChangeNotifier {
  bool ascending = true;
  SortingBy sortMode = SortingBy.Name;
  Set<MediaFile> files = {};
  bool _noControls = false;
  bool get noControls => _noControls;

  MediaFileProvider() {
    Config.onAppDir = loadFiles;
  }

  void sendUpdate() {
    notifyListeners();
  }

  void remove(Iterable elements) {
    files.removeAll(elements);
    notifyListeners();
  }

  void sort(SortingBy newSortMode) {
    List<MediaFile> sortedFiles = files.toList(growable: false);
    sortedFiles.sort((a, b) {
      switch (newSortMode) {
        case SortingBy.Name:
          return basename(a.file.path).compareTo(basename(b.file.path));
        case SortingBy.LastModified:
          return a.file.lastModifiedSync().compareTo(b.file.lastModifiedSync());
        case SortingBy.Size:
          return a.file.lengthSync().compareTo(b.file.lengthSync());
        case SortingBy.Type:
          if (a.isImage == b.isImage) {
            return 0;
          } else if (a.isImage) {
            return -1;
          }
          return 1;
      }
    });
    if (ascending) {
      files = sortedFiles.toSet();
    } else {
      files = sortedFiles.reversed.toSet();
    }
    sortMode = newSortMode;
    notifyListeners();
  }

  void toggleAscending() {
    ascending = !ascending;
    files = files.toList().reversed.toSet();
    notifyListeners();
  }

  void toggleControls() {
    _noControls = !noControls;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: _noControls ? [] : SystemUiOverlay.values);
    notifyListeners();
  }

  Future<void> loadFiles() async {
    // ensure folders exist
    final imgDir = Directory(join(Config.appDirPath, Config.imageDir));
    if (!(await imgDir.exists())) await imgDir.create();
    final vidDir = Directory(join(Config.appDirPath, Config.videoDir));
    if (!(await vidDir.exists())) await vidDir.create();
    // add images and videos
    files.addAll((await imgDir.list(followLinks: false).toList())
        .whereType<File>()
        .map((file) => MediaFile(file: file, isImage: true)));
    files.addAll((await vidDir.list(followLinks: false).toList())
        .whereType<File>()
        .map((file) => MediaFile(file: file, isImage: false)));
    // update
    notifyListeners();
  }
}
