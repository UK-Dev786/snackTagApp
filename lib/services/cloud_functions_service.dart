import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudFunctionsService {
  // Replace with your actual Firebase Functions URL
  // static const String _baseUrl = 'https://us-central1-snacktag-app.cloudfunctions.net';
  static const String _baseUrl = 'https://app-2ez2tbzmhq-uc.a.run.app';

  // Singleton pattern
  static final CloudFunctionsService _instance =
      CloudFunctionsService._internal();
  factory CloudFunctionsService() => _instance;
  CloudFunctionsService._internal();

  // Simple logging method
  void _log(String message) {
    debugPrint('CloudFunctionsService: $message');
  }

  Future<void> sendFCM({
    required List<String> tokens,
    required String title,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sendFCM'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tokens': tokens,
          'title': title,
          'msg': message,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send FCM: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM: $e');
      rethrow;
    }
  }

  Future<String> getStripeConnectionToken() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/connection_token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get connection token: ${response.body}');
      }

      final data = jsonDecode(response.body);
      return data['secret'];
    } catch (e) {
      print('Error getting connection token: $e');
      rethrow;
    }
  }

  Future<dynamic> callFunction(
      String functionName, Map<String, dynamic> data) async {
    try {
      _log('Calling function $functionName with data: $data');
      _log('URL: $_baseUrl/$functionName');

      final response = await http.post(
        Uri.parse('$_baseUrl/$functionName'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      _log('Response status code: ${response.statusCode}');
      _log('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Function call failed: ${response.body}');
      }

      try {
        return jsonDecode(response.body);
      } catch (e) {
        _log('Error decoding JSON: $e');
        throw Exception('Invalid response format: ${response.body}');
      }
    } catch (e) {
      _log('Error calling function $functionName: $e');
      throw Exception('Failed to call function $functionName: $e');
    }
  }
}
