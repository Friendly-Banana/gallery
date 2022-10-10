import 'package:flutter/material.dart';
import 'package:gallery/model.dart';
import 'package:gallery/widgets/thumbnail.dart';

class SelectableGridView extends StatefulWidget {
  final Iterable items;
  final Set selected;

  const SelectableGridView(
      {required this.items, this.selected = const {}, Key? key})
      : super(key: key);

  @override
  State<SelectableGridView> createState() => SelectableGridViewState();
}

class SelectableGridViewState extends State<SelectableGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items.elementAt(index);
        return InkWell(
          onTap: () => setState(() {
            if (!widget.selected.add(item)) widget.selected.remove(item);
          }),
          child: Stack(children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                  widget.selected.contains(item)
                      ? Colors.black26
                      : Colors.transparent,
                  BlendMode.darken),
              child: item is MediaFile
                  ? MyThumbnail.fromFile(mediaFile: item)
                  : MyThumbnail.fromAsset(asset: item),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                child: widget.selected.contains(item)
                    ? Icon(Icons.check_circle,
                        color: Theme.of(context).colorScheme.onPrimary)
                    : Icon(Icons.circle_outlined,
                        color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ]),
        );
      },
    );
  }
}
