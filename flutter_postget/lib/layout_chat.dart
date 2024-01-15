import 'package:flutter/cupertino.dart';
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
  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width  * 0.8;

    if (windowWidth < 350) {
      windowWidth = MediaQuery.of(context).size.width;
    }

    List<MessageBox> mensajes = [];
    mensajes.add(MessageBox.textOnly(owner: UserType.chatBot, textContent: "Welcome to IETI ChatBot!"));
    mensajes.add(MessageBox.textOnly(owner: UserType.chatBot, textContent: "Feel free to ask me anything"));
    mensajes.add(MessageBox.textOnly(owner: UserType.human, textContent: "OK I WILL"));

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.title),
        ),
        child: Center(child: Container(
          width: windowWidth,
          height: windowHeight,
          color: CupertinoColors.white,
          child: CupertinoScrollbar(
            child: ListView.builder(
              itemCount: mensajes.length,
              itemBuilder: (context, index) {
                return buildMessageItem(mensajes[index]);
              },
            ),
          ),) 
    ));
  }

  Widget buildMessageItem(MessageBox message) {
    double txtBubbleWidth = windowWidth * 0.45;
    if (txtBubbleWidth < 350) {
      txtBubbleWidth = windowWidth * 0.90;
    }
    return Align(
      alignment: message.owner == UserType.chatBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: txtBubbleWidth,
        color: message.owner == UserType.chatBot ? CupertinoColors.activeBlue : CupertinoColors.activeGreen,
        child: Text(
        message.textContent,
        style: CupertinoTheme.of(context).textTheme.textStyle,
      ),
      ),
    );
    
  }
}
