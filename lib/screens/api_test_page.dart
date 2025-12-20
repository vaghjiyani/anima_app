import 'package:flutter/material.dart';
import '../services/jikan_api_service.dart';

// Quick test page to verify API is working
class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  String _status = 'Not tested';

  Future<void> _testApi() async {
    setState(() => _status = 'Testing...');

    try {
      final anime = await JikanApiService.getTopAnime(page: 1, limit: 5);
      setState(
        () => _status =
            'SUCCESS! Got ${anime.length} anime:\n${anime.map((a) => a.displayTitle).join('\n')}',
      );
    } catch (e) {
      setState(() => _status = 'ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _testApi,
                child: const Text('Test Top Anime API'),
              ),
              const SizedBox(height: 20),
              Text(_status, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
