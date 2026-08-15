// lib/widgets/ai_generating_overlay.dart
import 'dart:async';
import 'package:flutter/material.dart';

class AIGeneratingOverlay extends StatefulWidget {
  final String imageAsset;
  final String failedImageAsset;
  final String? errorMessage;
  final bool isFailed;
  final VoidCallback? onRetry;

  const AIGeneratingOverlay({
    super.key,
    required this.imageAsset,
    required this.failedImageAsset,
    this.errorMessage,
    this.isFailed = false,
    this.onRetry,
  });

  @override
  State<AIGeneratingOverlay> createState() => _AIGeneratingOverlayState();
}

class _AIGeneratingOverlayState extends State<AIGeneratingOverlay> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!widget.isFailed) {
      _startProgress();
    }
  }

  void _startProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_progress < 0.9) {
        setState(() => _progress += 0.02);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(widget.isFailed ? widget.failedImageAsset : widget.imageAsset,
                height: 300, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 300, color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 64, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              if (widget.isFailed) ...[
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(widget.errorMessage ?? '生成失败', style: const TextStyle(fontSize: 16, color: Colors.red)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ] else ...[
                LinearProgressIndicator(value: _progress, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 16),
                Text('${(_progress * 100).toInt()}%', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                const Text('正在为您规划菜谱...', style: TextStyle(fontSize: 16)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}