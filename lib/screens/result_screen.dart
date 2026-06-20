import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/waste_recognition_result.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result, this.imageBytes});

  final WasteRecognitionResult result;
  final Uint8List? imageBytes;

  static const Color blue = Color(0xFF1F6BFF);
  static const Color textDark = Color(0xFF111827);
  static const Color textGray = Color(0xFF5F6876);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ResultTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _StepBadge(),
                    const SizedBox(height: 18),
                    _RecognizedCard(result: result, imageBytes: imageBytes),
                    const SizedBox(height: 18),
                    _FinalResultCard(result: result),
                    const SizedBox(height: 14),
                    _InfoCard(
                      icon: Icons.question_mark_rounded,
                      title: '이유',
                      description: result.reason,
                    ),
                    const SizedBox(height: 14),
                    _InfoCard(
                      icon: Icons.delete_outline_rounded,
                      title: '버리는 방법',
                      description: _formatList(
                        result.steps,
                        fallback: result.disposalMethod,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _InfoCard(
                      icon: Icons.lightbulb_outline_rounded,
                      title: '주의할 점',
                      description: _formatList(
                        result.tips,
                        fallback: '지역별 배출 기준이 다를 수 있으니 거주지 안내를 함께 확인해 주세요.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomButtons(
              onHomeTap: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  String _formatList(List<String> values, {required String fallback}) {
    if (values.isEmpty) {
      return fallback;
    }
    return values
        .asMap()
        .entries
        .map((entry) => '${entry.key + 1}. ${entry.value}')
        .join('\n');
  }
}

class _ResultTopBar extends StatelessWidget {
  const _ResultTopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 32,
                color: Color(0xFF111111),
              ),
            ),
          ),
          const Text(
            '결과 보기',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE8FF)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 22, color: ResultScreen.blue),
          SizedBox(width: 8),
          Text(
            '분류 완료',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4E5968),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecognizedCard extends StatelessWidget {
  const _RecognizedCard({required this.result, required this.imageBytes});

  final WasteRecognitionResult result;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    final percent = (result.confidence * 100).round();

    return _WhiteCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
      child: Row(
        children: [
          _ResultThumbnail(imageBytes: imageBytes),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.objectName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ResultScreen.textDark,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  '${result.material} · 신뢰도 $percent%',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: ResultScreen.textGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultThumbnail extends StatelessWidget {
  const _ResultThumbnail({required this.imageBytes});

  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    final bytes = imageBytes;
    if (bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(bytes, width: 118, height: 88, fit: BoxFit.cover),
      );
    }

    return Container(
      width: 118,
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.search_rounded,
        size: 42,
        color: ResultScreen.blue,
      ),
    );
  }
}

class _FinalResultCard extends StatelessWidget {
  const _FinalResultCard({required this.result});

  final WasteRecognitionResult result;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: ResultScreen.blue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _categoryIcon(result.wasteCategory),
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.wasteCategory,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w700,
                    color: ResultScreen.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.disposalMethod,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: ResultScreen.textGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    if (category.contains('재활용')) {
      return Icons.recycling_rounded;
    }
    if (category.contains('음식물')) {
      return Icons.compost_rounded;
    }
    if (category.contains('유해')) {
      return Icons.warning_amber_rounded;
    }
    return Icons.delete_outline_rounded;
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF5EA2FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: ResultScreen.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.48,
                    fontWeight: FontWeight.w600,
                    color: ResultScreen.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F3F8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({required this.onHomeTap});

  final VoidCallback onHomeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
      child: _BottomButton(
        title: '홈으로',
        icon: Icons.home_rounded,
        onTap: onHomeTap,
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 62,
          decoration: BoxDecoration(
            color: ResultScreen.blue,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 25, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
