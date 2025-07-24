// lib/services/ocr_service.dart
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'; // ML Kit for text recognition

class OCRService {
  /// Extracts text from a given image file using Google ML Kit's Text Recognition.
  /// Returns the recognized text as a String.
  Future<String> extractText(File imageFile) async {
    // Create an InputImage from the image file
    final inputImage = InputImage.fromFile(imageFile);
    // Initialize TextRecognizer for Latin script
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      // Process the image to recognize text
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      // Return the full recognized text
      return recognizedText.text;
    } catch (e) {
      // Handle any errors during text recognition
      print("Error during OCR text extraction: $e");
      throw Exception("Failed to extract text from image using OCR.");
    } finally {
      // Close the text recognizer to release resources
      textRecognizer.close();
    }
  }
}
