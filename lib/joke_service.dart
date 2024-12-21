import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class JokeService {
  final Dio _dio = Dio();
  static const String _cacheKey = 'cached_jokes';

  Future<List<dynamic>> fetchJokes() async {
    try {
      final response = await _dio.get(
        'https://v2.jokeapi.dev/joke/Any?amount=5',
      );

      if (response.statusCode == 200 && response.data != null) {
        final jokes = response.data['jokes'];
        await _cacheJokes(jokes);
        return jokes;
      } else {
        throw Exception('Failed to load jokes from API.');
      }
    } catch (e) {
      throw Exception('Error fetching jokes: $e');
    }
  }

  // Cache jokes in shared_preferences
  Future<void> _cacheJokes(List<dynamic> jokes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(jokes));
  }

  // Load cached jokes from shared_preferences
  Future<List<dynamic>> getCachedJokes() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);

    if (cachedData != null) {
      return jsonDecode(cachedData);
    } else {
      throw Exception('No cached jokes found.');
    }
  }
}
