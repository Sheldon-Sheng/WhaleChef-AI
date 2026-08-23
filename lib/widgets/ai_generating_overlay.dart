// lib/widgets/ai_generating_overlay.dart
import 'dart:async';
import 'package:flutter/material.dart';

class AIGeneratingOverlay extends StatefulWidget {
  final String imageAsset;
  final String? errorMessage;
  final bool isFailed;
  final VoidCallback? onRetry;

  const AIGeneratingOverlay({
    super.key,
    required this.imageAsset,
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
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 全屏背景图
          Image.asset(
            widget.imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.blueGrey[900],
              child: const Icon(Icons.image, size: 64, color: Colors.white70),
            ),
          ),
          // 前景内容 + 半透明遮罩保证可读性
          Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.isFailed ? Colors.white : Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.isFailed
                    ? const [
                        BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isFailed) ...[
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(widget.errorMessage ?? '生成失败',
                        style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/images/error.png',
                      height: 140,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),
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
                    Text('${(_progress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 14, color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text('正在为您规划菜谱...', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
