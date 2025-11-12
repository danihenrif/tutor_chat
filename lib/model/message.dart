enum SenderType {
  user,
  bot,
}

class Message{
  final String creationDate;
  final String message;
  final SenderType sender;

  Message({
    required this.creationDate,
    required this.message,
    required this.sender
  });
}


