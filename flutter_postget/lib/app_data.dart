import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_postget/message_box.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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

  final ScrollController scrollController = ScrollController();

  File? selectedImage;

  void scrollDown() {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  // Funció per fer crides tipus 'GET' i agafar la informació a mida que es va rebent
  Future<void> loadHttpGetByChunks(String url) async {
    var httpClient = HttpClient();
    var completer = Completer<void>();

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();

      dataGet = "";

      // Listen to each chunk of data
      response.transform(utf8.decoder).listen(
        (data) {
          // Aquí rep cada un dels troços de dades que envia el servidor amb 'res.write'
          dataGet += data;
          notifyListeners();
        },
        onDone: () {
          completer.complete();
        },
        onError: (error) {
          completer.completeError(
              "Error del servidor (appData/loadHttpGetByChunks): $error");
        },
      );
    } catch (e) {
      completer.completeError("Excepció (appData/loadHttpGetByChunks): $e");
    }

    return completer.future;
  }

  // Funció per fer crides tipus 'POST' amb un arxiu adjunt,
  // i agafar la informació a mida que es va rebent
  Future<void> loadHttpPostByChunks(String url, String body, MessageBox botMessage,{File? file}) async {
    var completer = Completer<void>();
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add JSON data as part of the form
    //request.fields['data'] = '{"type":"test"}';
    // Attach the file as part of the form
    if (file != null) {
      request.fields['data'] = '{"type":"imatge", "message":"$body"}';
      var stream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile('file', stream, length,
          filename: file.path.split('/').last,
          contentType: MediaType('application', 'octet-stream'));
      request.files.add(multipartFile);
    } else {
      request.fields['data'] = '{"type":"conversa", "message":"$body"}';
    }

    try {
      var response = await request.send();

      dataPost = "";

      // Listen to each chunk of data
      response.stream.transform(utf8.decoder).listen(
        (data) {
          if (!loadingPost) {
            http.post(Uri.parse("http://localhost:3000/close"));
            return;
          } else {
            // Update dataPost with the latest data
            dataPost += data;
            botMessage.textContent = dataPost;
            print(data);
            notifyListeners();
            scrollDown();
          }
        },
        onDone: () {
          completer.complete();
        },
        onError: (error) {
          completer.completeError(
              "Error del servidor (appData/loadHttpPostByChunks): $error");
        },
      );
    } catch (e) {
      completer.completeError("Excepció (appData/loadHttpPostByChunks): $e");
    }

    return completer.future;
  }

  // Carregar dades segons el tipus que es demana
  void load(String body, MessageBox botMessage, {File? selectedFile}) async {
    loadingPost = true;
    notifyListeners();
    await loadHttpPostByChunks('http://localhost:3000/data', body, botMessage,file:  selectedFile);
    loadingPost = false;
    notifyListeners();
  }
}
