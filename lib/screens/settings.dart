import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery/config.dart';
import 'package:gallery/main.dart';
import 'package:gallery/widgets/select_dialog.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: <Widget>[
        _title("Slideshow"),
        ListTile(
          title: const Text("Duration per Image"),
          subtitle: Slider(
              label: "${Config.slideDuration}s",
              value: Config.slideDuration,
              onChanged: (double value) =>
                  setState(() => Config.slideDuration = value),
              divisions: 19,
              min: 0.5,
              max: 10),
        ),
        ListTile(
          title: const Text("Slide Animation"),
          subtitle: Text(Config.animationName(Config.slideAnimation)),
          onTap: () => selectDialog(
              context,
              Config.animationCurves.keys,
              "Animation",
              (Curve curve) => Config.animationName(curve),
              (Curve curve) => setState(() => Config.slideAnimation = curve)),
        ),
        _title("General"),
        SwitchListTile(
          title: const Text("Dark Mode"),
          value: Config.darkMode,
          onChanged: (value) =>
              setState(() => Config.darkMode = App.darkNotifier.value = value),
        ),
        if (Platform.isAndroid)
          SwitchListTile(
            title: const Text("Restore folder"),
            subtitle: Text(Config.unhideToDownloads ? "Downloads" : "Pictures"),
            value: Config.unhideToDownloads,
            onChanged: (value) =>
                setState(() => Config.unhideToDownloads = value),
          ),
        ListTile(
          title: const Text("Thumbnail Size"),
          subtitle: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("High values might worsen performance"),
              ),
              Slider(
                  label: "${Config.logicalThumbnailSize}px",
                  value: Config.logicalThumbnailSize.toDouble(),
                  onChanged: (double value) => setState(
                      () => Config.logicalThumbnailSize = value.toInt()),
                  divisions: 7,
                  min: 64,
                  max: 512),
            ],
          ),
        ),
        AboutListTile(
          applicationName: Config.packageInfo.appName,
          applicationVersion: Config.appVersion,
          applicationIcon: Image.asset(
            "assets/icon 128.png",
            width: 80,
          ),
          applicationLegalese: "©2022 FriendlyBanana",
        ),
      ]),
    );
  }

  ListTile _title(String text) {
    return ListTile(
        title: Text(
      text,
      style: TextStyle(color: Theme.of(context).indicatorColor),
    ));
  }
}
