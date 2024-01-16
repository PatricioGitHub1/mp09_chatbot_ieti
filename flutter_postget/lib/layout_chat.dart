import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
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

  @override
  Widget build(BuildContext context) {
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
                  child: ListView.builder(
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
                  Expanded(
                    child: CupertinoTextField(
                      controller: messageController,
                      placeholder: 'Type your message...',
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      if (messageController.text.isEmpty) {
                        return;
                      }
                      addMessage(UserType.human, messageController.text);
                      sendMessage(messageController.text);
                      messageController.clear();
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

  void addMessage(UserType owner, String textContent) {
    setState(() {
      mensajes.add(MessageBox.textOnly(owner: owner, textContent: textContent));
    });
  }

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
      addMessage(UserType.chatBot, botMessage);
    } else {
      print('Error al enviar el mensaje: ${response.statusCode}');
    }
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
          border: Border.all(
            width: 1.0
          ),
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
