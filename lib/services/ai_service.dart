import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static const String _endpoint = 'chat/completions';

  final String apiKey;
  final String baseUrl;
  final String model;

  AIService({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
  });

  factory AIService.fromEnv() {
    return AIService(
      apiKey: dotenv.env['OPENAI_API_KEY'] ?? '',
      baseUrl: dotenv.env['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1',
      model: dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini',
    );
  }

  Future<String> generateResponse(String userMessage, {String? context}) async {
    if (apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    final systemPrompt = '''
You are STAR (Smart Technical Assistant & Responder), an advanced AI assistant. You are helpful, witty, and highly intelligent.
You have access to a vast knowledge base and can assist with any question or task.

Guidelines:
- Be concise but informative
- Use a professional yet friendly tone
- If you don't know something, admit it rather than making things up
- For complex topics, break down explanations clearly
- Always aim to be maximally helpful

${context != null ? 'Additional context: $context' : ''}
''';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$_endpoint'),
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

        // Handle specific quota exceeded error with user-friendly message
        if (errorMessage.contains('quota') ||
            errorMessage.contains('billing')) {
          throw Exception(
              'OpenAI API quota exceeded. Please check your OpenAI account billing and usage limits at https://platform.openai.com/account/billing');
        }

        throw Exception('API Error: $errorMessage');
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
    if (apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    final systemPrompt = '''
You are STAR (Smart Technical Assistant & Responder), an advanced AI assistant. You are helpful, witty, and highly intelligent.
You have access to a vast knowledge base and can assist with any question or task.

Guidelines:
- Be concise but informative
- Use a professional yet friendly tone
- Maintain context from previous messages
- If you don't know something, admit it rather than making things up
- For complex topics, break down explanations clearly
- Always aim to be maximally helpful
''';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...conversationHistory.map((msg) => {
            'role': msg['role'] == 'user' ? 'user' : 'assistant',
            'content': msg['content']
          }),
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$_endpoint'),
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

        // Handle specific quota exceeded error with user-friendly message
        if (errorMessage.contains('quota') ||
            errorMessage.contains('billing')) {
          throw Exception(
              'OpenAI API quota exceeded. Please check your OpenAI account billing and usage limits at https://platform.openai.com/account/billing');
        }

        throw Exception('API Error: $errorMessage');
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
