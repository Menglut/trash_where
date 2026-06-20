class WasteRecognitionResult {
  final String objectName;
  final String material;
  final String wasteCategory;
  final double confidence;
  final bool needsClarification;
  final String clarificationQuestion;
  final String disposalMethod;
  final String reason;
  final List<String> steps;
  final List<String> tips;

  const WasteRecognitionResult({
    required this.objectName,
    required this.material,
    required this.wasteCategory,
    required this.confidence,
    required this.needsClarification,
    required this.clarificationQuestion,
    required this.disposalMethod,
    required this.reason,
    required this.steps,
    required this.tips,
  });

  factory WasteRecognitionResult.fromJson(Map<String, dynamic> json) {
    return WasteRecognitionResult(
      objectName: _readString(json, 'objectName', fallback: '알 수 없는 물건'),
      material: _readString(json, 'material', fallback: '확인 필요'),
      wasteCategory: _readString(json, 'wasteCategory', fallback: '기타'),
      confidence: _readDouble(json, 'confidence'),
      needsClarification: json['needsClarification'] == true,
      clarificationQuestion: _readString(json, 'clarificationQuestion'),
      disposalMethod: _readString(
        json,
        'disposalMethod',
        fallback: '지역 분리배출 기준을 확인해 주세요.',
      ),
      reason: _readString(
        json,
        'reason',
        fallback: '입력 정보만으로 일부 판단이 제한될 수 있어요.',
      ),
      steps: _readStringList(json, 'steps'),
      tips: _readStringList(json, 'tips'),
    );
  }

  WasteRecognitionResult copyWith({
    String? disposalMethod,
    String? reason,
    List<String>? steps,
    List<String>? tips,
  }) {
    return WasteRecognitionResult(
      objectName: objectName,
      material: material,
      wasteCategory: wasteCategory,
      confidence: confidence,
      needsClarification: needsClarification,
      clarificationQuestion: clarificationQuestion,
      disposalMethod: disposalMethod ?? this.disposalMethod,
      reason: reason ?? this.reason,
      steps: steps ?? this.steps,
      tips: tips ?? this.tips,
    );
  }

  static String _readString(
    Map<String, dynamic> json,
    String key, {
    String fallback = '',
  }) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }

  static double _readDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) {
      return value.clamp(0, 1).toDouble();
    }
    return 0;
  }

  static List<String> _readStringList(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is List) {
      return value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }
}
