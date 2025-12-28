import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AirtableService {
  final String apiKey = dotenv.env['AIRTABLE_API_KEY'] ?? '';
  final String baseId = dotenv.env['AIRTABLE_BASE_ID'] ?? '';
  final String tableName = dotenv.env['AIRTABLE_TABLE_NAME'] ?? '';

  Future<List<Map<String, dynamic>>> fetchComputerModels() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('computer_models_cache');
    final lastFetchTime = prefs.getInt('computer_models_last_fetch_time') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Check if cache is valid (less than 24 hours old)
    if (cachedData != null && (currentTime - lastFetchTime) < 24 * 60 * 60 * 1000) {
      print('Using cached computer models');
      final List<dynamic> decodedData = json.decode(cachedData);
      return decodedData.cast<Map<String, dynamic>>();
    }

    print('Fetching computer models from Airtable API');
    final url = Uri.parse('https://api.airtable.com/v0/$baseId/$tableName');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> records = data['records'];

        final List<Map<String, dynamic>> models = records.map((record) {
          final fields = record['fields'];
          return {
            'key': fields['שם מוצר'] ?? 'Unknown',
            'price': fields['מחיר'] ?? 0,
            'id': record['id'],
          };
        }).toList();

        // Save to cache
        await prefs.setString('computer_models_cache', json.encode(models));
        await prefs.setInt('computer_models_last_fetch_time', currentTime);

        return models;
      } else {
        print('Failed to fetch data from Airtable: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching data from Airtable: $e');
      return [];
    }
  }
}
