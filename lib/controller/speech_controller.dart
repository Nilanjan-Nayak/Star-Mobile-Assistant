import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/conversation.dart';
import '../services/ai_service.dart';
import '../utils/text_formatter.dart';
import 'tts_controller.dart';

/// Professional Speech Controller with Auto-Conversation Flow
///
/// Features:
/// - Auto-stop when user finishes speaking (after 2 seconds of silence)
/// - Auto-send text to AI after speech ends
/// - Auto-start listening when AI finishes speaking
/// - Seamless continuous conversation loop
class SpeechController extends ChangeNotifier {
  Timer? _silenceTimer;
  final SpeechToText _speechToText = SpeechToText();
  final AIService _aiService = AIService.fromEnv();
  final TTSController _ttsController;

  bool _speechEnabled = false;
  String _lastWords = '';
  Conversation _conversation = Conversation();
  bool _isProcessingAI = false;
  bool _autoConversationMode = true; // Enable auto conversation by default
  bool _isExpectingSpeechResult = false;

  // Getter Methods
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;
  bool get isListening => _speechToText.isListening;
  Conversation get conversation => _conversation;
  bool get isProcessingAI => _isProcessingAI;
  TTSController get ttsController => _ttsController;
  bool get autoConversationMode => _autoConversationMode;

  SpeechController(this._ttsController) {
    _initSpeech();
  }

  /// Toggle auto conversation mode
  void toggleAutoConversation() {
    _autoConversationMode = !_autoConversationMode;
    notifyListeners();
  }

  /// Initialize speech recognition
  Future _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          debugPrint("🎤 Speech status: $status");
          notifyListeners();
        },
        onError: (error) {
          debugPrint("🎤 Speech error: ${error.errorMsg}");
        },
      );
      debugPrint("🎤 Speech initialized: $_speechEnabled");
    } catch (e) {
      debugPrint("❌ Error in speech initialization: $e");
    }

    notifyListeners();
  }

  /// Start listening for speech input
  Future<void> startListening() async {
    if (!_speechEnabled) {
      debugPrint("🎤 Speech not enabled, attempting to initialize...");
      await _initSpeech();
      if (!_speechEnabled) {
        debugPrint("❌ Speech recognition unavailable.");
        return;
      }
    }

    // Check if already listening to prevent duplicate starts
    if (_speechToText.isListening) {
      debugPrint("🎤 Already listening, skipping start");
      return;
    }

    // Don't start if TTS is still speaking
    if (_ttsController.isSpeaking) {
      debugPrint("🔊 TTS still speaking, waiting...");
      return;
    }

    _lastWords = "";
    _isExpectingSpeechResult = true;
    notifyListeners();

    debugPrint("🎤 Starting to listen...");

    try {
      // Cancel any existing silence timer
      _silenceTimer?.cancel();

      await _speechToText.listen(
        onResult: (result) {
          if (!_isExpectingSpeechResult) {
            debugPrint("🎤 Late speech result received, ignoring");
            return;
          }
          if (_isProcessingAI || _ttsController.isSpeaking) {
            debugPrint("🎤 Speech result received while processing/speaking, ignoring");
            _isExpectingSpeechResult = false;
            return;
          }
          _lastWords = result.recognizedWords;
          notifyListeners();

          // Reset silence timer on every result
          _silenceTimer?.cancel();

          // Only start timer if we have some words
          if (_lastWords.trim().isNotEmpty) {
            _silenceTimer = Timer(const Duration(milliseconds: 2500), () {
              debugPrint("⏳ Silence detected (manual timer), stopping...");
              if (_speechToText.isListening) {
                _stopAndProcess();
              } else {
                _processSpeechToAI();
              }
            });
          }

          // Fallback: If engine says final result, we still wait for our timer usually,
          // but if it's final, the engine stopped listening.
          if (result.finalResult && _lastWords.trim().isNotEmpty) {
            debugPrint("✅ Engine reported final result");
            _isExpectingSpeechResult = false;
            _silenceTimer?.cancel();
            _processSpeechToAI();
          }
        },
        // Listen for up to 2 minutes
        listenFor: const Duration(seconds: 120),
        // Increase engine pause detection to 5 seconds (we handle silence manually)
        pauseFor: const Duration(seconds: 5),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
          autoPunctuation: true,
        ),
      );
    } catch (e) {
      debugPrint("❌ Error starting speech recognition: $e");
      _isProcessingAI = false;
      _isExpectingSpeechResult = false;
      notifyListeners();
    }

    // Wait a moment for isListening to become true
    await Future.delayed(const Duration(milliseconds: 100));
    notifyListeners();
  }

  /// Internal method to stop and process speech
  Future<void> _stopAndProcess() async {
    _isExpectingSpeechResult = false;
    _silenceTimer?.cancel();
    _silenceTimer = null;
    await _speechToText.stop();
    await _processSpeechToAI();
    notifyListeners();
  }

  /// Stop listening and send to AI
  void stopListening() async {
    debugPrint("🛑 Stopping listening...");
    _isExpectingSpeechResult = false;
    _silenceTimer?.cancel();
    _silenceTimer = null;
    await _speechToText.stop();
    _processSpeechToAI();
    notifyListeners();
  }

  /// Cancel listening without processing
  void cancelListening() async {
    debugPrint("❌ Cancelling listening...");
    _isExpectingSpeechResult = false;
    _silenceTimer?.cancel();
    await _speechToText.cancel();
    _lastWords = '';
    notifyListeners();
  }

  /// Stop the entire conversation loop
  void stopConversation() {
    debugPrint("🛑 Stopping conversation loop...");
    _isExpectingSpeechResult = false;
    _silenceTimer?.cancel();
    _ttsController.stop();
    stopListening();
    _isProcessingAI = false;
    notifyListeners();
  }

  /// Process speech input and get AI response
  Future<void> _processSpeechToAI() async {
    // Prevent double processing
    if (_isProcessingAI) {
      debugPrint("⚠️ Already processing AI, skipping duplicate request");
      return;
    }

    _isExpectingSpeechResult = false;

    final words = _lastWords.trim();
    if (words.isEmpty) {
      debugPrint("⚠️ No speech detected, skipping AI processing");
      return;
    }

    // Immediately cancel timer and clear lastWords to prevent duplicate runs / race conditions
    _silenceTimer?.cancel();
    _silenceTimer = null;
    _lastWords = '';

    debugPrint("🤖 Processing speech: '$words'");

    // Add user message to conversation
    final userMessage = ConversationMessage.user(words);
    _conversation = _conversation.addMessage(userMessage);
    notifyListeners();

    // Add processing message
    final processingMessage = ConversationMessage.processing();
    _conversation = _conversation.addMessage(processingMessage);
    _isProcessingAI = true;
    notifyListeners();

    try {
      // Get conversation history for context, excluding the last user message we just added
      final historyMessages = _conversation.recentMessages
          .where((msg) => !msg.isProcessing && msg.error == null)
          .toList();
      
      if (historyMessages.isNotEmpty) {
        historyMessages.removeLast(); // Remove the current user message
      }

      final history = historyMessages
          .map((msg) =>
              {'role': msg.isUser ? 'user' : 'assistant', 'content': msg.text})
          .toList();

      // Generate AI response
      debugPrint("🤖 Generating AI response...");
      final aiResponse = await _aiService.generateResponseWithHistory(
        words,
        history,
      );

      debugPrint(
          "🤖 AI Response received: ${aiResponse.substring(0, aiResponse.length.clamp(0, 50))}...");

      // Replace processing message with actual response
      final aiMessage = ConversationMessage.ai(aiResponse);
      _conversation = _conversation.updateLastMessage(aiMessage);
      _isProcessingAI = false;
      notifyListeners();

      // Clear last words for next input
      _lastWords = '';

      // Check if conversation was stopped during processing
      if (!_autoConversationMode) return;

      // AUTO-SPEAK: Speak the AI response
      debugPrint("🔊 Speaking AI response...");
      final cleanedText = TextFormatter.cleanForTTS(aiResponse);
      await _ttsController.speak(cleanedText);

      // Wait for TTS to start
      await Future.delayed(const Duration(milliseconds: 300));

      // Wait while TTS is speaking
      debugPrint("⏳ Waiting for TTS to complete...");
      while (_ttsController.isSpeaking) {
        await Future.delayed(const Duration(milliseconds: 100));
        // Check if stopped during TTS
        if (!_ttsController.isSpeaking) break;
      }

      debugPrint("✅ TTS completed");

      // AUTO-LISTEN: If auto-conversation is enabled AND TTS finished naturally, start listening again
      // We check isSpeaking to ensure it wasn't manually stopped
      if (_autoConversationMode && !_ttsController.isSpeaking) {
        // Small delay before restarting (feels more natural)
        await Future.delayed(const Duration(milliseconds: 600));
        debugPrint("🎤 Auto-restarting listening...");
        await startListening();
      }
    } catch (e) {
      debugPrint("❌ AI Processing Error: $e");

      // Replace processing message with error message
      final errorMessage = ConversationMessage.error(e.toString());
      _conversation = _conversation.updateLastMessage(errorMessage);
      _isProcessingAI = false;
      notifyListeners();
    }
  }

  /// Clear conversation history
  void clearConversation() {
    _conversation = Conversation();
    _lastWords = '';
    notifyListeners();
  }

  /// Send a text message directly to the AI (from suggested prompts)
  Future<void> sendTextMessage(String text) async {
    _lastWords = text;
    await _processSpeechToAI();
  }


  /// Retry last failed message
  Future<void> retryLastMessage() async {
    if (_conversation.messages.isEmpty) return;

    final userMessages = _conversation.messages.where((msg) => msg.isUser);
    if (userMessages.isEmpty) return;

    final lastUserMessage = userMessages.last;

    // Remove any error or processing messages at the end
    while (_conversation.messages.isNotEmpty &&
        (_conversation.messages.last.isProcessing ||
            _conversation.messages.last.error != null)) {
      final updatedMessages =
          List<ConversationMessage>.from(_conversation.messages)..removeLast();
      _conversation = Conversation(messages: updatedMessages);
    }

    // Reprocess the last user message
    _lastWords = lastUserMessage.text;
    await _processSpeechToAI();
  }
}
