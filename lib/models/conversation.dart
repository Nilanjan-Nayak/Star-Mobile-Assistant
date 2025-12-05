class ConversationMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isProcessing;
  final String? error;

  ConversationMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isProcessing = false,
    this.error,
  });

  ConversationMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isProcessing,
    String? error,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
    );
  }

  factory ConversationMessage.user(String text) {
    return ConversationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory ConversationMessage.ai(String text) {
    return ConversationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  factory ConversationMessage.processing() {
    return ConversationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      isProcessing: true,
    );
  }

  factory ConversationMessage.error(String errorMessage) {
    return ConversationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      error: errorMessage,
    );
  }
}

class Conversation {
  final List<ConversationMessage> messages;

  Conversation({List<ConversationMessage>? messages})
      : messages = messages ?? [];

  Conversation addMessage(ConversationMessage message) {
    return Conversation(messages: [...messages, message]);
  }

  Conversation updateLastMessage(ConversationMessage updatedMessage) {
    if (messages.isEmpty) return this;

    final updatedMessages = List<ConversationMessage>.from(messages);
    updatedMessages[updatedMessages.length - 1] = updatedMessage;

    return Conversation(messages: updatedMessages);
  }

  Conversation clear() {
    return Conversation();
  }

  List<ConversationMessage> get recentMessages => messages.length > 10
      ? messages.sublist(messages.length - 10)
      : messages;

  bool get hasMessages => messages.isNotEmpty;
  bool get isProcessing => messages.isNotEmpty && messages.last.isProcessing;
  ConversationMessage? get lastMessage =>
      messages.isNotEmpty ? messages.last : null;
}
