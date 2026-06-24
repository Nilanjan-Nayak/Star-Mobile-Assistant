import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/text_formatter.dart';

class TTSController extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isInitialized = false;

  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;

  TTSController() {
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.52); // Slightly faster for natural speaking rhythm
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);

      // Dynamically select a high-quality premium/neural/natural voice if available
      try {
        final List<dynamic>? voices = await _flutterTts.getVoices;
        if (voices != null && voices.isNotEmpty) {
          String? selectedVoiceName;
          String? selectedVoiceLocale;
          
          // Priority keywords for natural sounding voices
          final priorityKeywords = ['neural', 'natural', 'google', 'wavenet'];
          
          for (final keyword in priorityKeywords) {
            for (final voice in voices) {
              if (voice is Map) {
                final String name = (voice['name'] ?? '').toString().toLowerCase();
                final String locale = (voice['locale'] ?? '').toString().toLowerCase();
                
                if ((locale.contains('en-us') || locale.contains('en-gb')) && name.contains(keyword)) {
                  selectedVoiceName = voice['name']?.toString();
                  selectedVoiceLocale = voice['locale']?.toString();
                  break;
                }
              }
            }
            if (selectedVoiceName != null) break;
          }
          
          // Fallback to any en-US voice
          if (selectedVoiceName == null) {
            for (final voice in voices) {
              if (voice is Map) {
                final String locale = (voice['locale'] ?? '').toString().toLowerCase();
                if (locale.contains('en-us')) {
                  selectedVoiceName = voice['name']?.toString();
                  selectedVoiceLocale = voice['locale']?.toString();
                  break;
                }
              }
            }
          }
          
          if (selectedVoiceName != null && selectedVoiceLocale != null) {
            await _flutterTts.setVoice({"name": selectedVoiceName, "locale": selectedVoiceLocale});
            debugPrint("Selected Premium Voice: $selectedVoiceName ($selectedVoiceLocale)");
          }
        }
      } catch (e) {
        debugPrint("Error fetching/setting high-quality voice: $e");
      }

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint("TTS Error: $msg");
        notifyListeners();
      });

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint("TTS Initialization Error: $e");
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      debugPrint("TTS not initialized");
      return;
    }

    if (_isSpeaking) {
      await stop();
    }

    try {
      // Clean text for better pronunciation
      final cleanedText = TextFormatter.cleanForTTS(text);
      await _flutterTts.speak(cleanedText);
    } catch (e) {
      debugPrint("TTS Speak Error: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      debugPrint("TTS Stop Error: $e");
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      debugPrint("TTS Pause Error: $e");
    }
  }

  Future<void> resume() async {
    try {
      // Resume is not available in flutter_tts, so we'll restart speaking
      // This is a limitation of the current TTS implementation
      debugPrint("Resume not supported, use speak() instead");
    } catch (e) {
      debugPrint("TTS Resume Error: $e");
    }
  }

  Future<List<String>> getLanguages() async {
    try {
      return await _flutterTts.getLanguages;
    } catch (e) {
      debugPrint("TTS Get Languages Error: $e");
      return [];
    }
  }

  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
    } catch (e) {
      debugPrint("TTS Set Language Error: $e");
    }
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      debugPrint("TTS Set Speech Rate Error: $e");
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume);
    } catch (e) {
      debugPrint("TTS Set Volume Error: $e");
    }
  }

  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
    } catch (e) {
      debugPrint("TTS Set Pitch Error: $e");
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
