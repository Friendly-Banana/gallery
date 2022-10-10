import 'package:flutter/material.dart';

Future selectDialog<T extends Object>(
    BuildContext context,
    Iterable<T> values,
    String title,
    String Function(T) itemDescription,
    void Function(T) onSelected,
    [Widget? child]) async {
  final List<Widget> children = child == null ? [] : [child];
  final result = await showDialog(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      title: Text("Select " + title),
      children: children
        ..addAll(List.generate(
          values.length,
          (index) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, values.elementAt(index)),
            child: Text(itemDescription(values.elementAt(index))),
          ),
        )),
    ),
  );
  if (result != null) onSelected(result);
}
