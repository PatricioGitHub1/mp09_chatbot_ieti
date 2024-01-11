import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

class LayoutDesktop extends StatefulWidget {
  const LayoutDesktop({super.key, required this.title});

  final String title;

  @override
  State<LayoutDesktop> createState() => _LayoutDesktopState();
}

class _LayoutDesktopState extends State<LayoutDesktop> {
  // Return a custom button
  Widget buildCustomButton(String buttonText, VoidCallback onPressedAction) {
    return SizedBox(
      width: 150, // Amplada total de l'espai
      child: Align(
        alignment: Alignment.centerRight, // Alineació a la dreta
        child: CDKButton(
          style: CDKButtonStyle.normal,
          isLarge: false,
          onPressed: onPressedAction,
          child: Text(buttonText),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    String stringGet = "";
    if (appData.loadingGet) {
      stringGet = "Loading ...";
    } else if (appData.dataGet != null) {
      stringGet = "GET: ${appData.dataGet.toString()}";
    }

    String stringFile = "";
    if (appData.loadingFile) {
      stringFile = "Loading ...";
    } else if (appData.dataFile != null) {
      stringFile = "File: ${appData.dataFile}";
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Vertical
        children: <Widget>[
          Container(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildCustomButton('Crida tipus GET', () {
                appData.load("GET");
              }),
              Container(
                width: 10,
              ),
              Expanded(
                  child: Text(stringGet,
                      softWrap: true, overflow: TextOverflow.visible)),
            ],
          ),
          Container(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildCustomButton('Llegir arxiu .JSON', () {
                appData.load("FILE");
              }),
              Container(
                width: 10,
              ),
              Expanded(
                  child: Text(stringFile,
                      softWrap: true, overflow: TextOverflow.visible)),
            ],
          ),
        ],
      ),
    );
  }
}
