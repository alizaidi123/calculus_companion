// utils/pdf_generator.dart
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart'; // For getting directory paths
import 'package:open_file/open_file.dart'; // For opening the generated PDF

class PDFGenerator {
  /// Converts common LaTeX commands to a more readable plain text format.
  /// This is a best-effort conversion as the PDF package does not render LaTeX.
  static String _convertLatexToPlainText(String latex) {
    String text = latex;

    // --- Basic replacements ---
    text = text.replaceAll(r'\left(', '(').replaceAll(r'\right)', ')');
    text = text.replaceAll(r'\left[', '[').replaceAll(r'\right]', ']');
    text = text.replaceAll(r'\left\{', '{').replaceAll(r'\right\}', '}');
    text = text.replaceAll(r'\cdot', '*');
    text = text.replaceAll(r'\times', '*');
    text = text.replaceAll(r'\div', '/');
    text = text.replaceAll(r'\pm', '+/-');
    text = text.replaceAll(r'\approx', '~=');
    text = text.replaceAll(r'\neq', '!=');
    text = text.replaceAll(r'\le', '<=');
    text = text.replaceAll(r'\ge', '>=');
    text = text.replaceAll(r'\alpha', 'alpha');
    text = text.replaceAll(r'\beta', 'beta');
    text = text.replaceAll(r'\gamma', 'gamma');
    text = text.replaceAll(r'\theta', 'theta');
    text = text.replaceAll(r'\pi', 'pi');
    text = text.replaceAll(r'\phi', 'phi');
    text = text.replaceAll(r'\lambda', 'lambda');
    text = text.replaceAll(r'\mu', 'mu');
    text = text.replaceAll(r'\sigma', 'sigma');
    text = text.replaceAll(r'\delta', 'delta');
    text = text.replaceAll(r'\epsilon', 'epsilon');
    text = text.replaceAll(r'\infty', 'infinity');
    text = text.replaceAll(r'\partial', 'partial');
    text = text.replaceAll(r'\nabla', 'nabla');
    text = text.replaceAll(r'\emptyset', 'empty set');
    text = text.replaceAll(r'\in', 'in');
    text = text.replaceAll(r'\notin', 'not in');
    text = text.replaceAll(r'\subset', 'subset');
    text = text.replaceAll(r'\supset', 'supset');
    text = text.replaceAll(r'\subseteq', 'subset or equal');
    text = text.replaceAll(r'\supseteq', 'supset or equal');
    text = text.replaceAll(r'\cap', 'intersect');
    text = text.replaceAll(r'\cup', 'union');
    text = text.replaceAll(r'\setminus', 'minus');
    text = text.replaceAll(r'\forall', 'for all');
    text = text.replaceAll(r'\exists', 'exists');
    text = text.replaceAll(r'\neg', 'not');
    text = text.replaceAll(r'\land', 'and');
    text = text.replaceAll(r'\lor', 'or');
    text = text.replaceAll(r'\implies', 'implies');
    text = text.replaceAll(r'\iff', 'if and only if');
    text = text.replaceAll(r'\to', '->');
    text = text.replaceAll(r'\gets', '<-');
    text = text.replaceAll(r'\leftrightarrow', '<->');
    text = text.replaceAll(r'\quad', '    '); // Large space
    text = text.replaceAll(r'\;', ' '); // Medium space
    text = text.replaceAll(r'\,', ' '); // Small space
    text = text.replaceAll(r'\!', ''); // Negative space

    // --- Functions ---
    text = text.replaceAll(r'\sin', 'sin');
    text = text.replaceAll(r'\cos', 'cos');
    text = text.replaceAll(r'\tan', 'tan');
    text = text.replaceAll(r'\cot', 'cot');
    text = text.replaceAll(r'\sec', 'sec');
    text = text.replaceAll(r'\csc', 'csc');
    text = text.replaceAll(r'\arcsin', 'arcsin');
    text = text.replaceAll(r'\arccos', 'arccos');
    text = text.replaceAll(r'\arctan', 'arctan');
    text = text.replaceAll(r'\sinh', 'sinh');
    text = text.replaceAll(r'\cosh', 'cosh');
    text = text.replaceAll(r'\tanh', 'tanh');
    text = text.replaceAll(r'\log', 'log');
    text = text.replaceAll(r'\ln', 'ln');
    text = text.replaceAll(r'\exp', 'exp');
    text = text.replaceAll(r'\det', 'det');
    text = text.replaceAll(r'\lim', 'lim');
    text = text.replaceAll(r'\max', 'max');
    text = text.replaceAll(r'\min', 'min');
    text = text.replaceAll(r'\arg', 'arg');

    // --- Regex-based replacements ---
    // Fractions: \frac{numerator}{denominator} -> (numerator) / (denominator)
    text = text.replaceAllMapped(RegExp(r'\\frac\{([^{}]+)\}\{([^{}]+)\}'),
        (match) {
      return '(${match.group(1)}) / (${match.group(2)})';
    });

    // Square roots: \sqrt{expression} -> sqrt(expression)
    text = text.replaceAllMapped(RegExp(r'\\sqrt\{([^{}]+)\}'), (match) {
      return 'sqrt(${match.group(1)})';
    });

    // nth roots: \sqrt[n]{expression} -> nth_root(expression, n)
    text =
        text.replaceAllMapped(RegExp(r'\\sqrt\[(\d+)\]\{([^{}]+)\}'), (match) {
      return '${match.group(1)}_root(${match.group(2)})';
    });

    // Integrals: \int ... dx -> integral(...) dx
    // This is more complex as \int can have limits. For simplicity, we'll look for basic patterns.
    // This regex is a simplification and might not catch all integral forms.
    text =
        text.replaceAllMapped(RegExp(r'\\int\s*(.*?)\s*d([a-zA-Z])'), (match) {
      String integrand = match.group(1)!.trim();
      String differential = match.group(2)!;
      return 'integral(${integrand}) d${differential}';
    });

    // Summations: \sum_{i=start}^{end} expression -> sum(expression, i=start to end)
    text = text.replaceAllMapped(RegExp(r'\\sum_\{(.+?)\}\^\{(.+?)\}\s*(.*)'),
        (match) {
      String lower = match.group(1)!.trim();
      String upper = match.group(2)!.trim();
      String expression = match.group(3)!.trim();
      return 'sum(${expression}, ${lower} to ${upper})';
    });

    // Limits: \lim_{x\to a} f(x) -> lim(f(x), x->a)
    text = text.replaceAllMapped(RegExp(r'\\lim_\{(.*?)\}\s*(.*)'), (match) {
      String limitVar = match.group(1)!.trim();
      String expression = match.group(2)!.trim();
      return 'lim(${expression}, ${limitVar})';
    });

    // Derivatives: \frac{d}{dx}(f(x)) -> d/dx(f(x))
    text = text.replaceAllMapped(RegExp(r'\\frac\{d\}\{d([a-zA-Z])\}\((.*?)\)'),
        (match) {
      String variable = match.group(1)!;
      String function = match.group(2)!;
      return 'd/d${variable}(${function})';
    });
    text = text.replaceAllMapped(
        RegExp(r'\\frac\{d\^(\d+)\}\{d([a-zA-Z])\^(\d+)\}\((.*?)\)'), (match) {
      String order = match.group(1)!;
      String variable = match.group(2)!;
      String varOrder = match.group(3)!;
      String function = match.group(4)!;
      return 'd^${order}/d${variable}^${varOrder}(${function})';
    });

    // Remove any remaining backslashes that might be part of unhandled LaTeX commands
    text = text.replaceAll(r'\\', '');

    return text;
  }

  /// Saves the math problem and its solution as a PDF file.
  /// [problem]: The original math problem text.
  /// [solution]: The step-by-step solution, potentially in LaTeX format with [TEXT] tags.
  static Future<void> saveMathAsPDF({
    required String problem,
    required String solution,
  }) async {
    final pdf = pw.Document(); // Create a new PDF document

    // Function to parse the solution string and return a list of pw.Widget
    List<pw.Widget> _parseSolutionForPdf(String solutionText) {
      List<pw.Widget> widgets = [];
      List<String> lines = solutionText.split('\n');

      for (String line in lines) {
        line = line.trim();

        if (line.isEmpty) {
          continue;
        }

        // Check if the line is a plain text block
        if (line.startsWith('[TEXT]') && line.endsWith('[/TEXT]')) {
          String textContent = line.substring(6, line.length - 7).trim();
          if (textContent.isNotEmpty) {
            widgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5.0),
                child: pw.Text(
                  textContent,
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ),
            );
          }
        }
        // Check if the line is a LaTeX math block (assuming `\(` and `\)` delimiters)
        else if (line.startsWith('\\(') && line.endsWith('\\)')) {
          String latexContent = line.substring(2, line.length - 2).trim();
          if (latexContent.isNotEmpty) {
            // Convert LaTeX content to a more readable plain text format
            String readableLatex = _convertLatexToPlainText(latexContent);

            widgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5.0),
                child: pw.Text(
                  readableLatex, // Display the converted LaTeX content
                  style: const pw.TextStyle(
                    // Use standard font for better readability
                    fontSize: 16,
                    color: PdfColors.black,
                  ),
                ),
              ),
            );
          }
        }
        // Fallback for any lines that don't match the expected format
        else {
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5.0),
              child: pw.Text(
                line,
                style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey),
              ),
            ),
          );
        }
      }
      return widgets;
    }

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4, // Set page format to A4
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(30), // Padding around content
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start, // Align text to start
              children: [
                pw.Text(
                  "Math Problem:",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  problem,
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Solution:",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                // Render the parsed solution components for PDF
                ..._parseSolutionForPdf(solution),
              ],
            ),
          );
        },
      ),
    );

    try {
      // Get the application's temporary directory for saving the file
      final directory = await getTemporaryDirectory();
      // Define the file path for the PDF
      final file = File(
          "${directory.path}/math_solution_${DateTime.now().millisecondsSinceEpoch}.pdf");

      // Save the PDF document to the file
      await file.writeAsBytes(await pdf.save());

      // Open the generated PDF file
      await OpenFile.open(file.path);
    } catch (e) {
      print("Error saving or opening PDF: $e");
      throw Exception("Could not save or open PDF. Please check permissions.");
    }
  }
}
