import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/waste_recognition_result.dart';

class MissingOpenAiApiKeyException implements Exception {
  const MissingOpenAiApiKeyException();

  @override
  String toString() {
    return 'OPENAI_API_KEY가 설정되지 않았습니다.';
  }
}

class WasteAiService {
  WasteAiService({http.Client? client, String? apiKey, String? model})
    : _client = client ?? http.Client(),
      _apiKey =
          apiKey ??
          dotenv.env['OPENAI_API_KEY'] ??
          const String.fromEnvironment('OPENAI_API_KEY'),
      _model =
          model ??
          dotenv.env['OPENAI_MODEL'] ??
          const String.fromEnvironment(
            'OPENAI_MODEL',
            defaultValue: 'gpt-5.4-mini',
          );

  final http.Client _client;
  final String _apiKey;
  final String _model;

  static final Uri _responsesUri = Uri.parse(
    'https://api.openai.com/v1/responses',
  );

  Future<WasteRecognitionResult> recognizeWaste({
    required Uint8List imageBytes,
    required String mimeType,
    String? regionName,
    String? scheduleText,
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw const MissingOpenAiApiKeyException();
    }

    final response = await _client.post(
      _responsesUri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        _buildRequestBody(imageBytes, mimeType, regionName, scheduleText),
      ),
    );

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _extractApiError(decoded);
      throw Exception('AI 분석 요청 실패: $message');
    }

    if (_isIncomplete(decoded)) {
      throw Exception('AI 응답이 길이 제한 때문에 중간에 끊겼어요. 다시 촬영하거나 잠시 후 다시 시도해 주세요.');
    }

    final outputText = _extractOutputText(decoded);
    if (outputText == null || outputText.trim().isEmpty) {
      throw Exception('AI 응답에서 분석 결과를 찾지 못했습니다.');
    }

    final resultJson = _decodeResultJson(outputText);
    return WasteRecognitionResult.fromJson(resultJson);
  }

  Future<WasteRecognitionResult> searchWaste(
    String query, {
    String? regionName,
    String? scheduleText,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      throw Exception('검색어를 입력해 주세요.');
    }

    if (_apiKey.trim().isEmpty) {
      throw const MissingOpenAiApiKeyException();
    }

    final response = await _client.post(
      _responsesUri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        _buildSearchRequestBody(trimmedQuery, regionName, scheduleText),
      ),
    );

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _extractApiError(decoded);
      throw Exception('검색 요청 실패: $message');
    }

    if (_isIncomplete(decoded)) {
      throw Exception(
        'AI 응답이 길이 제한 때문에 중간에 끊겼어요. 검색어를 조금 더 구체적으로 바꿔 다시 시도해 주세요.',
      );
    }

    final outputText = _extractOutputText(decoded);
    if (outputText == null || outputText.trim().isEmpty) {
      throw Exception('검색 결과를 찾지 못했습니다.');
    }

    final resultJson = _decodeResultJson(outputText);
    return WasteRecognitionResult.fromJson(resultJson);
  }

  Map<String, dynamic> _buildRequestBody(
    Uint8List imageBytes,
    String mimeType,
    String? regionName,
    String? scheduleText,
  ) {
    final imageData = base64Encode(imageBytes);
    final safeMimeType = mimeType.trim().isEmpty ? 'image/jpeg' : mimeType;
    final regionText = _regionPromptText(regionName);
    final schedulePromptText = _schedulePromptText(scheduleText);

    return {
      'model': _model,
      'input': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_text',
              'text':
                  '''
사진 속 물건을 한국어로 식별하고 한국 기준의 분리배출 안내를 작성해 주세요.
$regionText
$schedulePromptText
사진에서 확실히 보이는 정보만 근거로 삼아 주세요.
브랜드명만 보이고 물건 종류가 불확실하면 objectName은 추정하지 말고 needsClarification을 true로 설정해 주세요.
배터리, 전자담배, 보조배터리처럼 화재 위험이 가능한 물건은 확실할 때만 유해폐기물로 분류해 주세요.
모든 문장은 짧게 작성하고 steps와 tips는 각각 최대 3개만 작성해 주세요.
응답은 지정된 JSON 스키마만 사용해 주세요.
''',
            },
            {
              'type': 'input_image',
              'image_url': 'data:$safeMimeType;base64,$imageData',
            },
          ],
        },
      ],
      'text': {
        'format': {
          'type': 'json_schema',
          'name': 'waste_recognition',
          'strict': true,
          'schema': {
            'type': 'object',
            'additionalProperties': false,
            'required': [
              'objectName',
              'material',
              'wasteCategory',
              'confidence',
              'needsClarification',
              'clarificationQuestion',
              'disposalMethod',
              'reason',
              'steps',
              'tips',
            ],
            'properties': {
              'objectName': {'type': 'string', 'maxLength': 40},
              'material': {'type': 'string', 'maxLength': 40},
              'wasteCategory': {
                'type': 'string',
                'enum': [
                  '일반쓰레기',
                  '재활용',
                  '음식물쓰레기',
                  '대형폐기물',
                  '유해폐기물',
                  '의류수거',
                  '기타',
                ],
              },
              'confidence': {'type': 'number', 'minimum': 0, 'maximum': 1},
              'needsClarification': {'type': 'boolean'},
              'clarificationQuestion': {'type': 'string', 'maxLength': 80},
              'disposalMethod': {'type': 'string', 'maxLength': 120},
              'reason': {'type': 'string', 'maxLength': 160},
              'steps': {
                'type': 'array',
                'maxItems': 3,
                'items': {'type': 'string', 'maxLength': 80},
              },
              'tips': {
                'type': 'array',
                'maxItems': 3,
                'items': {'type': 'string', 'maxLength': 80},
              },
            },
          },
        },
      },
      'max_output_tokens': 1600,
    };
  }

  Map<String, dynamic> _buildSearchRequestBody(
    String query,
    String? regionName,
    String? scheduleText,
  ) {
    final regionText = _regionPromptText(regionName);
    final schedulePromptText = _schedulePromptText(scheduleText);

    return {
      'model': _model,
      'input': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_text',
              'text':
                  '''
사용자가 버리는 방법을 검색했습니다.
검색어: "$query"
$regionText
$schedulePromptText

한국 기준의 일반적인 분리배출 방법을 안내해 주세요.
지역마다 기준이 다를 수 있으면 tips에 지역 확인 안내를 넣어 주세요.
오염 여부가 중요한 물건이면 needsClarification을 true로 설정하고 clarificationQuestion에 짧은 질문을 넣어 주세요.
모든 문장은 짧게 작성하고 steps와 tips는 각각 최대 3개만 작성해 주세요.
응답은 지정된 JSON 스키마만 사용해 주세요.
''',
            },
          ],
        },
      ],
      'text': {
        'format': {
          'type': 'json_schema',
          'name': 'waste_search',
          'strict': true,
          'schema': {
            'type': 'object',
            'additionalProperties': false,
            'required': [
              'objectName',
              'material',
              'wasteCategory',
              'confidence',
              'needsClarification',
              'clarificationQuestion',
              'disposalMethod',
              'reason',
              'steps',
              'tips',
            ],
            'properties': {
              'objectName': {'type': 'string', 'maxLength': 40},
              'material': {'type': 'string', 'maxLength': 40},
              'wasteCategory': {
                'type': 'string',
                'enum': [
                  '일반쓰레기',
                  '재활용',
                  '음식물쓰레기',
                  '대형폐기물',
                  '유해폐기물',
                  '의류수거',
                  '기타',
                ],
              },
              'confidence': {'type': 'number', 'minimum': 0, 'maximum': 1},
              'needsClarification': {'type': 'boolean'},
              'clarificationQuestion': {'type': 'string', 'maxLength': 80},
              'disposalMethod': {'type': 'string', 'maxLength': 120},
              'reason': {'type': 'string', 'maxLength': 160},
              'steps': {
                'type': 'array',
                'maxItems': 3,
                'items': {'type': 'string', 'maxLength': 80},
              },
              'tips': {
                'type': 'array',
                'maxItems': 3,
                'items': {'type': 'string', 'maxLength': 80},
              },
            },
          },
        },
      },
      'max_output_tokens': 1200,
    };
  }

  String _regionPromptText(String? regionName) {
    final trimmed = regionName?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return '사용자 지역은 설정되지 않았습니다.';
    }
    return '사용자 지역: $trimmed. 가능하면 이 지역의 배출 기준을 우선 반영하고, 확실하지 않으면 지역 확인이 필요하다고 안내해 주세요.';
  }

  String _schedulePromptText(String? scheduleText) {
    final trimmed = scheduleText?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return '사용자가 설정한 배출일 정보는 없습니다.';
    }
    return '사용자가 앱에서 직접 설정한 배출일 정보: $trimmed 이 배출일을 tips나 steps에 자연스럽게 반영해 주세요.';
  }

  Map<String, dynamic> _decodeResultJson(String outputText) {
    try {
      final resultJson = jsonDecode(outputText);
      if (resultJson is Map<String, dynamic>) {
        return resultJson;
      }
      throw Exception('AI 응답 형식이 올바르지 않습니다.');
    } on FormatException {
      throw Exception('AI 응답이 중간에 끊겨 JSON을 해석하지 못했어요. 다시 시도해 주세요.');
    }
  }

  bool _isIncomplete(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      return false;
    }

    final status = decoded['status'];
    if (status == 'incomplete') {
      return true;
    }

    final details = decoded['incomplete_details'];
    if (details is Map<String, dynamic>) {
      final reason = details['reason'];
      return reason == 'max_output_tokens';
    }

    return false;
  }

  String? _extractOutputText(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final direct = decoded['output_text'];
    if (direct is String) {
      return direct;
    }

    final output = decoded['output'];
    if (output is! List) {
      return null;
    }

    final parts = <String>[];
    for (final item in output) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final content = item['content'];
      if (content is! List) {
        continue;
      }
      for (final contentItem in content) {
        if (contentItem is Map<String, dynamic>) {
          final text = contentItem['text'];
          if (text is String) {
            parts.add(text);
          }
        }
      }
    }

    return parts.isEmpty ? null : parts.join();
  }

  String _extractApiError(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    }
    return '상태 코드가 올바르지 않습니다.';
  }
}
