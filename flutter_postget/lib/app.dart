import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:flutter_postget/layout_chat.dart';
import 'package:flutter_postget/layout_desktop.dart';

// Main application widget
class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() => AppState();
}

// Main application state
class AppState extends State<App> {
  // Define the layout to use depending on the screen width
  Widget _setLayout(BuildContext context) {
    return const CDKApp(
        defaultAppearance: "system", // system, light, dark
        defaultColor: "systemBlue",
        //child: LayoutDesktop(title: "App Desktop Title"));
        child: LayoutChat(title: "ChatBot IETI | Beta"));
  }

  // Definir el contingut del widget 'App'
  @override
  Widget build(BuildContext context) {
    // Farem servir la base 'Cupertino'
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.light),
      home: _setLayout(context),
    );
  }
}
