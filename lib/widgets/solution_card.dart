import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';

class SolutionCard extends StatelessWidget {
  final String solution;

  const SolutionCard({super.key, required this.solution});

  List<Widget> _parseSolution(String input) {
    final List<Widget> widgets = [];
    final regex = RegExp(r'(\\\[.*?\\\]|\\\(.*?\\\))', dotAll: true);

    int lastEnd = 0;

    for (final match in regex.allMatches(input)) {
      if (match.start > lastEnd) {
        final plainText = input.substring(lastEnd, match.start).trim();
        if (plainText.isNotEmpty) widgets.add(_textWidget(plainText));
      }

      final matchText = match.group(0)!;
      final isDisplay = matchText.startsWith(r'\[');
      final math = matchText
          .replaceAll(r'\[', '')
          .replaceAll(r'\]', '')
          .replaceAll(r'\(', '')
          .replaceAll(r'\)', '')
          .trim();

      widgets.add(_latexWidget(math, isDisplay));
      lastEnd = match.end;
    }

    if (lastEnd < input.length) {
      final trailing = input.substring(lastEnd).trim();
      if (trailing.isNotEmpty) widgets.add(_textWidget(trailing));
    }

    return widgets;
  }

  Widget _textWidget(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.roboto(fontSize: 18, color: Colors.black87),
      ),
    );
  }

  Widget _latexWidget(String latex, bool display) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Math.tex(
          latex,
          textStyle: GoogleFonts.roboto(fontSize: 18, color: Colors.black87),
          mathStyle: display ? MathStyle.display : MathStyle.text,
          textScaleFactor: 1.2,
          onErrorFallback: (e) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "⚠️ Could not render LaTeX:",
                style: GoogleFonts.roboto(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                latex,
                style: GoogleFonts.roboto(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 6),
              Text(
                "Error: ${e.message}",
                style: GoogleFonts.roboto(fontSize: 14, color: Colors.red),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 20),
      elevation: theme.cardTheme.elevation ?? 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📘 Solution",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ..._parseSolution(solution),
          ],
        ),
      ),
    );
  }
}
