import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Funció per fer crides tipus 'GET' i agafar la informació a mida que es va rebent
  Future<String> loadHttpGetByChunks(String url) async {
    var httpClient = HttpClient();
    var completer = Completer<String>();
    String result = "";

    // If development, wait 1 second to simulate a delay
    if (!kReleaseMode) {
      await Future.delayed(const Duration(seconds: 1));
    }

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
              "Error del servidor (appData/loadHttpGetByChunks): $error");
        },
      );
    } catch (e) {
      completer.completeError("Excepció (appData/loadHttpGetByChunks): $e");
    }

    return completer.future;
  }

  // Funció per fer crides tipus 'POST' amb un arxiu adjunt,
  //i agafar la informació a mida que es va rebent
  Future<String> loadHttpPostByChunks(String url, File file) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Afegir les dades JSON com a part del formulari
    request.fields['data'] = '{"type":"test"}';

    // Adjunta l'arxiu com a part del formulari
    var stream = http.ByteStream(file.openRead());
    var length = await file.length();
    var multipartFile = http.MultipartFile('file', stream, length,
        filename: file.path.split('/').last,
        contentType: MediaType('application', 'octet-stream'));
    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      // La sol·licitud ha estat exitosa
      var responseData = await response.stream.toBytes();
      var responseString = utf8.decode(responseData);
      return responseString;
    } else {
      // La sol·licitud ha fallat
      throw Exception(
          "Error del servidor (appData/loadHttpPostByChunks): ${response.reasonPhrase}");
    }
  }

  // Funció per fer carregar dades d'un arxiu json de la carpeta 'assets'
  Future<dynamic> readJsonAsset(String filePath) async {
    // If development, wait 1 second to simulate a delay
    if (!kReleaseMode) {
      await Future.delayed(const Duration(seconds: 1));
    }

    try {
      var jsonString = await rootBundle.loadString(filePath);
      final jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      throw Exception("Excepció (appData/readJsonAsset): $e");
    }
  }

  // Carregar dades segons el tipus que es demana
  void load(String type, {File? selectedFile}) async {
    switch (type) {
      case 'GET':
        loadingGet = true;
        notifyListeners();

        // TODO: Cal modificar el funcionament d'aquí
        // per tal d'actualitzar el valor de 'dataGet' a mida que es va rebent
        // la informació del servidor, enlloc de mostrar 'Loading ...'
        dataGet = await loadHttpGetByChunks(
            'http://localhost:3000/llistat?cerca=motos&color=vermell');

        loadingGet = false;
        notifyListeners();
        break;
      case 'POST':
        loadingPost = true;
        notifyListeners();

        dataPost = await loadHttpPostByChunks(
            'http://localhost:3000/data', selectedFile!);

        loadingPost = false;
        notifyListeners();
        break;
      case 'FILE':
        loadingFile = true;
        notifyListeners();

        var fileData = await readJsonAsset("assets/data/example.json");

        loadingFile = false;
        switch (type) {
          case 'conversa':
            break;
          case 'imatge':
            break;
          default:
        }
        dataFile = fileData;
        notifyListeners();
        break;
    }
  }

  // Funcion para enviar al server del chatbot
  void sendBackend(String textBody, {File? selectedFile}) {
    if (selectedFile == null) {
      print("tipus conversa");
      loadHttpPost("http://localhost:3000/chat", "conversa", selectedFile!);
    } else {
      print("tipus image");
      loadHttpPost("http://localhost:3000/chat", "imatge", selectedFile!);
    }
  }

  // Funcion para cargar con o sin imagen
  Future<String> loadHttpPost(String url, String type, File file) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));

    switch (type) {
      case 'imatge':
        break;
      case 'conversa':
        break;
      default:
    }

    // Afegir les dades JSON com a part del formulari
    request.fields['data'] = '{"type":"test"}';

    // Adjunta l'arxiu com a part del formulari
    var stream = http.ByteStream(file.openRead());
    var length = await file.length();
    var multipartFile = http.MultipartFile('file', stream, length,
        filename: file.path.split('/').last,
        contentType: MediaType('application', 'octet-stream'));
    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      // La sol·licitud ha estat exitosa
      var responseData = await response.stream.toBytes();
      var responseString = utf8.decode(responseData);
      return responseString;
    } else {
      // La sol·licitud ha fallat
      throw Exception(
          "Error del servidor (appData/loadHttpPostByChunks): ${response.reasonPhrase}");
    }
  }
}
