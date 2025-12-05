
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/conversation.dart';
import '../services/ai_service.dart';
import '../utils/text_formatter.dart';
import 'tts_controller.dart';

class SpeechController extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final AIService _aiService = AIService.fromEnv();
  final TTSController _ttsController;

  bool _speechEnabled = false;
  String _lastWords = '';
  Conversation _conversation = Conversation();
  bool _isProcessingAI = false;

  // Getter Methods
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;
  bool get isListening => _speechToText.isListening;
  Conversation get conversation => _conversation;
  bool get isProcessingAI => _isProcessingAI;
  TTSController get ttsController => _ttsController;

  SpeechController(this._ttsController) {
    _initSpeech();
  }

  Future _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          debugPrint("Speech status: $status");
          if (status == 'done' || status == 'notListening') {
            // Don't automatically process speech to AI - wait for user confirmation
            // _processSpeechToAI();
          }
        },
      );
    } catch (e) {
      debugPrint("Error in initialization $e");
    }

    notifyListeners();
  }

  // Start Method
  Future<void> startListening() async {
    if (!_speechEnabled) {
      debugPrint("Speech not enabled, attempting to initialize...");
      await _initSpeech();
      if (!_speechEnabled) {
        debugPrint("Speech recognition unavailable.");
        return;
      }
    }

    // Check if already listening to prevent duplicate starts
    if (_speechToText.isListening) {
      debugPrint("Speech recognition already listening, skipping start");
      return;
    }

    _lastWords = "";
    notifyListeners();

    try {
      await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          notifyListeners();

          if (result.finalResult) {
            notifyListeners();
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      );
    } catch (e) {
      debugPrint("Error starting speech recognition: $e");
      _isProcessingAI = false;
      notifyListeners();
    }
    
    // Wait a moment for isListening to become true
    await Future.delayed(const Duration(milliseconds: 100));
    notifyListeners();
  }

  // Stop Method
  void stopListening() async {
    await _speechToText.stop();
    // Process the speech to AI after stopping
    _processSpeechToAI();
    notifyListeners();
  }

  // Process speech input and get AI response
  Future<void> _processSpeechToAI() async {
    if (_lastWords.trim().isEmpty) return;

    // Add user message to conversation
    final userMessage = ConversationMessage.user(_lastWords.trim());
    _conversation = _conversation.addMessage(userMessage);
    notifyListeners();

    // Add processing message
    final processingMessage = ConversationMessage.processing();
    _conversation = _conversation.addMessage(processingMessage);
    _isProcessingAI = true;
    notifyListeners();

    try {
      // Get conversation history for context
      final history = _conversation.recentMessages
          .where((msg) => !msg.isProcessing && msg.error == null)
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.text
              })
          .toList();

      // Generate AI response
      final aiResponse = await _aiService.generateResponseWithHistory(
        _lastWords.trim(),
        history,
      );

      // Replace processing message with actual response
      final aiMessage = ConversationMessage.ai(aiResponse);
      _conversation = _conversation.updateLastMessage(aiMessage);
      _isProcessingAI = false;
      notifyListeners();

      // Auto speak the response with cleaned text for better pronunciation
      final cleanedText = TextFormatter.cleanForTTS(aiResponse);
      await _ttsController.speak(cleanedText);
      
      // Wait for speaking to start (give it a moment)
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Wait while speaking
      while (_ttsController.isSpeaking) {
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Add a small delay before restarting listening
      await Future.delayed(const Duration(milliseconds: 500));
      // Restart listening for continuous conversation
      await startListening();

    } catch (e) {
      debugPrint("AI Processing Error: $e");

      // Replace processing message with error message
      final errorMessage = ConversationMessage.error(e.toString());
      _conversation = _conversation.updateLastMessage(errorMessage);
      _isProcessingAI = false;
      notifyListeners();
    }
  }

  // Clear conversation history
  void clearConversation() {
    _conversation = Conversation();
    _lastWords = '';
    notifyListeners();
  }

  // Retry last failed message
  Future<void> retryLastMessage() async {
    if (_conversation.messages.isEmpty) return;

    final lastUserMessage = _conversation.messages
        .lastWhere((msg) => msg.isUser);

    if (lastUserMessage != null) {
      // Remove any error or processing messages at the end
      while (_conversation.messages.isNotEmpty &&
             (_conversation.messages.last.isProcessing ||
              _conversation.messages.last.error != null)) {
        final updatedMessages = List<ConversationMessage>.from(_conversation.messages)
          ..removeLast();
        _conversation = Conversation(messages: updatedMessages);
      }

      // Reprocess the last user message
      _lastWords = lastUserMessage.text;
      await _processSpeechToAI();
    }
  }
}
