import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config.dart';
import '../models/diagnosis_result.dart';
import '../models/history_item.dart';
import '../models/issue.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? AppConfig.apiBaseUrl).replaceAll(RegExp(r'/$'), '');

  final http.Client _client;
  final String _baseUrl;

  static const Duration _diagnoseTimeout = Duration(seconds: 60);
  static const Duration _defaultTimeout = Duration(seconds: 20);

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$_baseUrl$path').replace(queryParameters: query);
  }

  Future<DiagnosisResult> diagnoseText({
    required String cropType,
    required String month,
    String? symptomDescription,
    String? location,
  }) async {
    try {
      final response = await _client
          .post(
            _uri('/diagnose'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'cropType': cropType,
              'month': month,
              'symptomDescription': symptomDescription ?? '',
              if (location != null && location.isNotEmpty) 'location': location,
            }),
          )
          .timeout(_diagnoseTimeout);
      return DiagnosisResult.fromJson(_decodeMap(response));
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        'The diagnosis is taking too long. Check your connection and try again.',
      );
    } on http.ClientException {
      throw ApiException(_networkMessage);
    } on FormatException {
      throw ApiException(
        "Couldn't get a clear diagnosis — please try again or add more detail.",
      );
    } catch (_) {
      throw ApiException(_networkMessage);
    }
  }

  Future<DiagnosisResult> diagnoseImage({
    required String cropType,
    required String month,
    String? symptomDescription,
    String? location,
    required Uint8List imageBytes,
    String filename = 'plant.jpg',
  }) async {
    try {
      final request = http.MultipartRequest('POST', _uri('/diagnose-image'));
      request.fields['cropType'] = cropType;
      request.fields['month'] = month;
      if (symptomDescription != null && symptomDescription.isNotEmpty) {
        request.fields['symptomDescription'] = symptomDescription;
      }
      if (location != null && location.isNotEmpty) {
        request.fields['location'] = location;
      }

      final lower = filename.toLowerCase();
      final isPng = lower.endsWith('.png');
      final safeName = isPng || lower.endsWith('.jpg') || lower.endsWith('.jpeg')
          ? filename
          : 'plant.jpg';

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: safeName,
          contentType: MediaType('image', isPng ? 'png' : 'jpeg'),
        ),
      );

      final streamed = await _client.send(request).timeout(_diagnoseTimeout);
      final response =
          await http.Response.fromStream(streamed).timeout(_diagnoseTimeout);
      return DiagnosisResult.fromJson(_decodeMap(response));
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        'The diagnosis is taking too long. Check your connection and try again.',
      );
    } on http.ClientException {
      throw ApiException(_networkMessage);
    } on FormatException {
      throw ApiException(
        "Couldn't get a clear diagnosis — please try again or add more detail.",
      );
    } catch (_) {
      throw ApiException(_networkMessage);
    }
  }

  Future<List<HistoryItem>> getHistory({int limit = 20}) async {
    try {
      final response = await _client
          .get(_uri('/history', {'limit': '$limit'}))
          .timeout(_defaultTimeout);
      final list = _decodeList(response);
      return list
          .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } on http.ClientException {
      throw ApiException(_networkMessage);
    } catch (_) {
      throw ApiException(_networkMessage);
    }
  }

  Future<List<IssueSummary>> getIssues() async {
    try {
      final response = await _client.get(_uri('/issues')).timeout(_defaultTimeout);
      final list = _decodeList(response);
      return list
          .map((e) => IssueSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } on http.ClientException {
      throw ApiException(_networkMessage);
    } catch (_) {
      throw ApiException(_networkMessage);
    }
  }

  Future<IssueDetail> getIssue(String id) async {
    try {
      final response =
          await _client.get(_uri('/issues/$id')).timeout(_defaultTimeout);
      return IssueDetail.fromJson(_decodeMap(response));
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } on http.ClientException {
      throw ApiException(_networkMessage);
    } catch (_) {
      throw ApiException(_networkMessage);
    }
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        "Couldn't get a clear diagnosis — please try again or add more detail.",
      );
    }
    return decoded;
  }

  List<dynamic> _decodeList(http.Response response) {
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw ApiException('Unexpected response from the server.');
    }
    return decoded;
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    String? detail;
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['detail'] != null) {
        final d = body['detail'];
        detail = d is String ? d : d.toString();
      }
    } catch (_) {}

    if (response.statusCode == 502) {
      throw ApiException(
        "Couldn't get a clear diagnosis — please try again or add more detail.",
        statusCode: 502,
      );
    }
    if (response.statusCode == 400) {
      throw ApiException(
        detail ?? 'Please check your input and try again.',
        statusCode: 400,
      );
    }
    if (response.statusCode >= 500) {
      throw ApiException(
        detail ?? 'The server had a problem. Please try again in a moment.',
        statusCode: response.statusCode,
      );
    }
    throw ApiException(
      detail ?? 'Request failed (${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }

  static const String _networkMessage =
      "Can't reach the orchard advisory server. Check that the backend is running and the API address is correct.";
}
