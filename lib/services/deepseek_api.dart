// lib/services/deepseek_api.dart
import 'dart:convert';
import 'package:dio/dio.dart';

class DeepSeekAPI {
  final Dio _dio;
  String _apiKey;
  String _model;

  DeepSeekAPI({required String apiKey, String model = 'deepseek-v4-flash'})
    : _apiKey = apiKey,
      _model = model,
      _dio = Dio(BaseOptions(
        baseUrl: 'https://api.deepseek.com/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
      ));

  void updateConfig(String apiKey, String model) {
    _apiKey = apiKey;
    _model = model;
  }

  /// 调用 DeepSeek API 生成菜谱
  /// 返回解析后的 JSON Map
  /// 抛出异常：网络错误、API 错误、JSON 解析错误
  Future<Map<String, dynamic>> generateMealPlan(String prompt) async {
    try {
      final response = await _dio.post('/chat/completions', data: {
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 8192,
      }, options: Options(
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      ));

      if (response.statusCode != 200) {
        throw DeepSeekException('API 返回错误: ${response.statusCode}');
      }

      final body = response.data as Map<String, dynamic>;
      final choices = body['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw DeepSeekException('API 返回为空');
      }

      final content = choices[0]['message']['content'] as String?;
      if (content == null || content.isEmpty) {
        throw DeepSeekException('API 返回内容为空');
      }

      // 尝试解析 JSON
      try {
        final jsonStr = _extractJSON(content);
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      } catch (e) {
        throw DeepSeekException('JSON 解析失败: $e');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw DeepSeekException('网络超时，请检查网络连接');
      }
      if (e.response?.statusCode == 401) {
        throw DeepSeekException('API Key 无效，请在设置中检查');
      }
      if (e.response?.statusCode == 402) {
        throw DeepSeekException('API 余额不足，请充值');
      }
      throw DeepSeekException('网络请求失败: ${e.message}');
    }
  }

  /// 从 AI 返回的文本中提取 JSON 部分
  String _extractJSON(String text) {
    // 尝试提取 ```json ... ``` 包裹的内容
    final jsonMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(text);
    if (jsonMatch != null) return jsonMatch.group(1)!;

    // 尝试提取 { ... } 包裹的内容
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end > start) {
      return text.substring(start, end + 1);
    }

    return text;
  }
}

class DeepSeekException implements Exception {
  final String message;
  DeepSeekException(this.message);
  @override
  String toString() => message;
}