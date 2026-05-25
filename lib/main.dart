
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SeekNowApp());
}

class SeekNowApp extends StatelessWidget {
  const SeekNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeekNow Client',
      theme: ThemeData(useMaterial3: true),
      home: const SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final queryController = TextEditingController();
  final apiKeyController = TextEditingController();

  String result = "";
  bool loading = false;

  Future<void> search() async {
    setState(() {
      loading = true;
      result = "";
    });

    try {
      final response = await http.post(
        Uri.parse("https://see-know.eu/api/v1/search"),
        headers: {
          "Content-Type": "application/json",
          "X-API-Key": apiKeyController.text.trim(),
        },
        body: jsonEncode({
          "query": queryController.text.trim(),
          "limit": 25
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        result = const JsonEncoder.withIndent("  ").convert(data);
      });
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SeekNow Client")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: "API Key",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: queryController,
              decoration: const InputDecoration(
                labelText: "Search Query",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loading ? null : search,
              child: Text(loading ? "Searching..." : "Search"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(result),
              ),
            )
          ],
        ),
      ),
    );
  }
}
