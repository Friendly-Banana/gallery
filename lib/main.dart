import 'package:flutter/material.dart';
import 'package:gallery/config.dart';
import 'package:gallery/model.dart';
import 'package:gallery/screens/home.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  static ValueNotifier<bool> darkNotifier = ValueNotifier(Config.darkMode);

  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    Config.load();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      Config.save();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MediaFileProvider>(
      create: (context) => MediaFileProvider(),
      child: ValueListenableBuilder(
        valueListenable: App.darkNotifier,
        builder: (BuildContext context, bool value, Widget? child) =>
            MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Gallery",
          theme: value ? ThemeData.dark() : ThemeData.light(),
          initialRoute: "home",
          routes: {
            "home": (context) => const Homepage(),
          },
        ),
      ),
    );
  }
}
