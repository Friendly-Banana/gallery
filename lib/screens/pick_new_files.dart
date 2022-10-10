import 'package:gallery/config.dart';
import 'package:gallery/widgets/selectable.dart';
import 'package:gallery/widgets/thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_manager/photo_manager.dart';

class PickAlbumScreen extends StatefulWidget {
  @override
  _PickAlbumScreenState createState() => _PickAlbumScreenState();
}

class _PickAlbumScreenState extends State<PickAlbumScreen> {
  List<AssetPathEntity> albums = [];
  List<Widget> thumbnails = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select album'),
      ),
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
          itemCount: albums.length,
          itemBuilder: (_, index) {
            final album = albums.elementAt(index);
            return InkWell(
              onTap: () async {
                Set<AssetEntity>? pickedMedia = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PickMediaScreen(album: album)),
                );
                if (pickedMedia != null) {
                  Navigator.pop(context, pickedMedia);
                }
              },
              child: Stack(
                children: [
                  thumbnails.elementAt(index),
                  Container(
                      padding: EdgeInsets.all(3),
                      alignment: Alignment.bottomLeft,
                      child: Text("${album.name} (${album.assetCount})",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              shadows: [Shadow(offset: Offset(1, 1))]))),
                ],
              ),
            );
          }),
    );
  }

  @override
  void initState() {
    _fetchAlbums();
    super.initState();
  }

  _fetchAlbums() async {
    // get all Albums
    albums = await PhotoManager.getAssetPathList();
    thumbnails = List.generate(albums.length, (index) => loadingWidget);
    setState(() {});
    for (int i = 0; i < albums.length; i++) {
      List<AssetEntity> firstAsset =
          await albums[i].getAssetListRange(start: 0, end: 1);
      thumbnails[i] =
          MyThumbnail.fromAsset(asset: firstAsset.first, showPlayIcon: false);
    }
    setState(() {});
  }
}

class PickMediaScreen extends StatefulWidget {
  final AssetPathEntity album;

  const PickMediaScreen({Key? key, required this.album}) : super(key: key);

  @override
  _PickMediaScreenState createState() => _PickMediaScreenState();
}

class _PickMediaScreenState extends State<PickMediaScreen> {
  // This will hold all the assets we fetched
  List<AssetEntity> allAssets = [];
  final Set<AssetEntity> pickedAssets = {};

  @override
  void initState() {
    _fetchAssets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.name),
      ),
      body: SelectableGridView(items: allAssets, selected: pickedAssets),
      floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pop(context, pickedAssets),
          child: Icon(Icons.check),
          tooltip: "Add files"),
    );
  }

  _fetchAssets() async {
    // Now that we got the album, fetch all the assets it contains
    final recentAssets = await widget.album.getAssetListRange(
      start: 0, // start at index 0
      end: 10000, // end at a very big index (to get all the assets)
    );

    // Update the state and notify UI
    setState(() {
      allAssets = recentAssets;
    });
  }
}
