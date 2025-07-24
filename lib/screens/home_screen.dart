// lib/screens/home_screen.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../services/openai_service.dart';
import '../widgets/solution_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  String _solution = '';
  bool _loading = false;

  final OpenAIService _openAIService = OpenAIService();

  Future<void> _solveTextProblem() async {
    final problem = _textController.text.trim();
    if (problem.isEmpty) return;

    setState(() => _loading = true);
    try {
      final solution = await _openAIService.solveMathProblem(problem);
      setState(() {
        _solution = solution;
        _loading = false;
      });
      _showSnackBar("✅ Solution generated from text.");
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar("❌ Failed to solve from text.");
      print("Text solve error: $e");
    }
  }

  Future<void> _solveImageProblem(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: source);
    if (file != null) {
      setState(() => _loading = true);
      try {
        final bytes = await File(file.path).readAsBytes();
        final base64Image = base64Encode(bytes);
        final solution = await _openAIService.solveMathFromBase64(base64Image);
        setState(() {
          _solution = solution;
          _loading = false;
        });
        _showSnackBar("✅ Solution generated from image.");
      } catch (e) {
        setState(() => _loading = false);
        _showSnackBar("❌ Failed to solve from image.");
        print("Image solve error: $e");
      }
    }
  }

  Future<void> _exportAsPDF() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (pw.Context context) => pw.Padding(
        padding: const pw.EdgeInsets.all(20),
        child: pw.Text(_solution, style: const pw.TextStyle(fontSize: 14)),
      ),
    ));

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/solution.pdf");
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EDF9),
      appBar: AppBar(
        title: const Text("Calculus Companion"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Enter a math problem...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _solveImageProblem(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text('From Gallery'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _solveImageProblem(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('From Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: _solveTextProblem,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Solve Text'),
                ),
                ElevatedButton.icon(
                  onPressed: _solution.isNotEmpty ? _exportAsPDF : null,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Save PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade200,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_loading)
              const CircularProgressIndicator()
            else if (_solution.isNotEmpty)
              SolutionCard(solution: _solution),
          ],
        ),
      ),
    );
  }
}
