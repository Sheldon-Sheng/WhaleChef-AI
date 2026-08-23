// lib/services/deepseek_api.dart
import 'dart:convert';

import 'package:dio/dio.dart';

/// 默认 AI 服务地址（DeepSeek，OpenAI 兼容 chat/completions）
const kDefaultAIBaseUrl = 'https://api.deepseek.com/v1';

/// 归一化 base URL：去首尾空白与尾部斜杠；空则回退默认
String normalizeBaseUrl(String url) {
  var u = url.trim();
  while (u.endsWith('/')) {
    u = u.substring(0, u.length - 1);
  }
  return u.isEmpty ? kDefaultAIBaseUrl : u;
}

class DeepSeekAPI {
  final Dio _dio;
  String _apiKey;
  String _model;

  DeepSeekAPI({
    required String apiKey,
    String model = 'deepseek-v4-flash',
    String baseUrl = kDefaultAIBaseUrl,
  }) : _apiKey = apiKey,
       _model = model,
       _dio = Dio(
         BaseOptions(
           baseUrl: normalizeBaseUrl(baseUrl),
           connectTimeout: const Duration(seconds: 30),
           receiveTimeout: const Duration(seconds: 120),
         ),
       );

  void updateConfig(String apiKey, String model, String baseUrl) {
    _apiKey = apiKey;
    _model = model;
    _dio.options.baseUrl = normalizeBaseUrl(baseUrl);
  }

  /// 调用 DeepSeek API 生成菜谱
  /// 返回解析后的 JSON Map
  /// 抛出异常：网络错误、API 错误、JSON 解析错误
  Future<Map<String, dynamic>> generateMealPlan(String prompt) async {
    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 65536,
          'reasoning_effort': 'low',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

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
        // content 为空时尝试从 reasoning_content 提取
        final reasoningContent =
            choices[0]['message']['reasoning_content'] as String?;
        if (reasoningContent != null && reasoningContent.isNotEmpty) {
          try {
            final jsonStr = _extractJSON(reasoningContent);
            return jsonDecode(jsonStr) as Map<String, dynamic>;
          } catch (e) {
            throw DeepSeekException('JSON 解析失败: $e');
          }
        }
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
  /// 支持多种格式：纯 JSON、```json...``` 包裹、或文本中混有 JSON
  String _extractJSON(String text) {
    // 尝试提取 ```json ... ``` 或 ``` ... ``` 包裹的内容
    final jsonMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```')
        .firstMatch(text);
    if (jsonMatch != null) return jsonMatch.group(1)!.trim();

    // 尝试直接解析整个文本
    final trimmed = text.trim();
    try {
      jsonDecode(trimmed);
      return trimmed;
    } catch (_) {}

    // 尝试提取第一个 { 到最后一个 } 之间的内容
    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start != -1 && end > start) {
      return trimmed.substring(start, end + 1);
    }

    return trimmed;
  }
}

class DeepSeekException implements Exception {
  final String message;
  DeepSeekException(this.message);
  @override
  String toString() => message;
}
