import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/waste_recognition_result.dart';
import 'result_screen.dart';

class AdditionalQuestionScreen extends StatefulWidget {
  const AdditionalQuestionScreen({
    super.key,
    required this.result,
    required this.imageBytes,
  });

  final WasteRecognitionResult result;
  final Uint8List imageBytes;

  @override
  State<AdditionalQuestionScreen> createState() =>
      _AdditionalQuestionScreenState();
}

class _AdditionalQuestionScreenState extends State<AdditionalQuestionScreen> {
  int selectedIndex = 3;

  static const List<_QuestionOption> options = [
    _QuestionOption(
      icon: Icons.auto_awesome_rounded,
      title: '깨끗해요',
      value: 'clean',
    ),
    _QuestionOption(
      icon: Icons.water_drop_outlined,
      title: '조금 묻었어요',
      value: 'slightly_dirty',
    ),
    _QuestionOption(
      icon: Icons.water_drop_rounded,
      title: '많이 묻었어요',
      value: 'dirty',
    ),
    _QuestionOption(
      icon: Icons.help_outline_rounded,
      title: '잘 모르겠어요',
      value: 'unknown',
    ),
  ];

  WasteRecognitionResult _resultWithAnswer() {
    final selected = options[selectedIndex];

    if (selected.value == 'clean') {
      return widget.result.copyWith(
        tips: [...widget.result.tips, '깨끗한 상태라면 재질 표시와 지역 기준에 맞춰 분리배출하세요.'],
      );
    }

    if (selected.value == 'dirty') {
      return widget.result.copyWith(
        disposalMethod: '오염이 심하면 재활용이 어려워 일반쓰레기로 배출하는 쪽이 안전합니다.',
        reason: '음식물, 기름, 내용물이 많이 묻은 포장재는 선별 과정에서 재활용 품질을 떨어뜨릴 수 있어요.',
        tips: ['가능하면 내용물을 비우고 한 번 헹군 뒤 다시 판단하세요.', '씻어도 오염이 남으면 일반쓰레기로 배출하세요.'],
      );
    }

    if (selected.value == 'slightly_dirty') {
      return widget.result.copyWith(
        disposalMethod: '가볍게 헹군 뒤 재질별 분리배출 기준에 맞춰 배출하세요.',
        tips: ['물로 헹궈 음식물과 액체를 제거하세요.', ...widget.result.tips],
      );
    }

    return widget.result;
  }

  void _showResult() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: _resultWithAnswer(),
          imageBytes: widget.imageBytes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _QuestionTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _StepBadge(),
                    const SizedBox(height: 18),
                    _RecognizedItemCard(
                      result: widget.result,
                      imageBytes: widget.imageBytes,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      widget.result.clarificationQuestion.isEmpty
                          ? '오염 상태가 어떤가요?'
                          : widget.result.clarificationQuestion,
                      style: const TextStyle(
                        fontSize: 31,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 22),
                    ...List.generate(options.length, (index) {
                      final option = options[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _AnswerOptionButton(
                          icon: option.icon,
                          title: option.title,
                          isSelected: selectedIndex == index,
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _BottomActionButton(
                            title: '이전',
                            isPrimary: false,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _BottomActionButton(
                            title: '결과 보기',
                            icon: Icons.check_circle_rounded,
                            isPrimary: true,
                            onTap: _showResult,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionOption {
  const _QuestionOption({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;
}

class _QuestionTopBar extends StatelessWidget {
  const _QuestionTopBar();

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
            '추가 질문',
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
          Icon(Icons.tune_rounded, size: 22, color: Color(0xFF1F6BFF)),
          SizedBox(width: 8),
          Text(
            '정확한 분류를 위한 확인 2/3',
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

class _RecognizedItemCard extends StatelessWidget {
  const _RecognizedItemCard({required this.result, required this.imageBytes});

  final WasteRecognitionResult result;
  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              imageBytes,
              width: 108,
              height: 82,
              fit: BoxFit.cover,
            ),
          ),
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
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.material} · ${result.wasteCategory}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5F6876),
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

class _AnswerOptionButton extends StatelessWidget {
  const _AnswerOptionButton({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF1F6BFF);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 74,
          decoration: BoxDecoration(
            color: isSelected ? blue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? blue : const Color(0xFFD5E5FF),
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 24),
              Icon(
                icon,
                size: 30,
                color: isSelected ? Colors.white : const Color(0xFF8F98A8),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF111111),
                  ),
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 24),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 30,
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

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.title,
    required this.isPrimary,
    required this.onTap,
    this.icon,
  });

  final String title;
  final IconData? icon;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF1F6BFF);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 62,
          decoration: BoxDecoration(
            color: isPrimary ? blue : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: isPrimary
                ? null
                : Border.all(color: const Color(0xFFDCE8FF)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 24, color: isPrimary ? Colors.white : blue),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isPrimary ? Colors.white : blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
