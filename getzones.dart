import 'dart:io';

import 'package:dio/dio.dart';

class CloudflareAPI {
  final String token;
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.cloudflare.com/client/v4',
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  CloudflareAPI(this.token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<List<Map<String, dynamic>>> listZones({
    int page = 1,
    int perPage = 20,
    String? name,
  }) async {
    try {
      final response = await dio.get(
        '/zones',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'order': 'name',
          'direction': 'asc',
          if (name != null) 'name': name,
        },
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['result']);
      } else {
        throw Exception('API request failed: ${response.data['errors']}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch zones: ${e.message}');
    }
  }
}

void main() async {
  // Get token from environment variable
  final token = Platform.environment['CF_TOKEN'];
  if (token == null) {
    print('Please set CF_TOKEN environment variable');
    exit(1);
  }

  final api = CloudflareAPI(token);

  try {
    final zones = await api.listZones();

    print('\nZone List:');
    print('-' * 50);

    for (final zone in zones) {
      print('Name: ${zone['name']}');
      print('ID: ${zone['id']}');
      print('Status: ${zone['status']}');
      print('Plan: ${zone['plan']['name']}');
      print('-' * 50);
    }

    // Print total count
    print('Total zones: ${zones.length}');
    exit(0);
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
