import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery/model.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../config.dart';

class MyThumbnail extends StatelessWidget {
  final bool showPlayIcon;
  final bool isImage;
  final Future<Uint8List?> bytes;

  const MyThumbnail(
      {Key? key,
      required this.bytes,
      this.isImage = true,
      this.showPlayIcon = true})
      : super(key: key);

  MyThumbnail.fromFile(
      {super.key, required MediaFile mediaFile, this.showPlayIcon = true})
      : isImage = mediaFile.isImage,
        bytes = mediaFile.isImage
            ? mediaFile.file.readAsBytes()
            : VideoThumbnail.thumbnailData(
                video: mediaFile.file.path,
                maxWidth: Config.realThumbnailSize,
                maxHeight: Config.realThumbnailSize,
              );

  MyThumbnail.fromAsset(
      {super.key, required AssetEntity asset, this.showPlayIcon = true})
      : bytes = asset.thumbnailData,
        isImage = asset.type == AssetType.image;

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
        future: bytes,
        builder: (_, s) => !s.hasData
            ? loadingWidget
            : Stack(children: [
                // Wrap the image in a Positioned.fill to fill the space
                Positioned.fill(
                  child: Image.memory(
                    s.data!,
                    fit: BoxFit.cover,
                    cacheWidth: Config.realThumbnailSize,
                  ),
                ),
                // Display a Play icon if the asset is a video
                if (!isImage && showPlayIcon)
                  const Center(
                    child: Icon(
                      Icons.play_arrow,
                    ),
                  ),
              ]),
      );
}

/* Create AssetEntity from File
    static Future<AssetEntity> fromFile(File file, bool isImage) async {
    // Convert to Uint8List
    final Uint8List byteData = await file.readAsBytes();
    // Save on the device to create an AssetEntity
    final AssetEntity? assetEntity;
    if (isImage)
      assetEntity = await PhotoManager.editor.saveImage(byteData);
    else
      assetEntity = await PhotoManager.editor.saveVideo(file);
    await PhotoManager.editor.deleteWithIds([id]);
    return assetEntity;
  }
 */
