// lib/services/openai_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY']!;

  /// Solves math problems from text input using GPT-4o
  Future<String> solveMathProblem(String problem) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4o", // ✅ unified model
        "messages": [
          {
            "role": "system",
            "content": "You are a helpful math tutor. Solve problems step-by-step using LaTeX. Wrap math in \\( and \\)."
          },
          {
            "role": "user",
            "content": "Solve this step-by-step in LaTeX format:\n$problem"
          }
        ],
        "temperature": 0.2,
        "max_tokens": 1000
      }),
    );

    if (response.statusCode != 200) {
      print("❌ GPT-4o (text) error ${response.statusCode}: ${response.body}");
      throw Exception("Failed to solve text query.");
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'].toString();
  }

  /// Solves math problems from base64-encoded image using GPT-4o
  Future<String> solveMathFromBase64(String base64Image) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4o", // ✅ use latest vision-enabled model
        "messages": [
          {
            "role": "system",
            "content": "You are a helpful math tutor. Solve the math problem in the image step-by-step using LaTeX. Use \\( and \\) to wrap equations for rendering."
          },
          {
            "role": "user",
            "content": [
              {
                "type": "image_url",
                "image_url": {
                  // optionally change jpeg → png if needed
                  "url": "data:image/jpeg;base64,$base64Image"
                }
              }
            ]
          }
        ],
        "temperature": 0.2,
        "max_tokens": 1500
      }),
    );

    if (response.statusCode != 200) {
      print("❌ GPT-4o (image) error ${response.statusCode}: ${response.body}");
      throw Exception("Failed to process image: ${response.body}");
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'].toString();
  }
}
