import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static String? _staticApiKey;

  /// Initialize the service with an API key
  static void init(String apiKey) {
    _staticApiKey = apiKey;
  }

  /// Static method to generate text, as used in HomeScreen
  static Future<String> generateText(String prompt) async {
    final apiKey = _staticApiKey ?? 'AIzaSyAZu2a2p5vLsMgB5cDjgWzSJTEAsLLoLCE';
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.85,
          'maxOutputTokens': 512,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } else {
      throw Exception('Gemini API error: ${response.statusCode}');
    }
  }

  // Inject your API key here or load from env/secure storage
  final String _apiKey;

  GeminiService({required String apiKey}) : _apiKey = apiKey;

  /// Generate a personalised relationship tip based on user data.
  Future<String> generateRelationshipTip({
    required String userName,
    required int lustScore,
    required int emotionalScore,
    required int physicalScore,
  }) async {
    final prompt = '''
You are a warm, supportive relationship coach. Generate ONE concise, positive relationship tip 
(2-3 sentences max) for a couple. Personalise it based on:
- Name: $userName
- Lust Score: $lustScore/100
- Emotional Score: $emotionalScore/100
- Physical Score: $physicalScore/100

Focus on the lowest score area. Be encouraging and specific. No emojis in the tip itself.
''';
    return _generate(prompt);
  }

  /// Generate Truth or Dare prompts
  Future<List<String>> generateTruthOrDarePrompts({
    required String type,
    required int count,
    bool spicy = false,
  }) async {
    final intensity = spicy ? 'moderately spicy but tasteful' : 'fun and light';
    final prompt = '''
Generate $count $intensity "$type" prompts for a couple's Truth or Dare game.
Return ONLY a numbered list, one per line, no extra text.
Make them playful and relationship-building.
''';
    final raw = await _generate(prompt);
    return raw
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .map((l) => l.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
        .take(count)
        .toList();
  }

  /// Generate compatibility quiz questions
  Future<List<Map<String, dynamic>>> generateQuizQuestions(
      {required int count}) async {
    final prompt = '''
Create $count multiple-choice quiz questions a couple can answer about each other.
Format each as JSON: {"question": "...", "options": ["A", "B", "C", "D"]}
Return a JSON array only, no markdown or commentary.
''';
    final raw = await _generate(prompt);
    try {
      final cleaned = raw.replaceAll('```json', '').replaceAll('```', '').trim();
      final list = jsonDecode(cleaned) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Generate fantasy card prompts
  Future<List<String>> generateFantasyCards({required int count}) async {
    final prompt = '''
Generate $count romantic and sensual "Fantasy Card" scenarios for an adult couple.
Keep them tasteful but exciting. Return ONLY a numbered list, one per line.
''';
    final raw = await _generate(prompt);
    return raw
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .map((l) => l.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
        .take(count)
        .toList();
  }

  Future<String> _generate(String prompt) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.85,
          'maxOutputTokens': 512,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } else {
      throw Exception('Gemini API error: ${response.statusCode}');
    }
  }
}
