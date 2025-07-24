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
    if (problem.isEmpty) {
      _showSnackBar("Please enter a problem to solve.");
      return;
    }

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
    } else {
      _showSnackBar("Image selection cancelled.");
    }
  }

  Future<void> _exportAsPDF() async {
    if (_solution.isEmpty) {
      _showSnackBar("No solution to export.");
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (pw.Context context) => pw.Padding(
        padding: const pw.EdgeInsets.all(25),
        child: pw.Text(_solution, style: const pw.TextStyle(fontSize: 16)),
      ),
    ));

    try {
      final output = await getTemporaryDirectory();
      final filePath = "${output.path}/CalculusCompanion_Solution.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      _showSnackBar("PDF exported successfully!");
    } catch (e) {
      _showSnackBar("Failed to export PDF.");
      print("PDF export error: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(20),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;
    final BorderRadius? inputBorderRadius =
        (inputDecorationTheme.border is OutlineInputBorder)
            ? (inputDecorationTheme.border as OutlineInputBorder).borderRadius
            : null;

    return Scaffold(
      // The body will now contain the gradient for the entire screen
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Theme.of(context).colorScheme.background, // F8F8F8
              Theme.of(context).colorScheme.background.withOpacity(0.95),
              Theme.of(context)
                  .colorScheme
                  .surface
                  .withOpacity(0.8), // A subtle blend to hint at depth
            ],
            stops: const [0.0, 0.7, 1.0], // Control the spread
            center: Alignment.topRight, // Origin of the gradient
            radius: 1.5, // Control the size of the gradient
          ),
        ),
        child: CustomScrollView(
          // Use CustomScrollView for AppBar and scrolling content
          slivers: [
            SliverAppBar(
              expandedHeight: 180.0, // More height for a hero effect
              floating: true, // App bar floats over content
              pinned: true, // App bar stays visible
              backgroundColor: Colors.transparent, // Allow gradient to show
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Calculus Companion",
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.9),
                        Theme.of(context).colorScheme.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      // Add subtle shadow for depth
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      decoration: BoxDecoration(
                        color: inputDecorationTheme.fillColor,
                        borderRadius:
                            inputBorderRadius ?? BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(
                                0.15), // Slightly more pronounced shadow
                            spreadRadius: 2,
                            blurRadius: 10, // Increased blur for softer look
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: 5,
                        minLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter your math problem here...',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          contentPadding: inputDecorationTheme.contentPadding,
                          hintStyle: inputDecorationTheme.hintStyle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25), // Increased space
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () =>
                              _solveImageProblem(ImageSource.gallery),
                          icon: const Icon(Icons.photo, color: Colors.white),
                          label: const Text('From Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _solveImageProblem(ImageSource.camera),
                          icon:
                              const Icon(Icons.camera_alt, color: Colors.white),
                          label: const Text('From Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _solveTextProblem,
                          icon:
                              const Icon(Icons.calculate, color: Colors.white),
                          label: const Text('Solve Text'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _solution.isNotEmpty ? _exportAsPDF : null,
                          icon: const Icon(Icons.picture_as_pdf,
                              color: Colors.white),
                          label: const Text('Save PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            elevation: 7,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 35), // More space before content area
                    AnimatedSwitcher(
                      duration: const Duration(
                          milliseconds: 500), // Smooth transition duration
                      child: _loading
                          ? Center(
                              key: const ValueKey(
                                  'loading'), // Key for AnimatedSwitcher
                              child: Column(
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary),
                                    strokeWidth: 5,
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    "Solving your problem...",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: Colors.grey.shade700,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : _solution.isNotEmpty
                              ? SolutionCard(
                                  key: const ValueKey('solution'),
                                  solution:
                                      _solution) // Key for AnimatedSwitcher
                              : Column(
                                  // Use a Column for the empty state
                                  key: const ValueKey(
                                      'empty'), // Key for AnimatedSwitcher
                                  children: [
                                    Icon(
                                      Icons
                                          .lightbulb_outline, // A relevant icon
                                      size: 80,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      "Enter a math problem or select an image to get started!",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ],
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
