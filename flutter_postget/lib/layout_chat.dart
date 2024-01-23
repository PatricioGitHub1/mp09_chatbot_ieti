import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutChat extends StatefulWidget {
  const LayoutChat({super.key, required this.title});

  final String title;

  @override
  State<LayoutChat> createState() => _LayoutChatState();
}

class _LayoutChatState extends State<LayoutChat> {
  final ScrollController _scrollController = ScrollController();

  File selectedImage = File('');
  bool isFileSelected = false;
  double windowHeight = 0;
  double windowWidth = 0;

  TextEditingController messageController = TextEditingController();

  List<MessageBox> mensajes = [];

  Future<File> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      throw Exception("No s'ha seleccionat cap arxiu.");
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
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: mensajes.length,
                    itemBuilder: (context, index) {
                      return buildMessageItem(mensajes[index]);
                    },
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              padding: const EdgeInsets.all(10),
              duration: const Duration(milliseconds: 100),
              height: isFileSelected ? 40 : 0,
              color: CupertinoColors.activeGreen,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'File Selected',
                      style: TextStyle(color: CupertinoColors.white),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      removeFile();
                    },
                    child: const Icon(CupertinoIcons.xmark_circle),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: CupertinoColors.lightBackgroundGray,
              child: Row(
                children: [
                  CupertinoButton(
                    onPressed: () async {
                      selectedImage = await pickFile();
                      isFileSelected = true;
                      setState(() {});
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
                      if (messageController.text.isEmpty &&
                          selectedImage.path.isEmpty) {
                        return;
                      } else if (selectedImage.path.isEmpty) {
                        addMessage(
                            UserType.human, messageController.text, null);
                      } else {
                        addMessage(UserType.human, messageController.text,
                            selectedImage);
                      }
                      appData.sendBackend(
                          messageController.text, selectedImage);
                      messageController.clear();
                      removeFile();
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addMessage(UserType owner, String textContent, File? imageContent) {
    setState(() {
      if (imageContent != null) {
        mensajes.add(MessageBox(
            owner: owner,
            textContent: textContent,
            image: imageContent,
            hasImage: true));
        scrollToEnd();
        return;
      }

      mensajes.add(MessageBox.textOnly(owner: owner, textContent: textContent));
      scrollToEnd();
    });
  }

  void scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }
/*
  Future<void> sendMessage(String message) async {
    final url = Uri.parse(
        'http://localhost:3000/chat'); // Reemplaza con la dirección de tu servidor
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'type': 'conversa', 'message': message}),
    );

    if (response.statusCode == 200) {
      print('Mensaje enviado con éxito');
      final jsonResponse = jsonDecode(response.body);
      final botMessage = jsonResponse['message'];
      addMessage(UserType.chatBot, botMessage, null);
    } else {
      print('Error al enviar el mensaje: ${response.statusCode}');
    }
  }
*/

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
        child: message.hasImage
            ? Column(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(message.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message.textContent,
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                ],
              )
            : Text(
                message.textContent,
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
      ),
    );
  }

  removeFile() {
    selectedImage = File('');
    isFileSelected = false;
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
