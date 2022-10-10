import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery/config.dart';
import 'package:gallery/model.dart';
import 'package:gallery/screens/fullscreen_media.dart';
import 'package:gallery/widgets/select_dialog.dart';
import 'package:gallery/widgets/selectable.dart';
import 'package:gallery/widgets/thumbnail.dart';
import 'package:path/path.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'pick_new_files.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  bool selectMode = false;
  final Set<MediaFile> selected = {};

  @override
  Widget build(BuildContext context) => Consumer<MediaFileProvider>(
        builder: (context, model, child) => Scaffold(
          appBar:
              AppBar(title: Text("Gallery (${model.files.length})"), actions: [
            IconButton(
              icon: const Icon(Icons.lock_open),
              tooltip: "Unhide selected files",
              onPressed: () => _unlockTapped(model),
            ),
            if (!selectMode)
              IconButton(
                icon: const Icon(Icons.play_circle_outline),
                tooltip: "Slideshow",
                onPressed: () => model.files.isEmpty
                    ? _snackbar("Add files first")
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MediaScreen(startIndex: 0, slide: true)),
                      ),
              ),
            if (!selectMode)
              IconButton(
                icon: const Icon(Icons.sort),
                tooltip: "Sort",
                onPressed: () => selectDialog(
                    context,
                    SortingBy.values,
                    "Sort Order",
                    describeEnum,
                    model.sort,
                    TextButton(
                        child: Text(
                            "Toggle ${model.ascending ? "Ascending" : "Descending"}"),
                        onPressed: () {
                          model.toggleAscending();
                          Navigator.pop(context);
                        })),
              ),
          ]),
          body: selectMode
              ? SelectableGridView(items: model.files, selected: selected)
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10),
                  itemCount: model.files.length,
                  itemBuilder: (context, index) {
                    MediaFile mediaFile = model.files.elementAt(index);
                    return InkWell(
                      child: MyThumbnail.fromFile(mediaFile: mediaFile),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MediaScreen(startIndex: index, slide: false)),
                      ),
                      onLongPress: () => setState(() {
                        selectMode = true;
                        selected.add(mediaFile);
                      }),
                    );
                  },
                ),
          floatingActionButton: selectMode
              ? FloatingActionButton(
                  onPressed: () => setState(() => selectMode = false),
                  tooltip: "Finished",
                  child: const Icon(Icons.close),
                )
              : FloatingActionButton(
                  onPressed: () => _addFiles(model),
                  tooltip: "Add files",
                  child: const Icon(Icons.add),
                ),
        ),
      );

  void _unlockTapped(MediaFileProvider model) {
    if (selectMode) {
      _removeFiles(model);
    } else {
      if (model.files.isEmpty) {
        _snackbar("Add files first");
      } else {
        _snackbar("Select files to unhide first");
        setState(() => selectMode = true);
      }
    }
  }

  void _snackbar(String text) {
    ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text(text), duration: const Duration(seconds: 2)));
  }

  Future<void> _addFiles(MediaFileProvider model) async {
    final Set<AssetEntity>? media = await Navigator.push(this.context,
        MaterialPageRoute(builder: (context) => PickAlbumScreen()));
    if (media == null || media.isEmpty) {
      _snackbar("File picking cancelled");
    } else {
      for (AssetEntity asset in media) {
        File sourceFile = (await asset.originFile)!;
        // store file in app directory
        try {
          // copy-delete needed because of different filesystems
          File newFile = await sourceFile.copy(join(
              Config.appDirPath,
              asset.type == AssetType.image ? Config.imageDir : Config.videoDir,
              basename(sourceFile.path)));
          model.files.add(
              MediaFile(file: newFile, isImage: asset.type == AssetType.image));
          // delete old file to complete move
          await sourceFile.delete();
        } // ignore shadow files when media query didn't catch up yet
        on FileSystemException catch (e) {
          log("Copying file failed", error: e);
        }
      }
      // delete picked from media database
      PhotoManager.editor.android.removeAllNoExistsAsset();
      model.sendUpdate();
    }
  }

  void _removeFiles(MediaFileProvider model) async {
    if (selected.isEmpty) return;
    for (MediaFile oldFile in selected) {
      if (Config.unhideToDownloads) {
        await oldFile.file.copy(
            "/storage/emulated/0/Download/${basename(oldFile.file.path)}");
      } else {
        // properly insert into media database
        if (oldFile.isImage) {
          await PhotoManager.editor.saveImageWithPath(oldFile.file.path,
              title: basename(oldFile.file.path));
        } else {
          await PhotoManager.editor
              .saveVideo(oldFile.file, title: basename(oldFile.file.path));
        }
      }
      await oldFile.file.delete();
    }
    model.remove(selected);
    setState(() {
      selectMode = false;
      selected.clear();
    });
  }
}
