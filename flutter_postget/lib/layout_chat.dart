import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_postget/message_box.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutChat extends StatefulWidget {
  const LayoutChat({super.key, required this.title});

  final String title;

  @override
  State<LayoutChat> createState() => _LayoutChatState();
}

class _LayoutChatState extends State<LayoutChat> {
  double windowHeight = 0;
  double windowWidth = 0;

  TextEditingController messageController = TextEditingController();
  List<MessageBox> mensajes = [];

  // Funció per seleccionar un arxiu
  Future<File> pickFile() async {
    FilePickerResult? result;

    result = await FilePicker.platform.pickFiles(dialogTitle: 'prueba', withData: true);

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      throw Exception("No s'ha seleccionat cap arxiu.");
    }
  }

  // Funció per carregar l'arxiu seleccionat amb una sol·licitud POST
  Future<void> uploadFile(AppData appData) async {
    try {

      appData.selectedImage = await pickFile();
      print('selected file');
    } catch (e) {
      if (kDebugMode) {
        print("Excepció (uploadFile): $e");
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width * 0.8;

    if (windowWidth < 350) {
      windowWidth = MediaQuery.of(context).size.width;
    }

    // Agregamos algunos mensajes de ejemplo al inicio
    if (mensajes.isEmpty) {
      mensajes.add(MessageBox.textOnly(
          owner: UserType.chatBot, textContent: "Welcome to IETI ChatBot!"));
      mensajes.add(MessageBox.textOnly(
          owner: UserType.chatBot,
          textContent: "Feel free to ask me anything"));
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: windowWidth,
                color: CupertinoColors.white,
                child: CupertinoScrollbar(
                  controller: appData.scrollController,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    controller: appData.scrollController,
                    itemCount: mensajes.length,
                    itemBuilder: (context, index) {
                      return buildMessageItem(mensajes[index]);
                    },
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: CupertinoColors.lightBackgroundGray,
              child: Row(
                children: [
                  CupertinoButton(
                    onPressed: () async {
                      //print('en botton para enviar img');
                      await uploadFile(appData);
                      
                    },
                    child:
                        const Icon(CupertinoIcons.photo_fill_on_rectangle_fill),
                  ),
                  Expanded(
                    child: CupertinoTextField(
                      controller: messageController,
                      placeholder: 'Type your message...',
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      if (messageController.text.isEmpty && appData.selectedImage == null) {
                        return;
                      }
                      MessageBox newBotMessage = MessageBox.textOnly(owner: UserType.chatBot, textContent: "Loading...");
                      // esto es para determinar si es tipo conversa o imatge, falta el file picker ...
                      addMessage(UserType.human, messageController.text);
                      if (appData.selectedImage == null) {
                        appData.load(messageController.text, newBotMessage);
                      } else {
                        appData.load(messageController.text, newBotMessage, selectedFile:  appData.selectedImage);
                      }
                      
                      mensajes.add(newBotMessage);

                      messageController.clear();
                    },
                    child: const Text('Send'),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      print('stopping stream of message');
                      appData.loadingPost = false;
                    },
                    child:
                        const Icon(CupertinoIcons.clear_fill),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addMessage(UserType owner, String textContent) {
    setState(() {
      mensajes.add(MessageBox.textOnly(owner: owner, textContent: textContent));
    });
  }

  Widget buildMessageItem(MessageBox message) {
    double txtBubbleWidth = windowWidth * 0.45;
    if (txtBubbleWidth < 350) {
      txtBubbleWidth = windowWidth * 0.90;
    }
    return Align(
      alignment: message.owner == UserType.chatBot
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        width: txtBubbleWidth,
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: message.owner == UserType.chatBot
              ? CupertinoColors.activeBlue
              : CupertinoColors.activeGreen,
          border: Border.all(width: 1.0),
          borderRadius: const BorderRadius.all(
              Radius.circular(5.0) //                 <--- border radius here
              ),
        ),
        child: Text(
          message.textContent,
          style: CupertinoTheme.of(context).textTheme.textStyle,
        ),
      ),
    );
  }
}
