import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/waste_recognition_result.dart';
import '../services/location_preference_service.dart';
import '../services/waste_ai_service.dart';
import 'additional_question_screen.dart';
import 'result_screen.dart';

class AiRecognitionScreen extends StatefulWidget {
  const AiRecognitionScreen({super.key});

  @override
  State<AiRecognitionScreen> createState() => _AiRecognitionScreenState();
}

class _AiRecognitionScreenState extends State<AiRecognitionScreen> {
  final ImagePicker _picker = ImagePicker();
  final WasteAiService _aiService = WasteAiService();
  final LocationPreferenceService _locationService =
      LocationPreferenceService();

  Uint8List? _imageBytes;
  String _mimeType = 'image/jpeg';
  WasteRecognitionResult? _result;
  bool _isAnalyzing = false;
  String? _errorMessage;
  String? _regionName;
  WasteSchedulePreference _schedule = WasteSchedulePreference.defaultSchedule;

  @override
  void initState() {
    super.initState();
    _loadRegionName();
  }

  Future<void> _loadRegionName() async {
    final regionName = await _locationService.loadRegionName();
    final schedule = await _locationService.loadWasteSchedule();
    if (!mounted) {
      return;
    }
    setState(() {
      _regionName = regionName;
      _schedule = schedule;
    });
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 82,
    );

    if (picked == null) {
      return;
    }

    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _mimeType = picked.mimeType ?? _guessMimeType(picked.name);
      _result = null;
      _errorMessage = null;
      _isAnalyzing = true;
    });

    try {
      final result = await _aiService.recognizeWaste(
        imageBytes: bytes,
        mimeType: _mimeType,
        regionName: _regionName,
        scheduleText: _schedule.toPromptText(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    } on MissingOpenAiApiKeyException {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = '.env에 OPENAI_API_KEY를 입력해 주세요.';
        _isAnalyzing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isAnalyzing = false;
      });
    }
  }

  void _continue() {
    final result = _result;
    final imageBytes = _imageBytes;
    if (result == null || imageBytes == null) {
      return;
    }

    final destination = result.needsClarification
        ? AdditionalQuestionScreen(result: result, imageBytes: imageBytes)
        : ResultScreen(result: result, imageBytes: imageBytes);

    Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
  }

  String _guessMimeType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _TopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeaderSection(),
                    const SizedBox(height: 22),
                    _PhotoPreviewCard(
                      imageBytes: _imageBytes,
                      isAnalyzing: _isAnalyzing,
                    ),
                    const SizedBox(height: 18),
                    _ActionButtons(
                      isBusy: _isAnalyzing,
                      onCameraTap: () => _pickAndAnalyze(ImageSource.camera),
                      onGalleryTap: () => _pickAndAnalyze(ImageSource.gallery),
                    ),
                    const SizedBox(height: 18),
                    if (_errorMessage != null) ...[
                      _MessageCard(
                        icon: Icons.error_outline_rounded,
                        title: '분석할 수 없어요',
                        message: _errorMessage!,
                        isError: true,
                      ),
                      const SizedBox(height: 18),
                    ],
                    if (_result != null) ...[
                      _RecognitionResultCard(result: _result!),
                      const SizedBox(height: 20),
                      _BottomButton(
                        title: _result!.needsClarification
                            ? '정확도 높이기'
                            : '결과 보기',
                        icon: _result!.needsClarification
                            ? Icons.help_outline_rounded
                            : Icons.check_circle_rounded,
                        isPrimary: true,
                        onTap: _continue,
                      ),
                    ] else if (!_isAnalyzing) ...[
                      const _MessageCard(
                        icon: Icons.camera_alt_outlined,
                        title: '사진을 선택해 주세요',
                        message: '물건이 잘 보이도록 밝은 곳에서 한 장만 촬영하면 더 정확해요.',
                      ),
                    ],
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

class _TopAppBar extends StatelessWidget {
  const _TopAppBar();

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
            'AI 사진 인식',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사진으로 물건을\n인식해 볼게요',
          style: TextStyle(
            fontSize: 36,
            height: 1.18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121826),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'AI가 물건과 재질을 추정하고 분리배출 방법까지 이어서 안내합니다.',
          style: TextStyle(
            fontSize: 15.5,
            height: 1.45,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6A7280),
          ),
        ),
      ],
    );
  }
}

class _PhotoPreviewCard extends StatelessWidget {
  const _PhotoPreviewCard({
    required this.imageBytes,
    required this.isAnalyzing,
  });

  final Uint8List? imageBytes;
  final bool isAnalyzing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAEC),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageBytes == null)
            const _EmptyPhotoPlaceholder()
          else
            Image.memory(imageBytes!, fit: BoxFit.cover),
          if (isAnalyzing)
            Container(
              color: Colors.black.withValues(alpha: 0.34),
              child: const Center(child: _AnalyzingPill()),
            ),
        ],
      ),
    );
  }
}

class _EmptyPhotoPlaceholder extends StatelessWidget {
  const _EmptyPhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDDE9F8), Color(0xFFF6FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.add_a_photo_outlined,
          size: 88,
          color: Color(0xFF1F6BFF),
        ),
      ),
    );
  }
}

class _AnalyzingPill extends StatelessWidget {
  const _AnalyzingPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(width: 12),
          Text(
            'AI 분석 중',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F6BFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isBusy,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final bool isBusy;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BottomButton(
            title: '촬영',
            icon: Icons.camera_alt_outlined,
            isPrimary: true,
            onTap: isBusy ? null : onCameraTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BottomButton(
            title: '앨범',
            icon: Icons.photo_library_outlined,
            isPrimary: false,
            onTap: isBusy ? null : onGalleryTap,
          ),
        ),
      ],
    );
  }
}

class _RecognitionResultCard extends StatelessWidget {
  const _RecognitionResultCard({required this.result});

  final WasteRecognitionResult result;

  @override
  Widget build(BuildContext context) {
    final percent = (result.confidence * 100).round();

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFF1F6BFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
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
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${result.material} · ${result.wasteCategory}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6A7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: result.confidence.clamp(0, 1),
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE1EDFF),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2574FF),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F6BFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            result.needsClarification
                ? result.clarificationQuestion
                : result.disposalMethod,
            style: const TextStyle(
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.isError = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isError ? const Color(0xFFE5484D) : const Color(0xFF1F6BFF),
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667085),
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
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.title,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF1F6BFF);
    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 62,
          decoration: BoxDecoration(
            color: isPrimary
                ? blue.withValues(alpha: enabled ? 1 : 0.45)
                : Colors.white.withValues(alpha: enabled ? 1 : 0.55),
            borderRadius: BorderRadius.circular(18),
            border: isPrimary
                ? null
                : Border.all(color: const Color(0xFFDCE8FF), width: 1.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: isPrimary ? Colors.white : blue),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 19,
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
