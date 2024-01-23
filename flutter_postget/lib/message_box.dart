import 'dart:io';

enum UserType {
  chatBot,
  human,
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
