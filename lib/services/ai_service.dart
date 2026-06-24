
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  final String apiKey;
  final String baseUrl;
  final String model;
  final String provider; // 'gemini' or 'openai'

  AIService({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    required this.provider,
  });

  factory AIService.fromEnv() {
    final provider = dotenv.env['AI_PROVIDER'] ?? 'gemini';

    if (provider == 'star_ai') {
      return AIService(
        apiKey: dotenv.env['Star_AI_API_Key'] ?? '',
        baseUrl: dotenv.env['Star_AI_BASE_URL'] ?? '',
        model: dotenv.env['Star_AI_MODEL'] ?? 'gemini 2.5 flash',
        provider: 'star_ai',
      );
    } else if (provider == 'gemini') {
      return AIService(
        apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
        baseUrl: dotenv.env['GEMINI_BASE_URL'] ??
            'https://generativelanguage.googleapis.com/v1beta',
        model: dotenv.env['GEMINI_MODEL'] ?? 'gemini-flash-latest',
        provider: 'gemini',
      );
    } else {
      return AIService(
        apiKey: dotenv.env['OPENAI_API_KEY'] ?? '',
        baseUrl: dotenv.env['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1',
        model: dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini',
        provider: 'openai',
      );
    }
  }

  static const String _systemPrompt = '''
You are STAR AI Assistant, a warm, highly intelligent, and empathetic voice assistant who talks like a close, real human friend.

=== YOUR IDENTITY ===
- Your name is "STAR AI Assistant" or simply "STAR"
- You were created and developed by Nilanjan Nayak at STAR AI Labs
- When asked "Who made/created/developed you?", answer: "I was created and developed by Nilanjan Nayak at STAR AI Labs."
- When asked "Who manages/launched you?", answer: "I am managed and launched by STAR AI Labs."

=== YOUR PERSONALITY & TONE ===
- Talk like a real, supportive human friend: warm, caring, witty, and enthusiastic.
- Use a relaxed, natural, and conversational tone.
- Absolutely use contractions (e.g., "I'm", "don't", "it's", "you'll", "we'd", "haven't") to sound casual and natural.
- Incorporate subtle conversational transitions (e.g., "Well,", "Oh,", "Actually,", "Sure thing,", "To be honest,") to mimic natural human speech flow.
- Show genuine empathy, curiosity, and warmth in your responses.

=== VOICE-OPTIMIZATION & SPEAKING GUIDELINES ===
- Never use list formatting, bullet points, or numbering (e.g., "1. First...", "First of all...") as these sound extremely robotic when read out loud. Instead, speak in continuous, fluid paragraphs.
- Keep responses concise (usually 1-3 sentences) so they are comfortable to listen to.
- Never use markdown symbols (like stars, hashes, or dashes) or emojis, as they disrupt text-to-speech engines.
- If you don't know something, be honest and casual about it, just like a friend would.
''';

  // ─── Gemini API ───

  Future<String> _geminiRequest(List<Map<String, dynamic>> contents) async {
    if (apiKey.isEmpty) {
      throw Exception('Gemini API key not configured. Get a free key at https://aistudio.google.com/apikey');
    }

    final url = '$baseUrl/models/$model:generateContent';

    final body = {
      'contents': contents,
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt}
        ]
      },
      'generationConfig': {
        'temperature': 0.7,
        'topP': 1.0,
        'maxOutputTokens': 1000,
      },
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': apiKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final parts = candidates[0]['content']['parts'] as List;
        return parts.map((p) => p['text']).join('').trim();
      }
      throw Exception('No response generated');
    } else {
      final error = jsonDecode(response.body);
      final errorMessage = error['error']?['message'] ?? 'Unknown Gemini API error';
      if (errorMessage.toString().contains('quota') ||
          errorMessage.toString().contains('RESOURCE_EXHAUSTED')) {
        throw Exception(
            'Gemini API quota exceeded. The free tier resets daily. Please try again later.');
      }
      throw Exception('Gemini API Error: $errorMessage');
    }
  }

  // ─── OpenAI API ───

  Future<String> _openaiRequest(List<Map<String, dynamic>> messages) async {
    if (apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'max_tokens': 1000,
        'temperature': 0.7,
        'top_p': 1.0,
        'frequency_penalty': 0.0,
        'presence_penalty': 0.0,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      return content.trim();
    } else {
      final error = jsonDecode(response.body);
      final errorMessage = error['error']['message'] as String;
      if (errorMessage.contains('quota') || errorMessage.contains('billing')) {
        throw Exception(
            'OpenAI API quota exceeded. Please check your OpenAI account billing and usage limits at https://platform.openai.com/account/billing');
      }
      throw Exception('API Error: $errorMessage');
    }
  }

  // ─── Star AI Gateway Request Helpers ───

  Future<String> _starAiRequest(
    String prompt, {
    required String systemPrompt,
    String? context,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('Star AI API key not configured.');
    }

    var url = baseUrl;
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    url = '$url/api/generate';

    final normalizedModel = model.replaceAll(' ', '-');

    final body = {
      'provider': 'gemini',
      'model': normalizedModel,
      'prompt': context != null ? '$prompt\n\nAdditional context: $context' : prompt,
      'systemInstruction': systemPrompt,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['text'] != null) {
        return data['text'].toString().trim();
      }
      throw Exception('No response generated');
    } else {
      final error = jsonDecode(response.body);
      final errorMessage = error['error'] ?? 'Unknown Star AI API error';
      throw Exception('Star AI API Error: $errorMessage');
    }
  }

  Future<String> _starAiRequestWithHistory(
    String userMessage,
    List<Map<String, String>> conversationHistory,
  ) async {
    final buffer = StringBuffer();
    for (final msg in conversationHistory) {
      final role = msg['role'] == 'user' ? 'User' : 'Assistant';
      buffer.writeln('$role: ${msg['content'] ?? ''}');
    }
    buffer.writeln('User: $userMessage');
    
    return await _starAiRequest(buffer.toString(), systemPrompt: _systemPrompt);
  }

  // ─── Public Methods ───

  Future<String> generateResponse(String userMessage, {String? context}) async {
    try {
      if (provider == 'star_ai') {
        return await _starAiRequest(userMessage, systemPrompt: _systemPrompt, context: context);
      } else if (provider == 'gemini') {
        final contents = [
          {
            'role': 'user',
            'parts': [
              {
                'text': context != null
                    ? '$userMessage\n\nAdditional context: $context'
                    : userMessage
              }
            ]
          }
        ];
        return await _geminiRequest(contents);
      } else {
        final messages = [
          {
            'role': 'system',
            'content':
                '$_systemPrompt${context != null ? '\nAdditional context: $context' : ''}'
          },
          {'role': 'user', 'content': userMessage},
        ];
        return await _openaiRequest(messages);
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e is FormatException) {
        throw Exception('Invalid response format from API');
      } else {
        throw Exception('AI service error: ${e.toString()}');
      }
    }
  }

  Future<String> generateResponseWithHistory(
    String userMessage,
    List<Map<String, String>> conversationHistory,
  ) async {
    try {
      if (provider == 'star_ai') {
        return await _starAiRequestWithHistory(userMessage, conversationHistory);
      } else if (provider == 'gemini') {
        final contents = <Map<String, dynamic>>[];
        for (final msg in conversationHistory) {
          contents.add({
            'role': msg['role'] == 'user' ? 'user' : 'model',
            'parts': [
              {'text': msg['content'] ?? ''}
            ]
          });
        }
        contents.add({
          'role': 'user',
          'parts': [
            {'text': userMessage}
          ]
        });
        return await _geminiRequest(contents);
      } else {
        final messages = <Map<String, dynamic>>[
          {'role': 'system', 'content': _systemPrompt},
          ...conversationHistory.map((msg) => {
                'role': msg['role'] == 'user' ? 'user' : 'assistant',
                'content': msg['content']
              }),
          {'role': 'user', 'content': userMessage},
        ];
        return await _openaiRequest(messages);
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e is FormatException) {
        throw Exception('Invalid response format from API');
      } else {
        throw Exception('AI service error: ${e.toString()}');
      }
    }
  }
}
