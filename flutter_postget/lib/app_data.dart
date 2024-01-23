import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

enum UserType {
  chatBot,
  human,
}

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

  // Funció per fer crides tipus 'POST' amb un arxiu adjunt,
  //i agafar la informació a mida que es va rebent
  Future<String> loadHttpPostByChunks(String url, File file,
      {String? message}) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Verifica si se ha adjuntado un archivo
    if (file.path.isEmpty) {
      request.fields['type'] = 'conversa';
      request.fields['message'] = '$message';
    } else {
      request.fields['type'] = 'imatge';
      request.fields['message'] = '$message';

      var stream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: file.path.split('/').last,
        contentType: MediaType('application', 'octet-stream'),
      );
      request.files.add(multipartFile);
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // Procesar la respuesta del servidor
        var responseData = await response.stream.toBytes();
        var responseString = utf8.decode(responseData);
        return responseString;
      } else {
        throw Exception(
            "Error del servidor (appData/loadHttpPostByChunks): ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Excepción en loadHttpPostByChunks: $e");
      throw e;
    }
  }

  // Funcion para enviar al server del chatbot
  void sendBackend(String textBody, File selectedFile) {
    if (selectedFile.path.isEmpty) {
      print("tipus conversa");
      loadHttpPostByChunks("http://localhost:3000/chat", selectedFile,
          message: textBody);
    } else {
      print("tipus image");
      loadHttpPostByChunks("http://localhost:3000/chat", selectedFile,
          message: textBody);
    }
  }
}

class MessageBox {
  UserType owner;
  String textContent = "";
  bool hasImage;
  late File image;

  // Constructor with named parameters
  MessageBox({
    required this.owner, // Add the owner parameter
    required this.textContent,
    this.hasImage = false,
    required this.image,
  });

  // Additional constructor for cases without an image
  MessageBox.textOnly({
    required this.owner, // Add the owner parameter
    required this.textContent,
  }) : hasImage = false;
}
