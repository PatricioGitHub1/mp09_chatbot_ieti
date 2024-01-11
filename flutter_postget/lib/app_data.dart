import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppData with ChangeNotifier {
  // Access appData globaly with:
  // AppData appData = Provider.of<AppData>(context);
  // AppData appData = Provider.of<AppData>(context, listen: false)

  bool loadingGet = false;
  bool loadingPost = false;
  bool loadingFile = false;

  dynamic dataGet;
  dynamic dataPost;
  dynamic dataFile;

  Future<String> loadHttpChunks(String url) async {
    var httpClient = HttpClient();
    var completer = Completer<String>();
    String result = "";

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();

      response.transform(utf8.decoder).listen(
        (data) {
          // Aquí rep cada un dels troços de dades que envia el servidor amb 'res.write'
          result += data;
        },
        onDone: () {
          completer.complete(result);
        },
        onError: (error) {
          completer.completeError(
              "Error del servidor (appData/loadHttpChunks): $error");
        },
      );
    } catch (e) {
      completer.completeError("Excepció (appData/loadHttpChunks): $e");
    }

    return completer.future;
  }

  // Load data from '.json' file
  void load(String type) async {
    switch (type) {
      case 'GET':
        loadingGet = true;
        notifyListeners();

        // If development, wait 1 second to simulate a delay
        if (!kReleaseMode) {
          await Future.delayed(const Duration(seconds: 1));
        }

        dataGet = await loadHttpChunks(
            'http://localhost:3000/llistat?cerca=motos&color=vermell');
        loadingGet = false;
        notifyListeners();

        break;
      case 'FILE':
        loadingFile = true;
        notifyListeners();

        // If development, wait 1 second to simulate a delay
        if (!kReleaseMode) {
          await Future.delayed(const Duration(seconds: 1));
        }

        // Load data from file
        var file = "assets/data/example.json";
        var fileText = await rootBundle.loadString(file);
        var fileData = json.decode(fileText);

        loadingFile = false;
        dataFile = fileData;

        notifyListeners();
        break;
    }
  }
}
