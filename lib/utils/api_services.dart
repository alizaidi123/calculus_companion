// utils/api_services.dart
import 'dart:io';
import 'dart:convert'; // Import for base64Encode
// REMOVED: import '../services/ocr_service.dart'; // OCRService is no longer used for math images
import '../services/openai_service.dart'; // Ensure this path is correct

class ApiService {
  // REMOVED: final OCRService _ocrService = OCRService(); // OCRService instance removed
  final OpenAIService _openAIService = OpenAIService();

  /// Solves a math problem provided as text using the OpenAI service.
  /// Returns the step-by-step solution as a String.
  Future<String> getSolutionFromText(String problem) async {
    try {
      return await _openAIService.solveMathProblem(problem);
    } catch (e) {
      print("Error solving math problem from text: $e");
      throw Exception("Failed to get math solution from text.");
    }
  }

  /// Solves a math problem from an image using OpenAI's vision model.
  /// Returns the step-by-step solution as a String.
  Future<String> getSolutionFromImage(File imageFile) async {
    try {
      // Read the image file as bytes and then encode to Base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      return await _openAIService.solveMathFromBase64(base64Image);
    } catch (e) {
      print("Error solving math problem from image: $e");
      throw Exception(
          "Failed to get math solution from image. Please try again.");
    }
  }
}
