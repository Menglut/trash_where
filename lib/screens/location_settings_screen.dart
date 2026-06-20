import 'package:flutter/material.dart';

import '../services/location_preference_service.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  static const List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  final LocationPreferenceService _locationService =
      LocationPreferenceService();
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = true;
  bool _isDetecting = false;
  bool _isSaving = false;
  String? _regionName;
  String? _message;
  bool _isError = false;
  Set<String> _generalWasteDays = const {};
  Set<String> _recyclingDays = const {};
  Set<String> _foodWasteDays = const {};

  @override
  void initState() {
    super.initState();
    _loadRegion();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRegion() async {
    final regionName = await _locationService.loadRegionName();
    final schedule = await _locationService.loadWasteSchedule();
    if (!mounted) {
      return;
    }
    setState(() {
      _regionName = regionName;
      _controller.text = regionName ?? '';
      _generalWasteDays = _parseScheduleDays(schedule.generalWasteDays);
      _recyclingDays = _parseScheduleDays(schedule.recyclingDays);
      _foodWasteDays = _parseScheduleDays(schedule.foodWasteDays);
      _isLoading = false;
    });
  }

  Set<String> _parseScheduleDays(String value) {
    final normalized = value.trim();
    if (normalized == '매일') {
      return _weekdays.toSet();
    }

    return normalized
        .split(RegExp(r'[/,\s]+'))
        .map((day) => day.trim())
        .where(_weekdays.contains)
        .toSet();
  }

  String _formatScheduleDays(Set<String> selectedDays) {
    if (selectedDays.length == _weekdays.length) {
      return '매일';
    }

    final orderedDays = _weekdays
        .where(selectedDays.contains)
        .toList(growable: false);

    if (orderedDays.isEmpty) {
      return '미설정';
    }

    return orderedDays.join(' / ');
  }

  void _toggleScheduleDay(String category, String day) {
    setState(() {
      Set<String> toggle(Set<String> source) {
        final next = {...source};
        if (next.contains(day)) {
          next.remove(day);
        } else {
          next.add(day);
        }
        return next;
      }

      switch (category) {
        case 'general':
          _generalWasteDays = toggle(_generalWasteDays);
          break;
        case 'recycling':
          _recyclingDays = toggle(_recyclingDays);
          break;
        case 'food':
          _foodWasteDays = toggle(_foodWasteDays);
          break;
      }
    });
  }

  Future<void> _detectCurrentLocation() async {
    setState(() {
      _isDetecting = true;
      _message = null;
    });

    try {
      final regionName = await _locationService.detectAndSaveCurrentRegion();
      if (!mounted) {
        return;
      }
      setState(() {
        _regionName = regionName;
        _controller.text = regionName;
        _message = '현재 위치로 지역을 설정했어요.';
        _isError = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error.toString();
        _isError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
    }
  }

  Future<void> _saveManualRegion() async {
    setState(() {
      _isSaving = true;
      _message = null;
    });

    try {
      await _locationService.saveRegionName(_controller.text);
      final schedule = WasteSchedulePreference(
        generalWasteDays: _formatScheduleDays(_generalWasteDays),
        recyclingDays: _formatScheduleDays(_recyclingDays),
        foodWasteDays: _formatScheduleDays(_foodWasteDays),
      );
      await _locationService.saveWasteSchedule(schedule);
      if (!mounted) {
        return;
      }
      setState(() {
        _regionName = _controller.text.trim();
        _message = '지역과 배출일을 저장했어요.';
        _isError = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error.toString();
        _isError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _TopBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _HeaderSection(),
                          const SizedBox(height: 22),
                          _CurrentRegionCard(regionName: _regionName),
                          const SizedBox(height: 18),
                          _PrimaryActionButton(
                            title: '현재 위치로 설정',
                            icon: Icons.my_location_rounded,
                            isLoading: _isDetecting,
                            onTap: _isDetecting ? null : _detectCurrentLocation,
                          ),
                          const SizedBox(height: 22),
                          _ManualRegionCard(
                            controller: _controller,
                            weekdays: _weekdays,
                            generalWasteDays: _generalWasteDays,
                            recyclingDays: _recyclingDays,
                            foodWasteDays: _foodWasteDays,
                            onGeneralDayTap: (day) =>
                                _toggleScheduleDay('general', day),
                            onRecyclingDayTap: (day) =>
                                _toggleScheduleDay('recycling', day),
                            onFoodDayTap: (day) =>
                                _toggleScheduleDay('food', day),
                            isSaving: _isSaving,
                            onSave: _saveManualRegion,
                          ),
                          if (_message != null) ...[
                            const SizedBox(height: 18),
                            _MessageCard(message: _message!, isError: _isError),
                          ],
                          const SizedBox(height: 18),
                          const _NoticeCard(),
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

class _TopBar extends StatelessWidget {
  const _TopBar();

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
            '지역 설정',
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

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '우리 동네 기준으로\n안내할게요',
          style: TextStyle(
            fontSize: 36,
            height: 1.18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121826),
          ),
        ),
        SizedBox(height: 12),
        Text(
          '지역을 설정하면 사진 인식과 직접 검색 결과에 해당 지역 기준을 함께 반영합니다.',
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

class _CurrentRegionCard extends StatelessWidget {
  const _CurrentRegionCard({required this.regionName});

  final String? regionName;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFF1F6BFF),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '현재 설정 지역',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  regionName ?? '아직 설정되지 않았어요',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
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

class _ManualRegionCard extends StatelessWidget {
  const _ManualRegionCard({
    required this.controller,
    required this.weekdays,
    required this.generalWasteDays,
    required this.recyclingDays,
    required this.foodWasteDays,
    required this.onGeneralDayTap,
    required this.onRecyclingDayTap,
    required this.onFoodDayTap,
    required this.isSaving,
    required this.onSave,
  });

  final TextEditingController controller;
  final List<String> weekdays;
  final Set<String> generalWasteDays;
  final Set<String> recyclingDays;
  final Set<String> foodWasteDays;
  final ValueChanged<String> onGeneralDayTap;
  final ValueChanged<String> onRecyclingDayTap;
  final ValueChanged<String> onFoodDayTap;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '지역 직접 설정',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSave(),
            decoration: InputDecoration(
              hintText: '예: 경기도 부천시 상동',
              prefixIcon: const Icon(Icons.edit_location_alt_outlined),
              filled: true,
              fillColor: const Color(0xFFF7FAFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFDCE8FF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFDCE8FF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFF1F6BFF),
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            '배출일 설정',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),
          _ScheduleDaySelector(
            weekdays: weekdays,
            selectedDays: generalWasteDays,
            icon: Icons.delete_rounded,
            label: '일반쓰레기',
            onDayTap: onGeneralDayTap,
          ),
          const SizedBox(height: 14),
          _ScheduleDaySelector(
            weekdays: weekdays,
            selectedDays: recyclingDays,
            icon: Icons.recycling_rounded,
            label: '재활용',
            onDayTap: onRecyclingDayTap,
          ),
          const SizedBox(height: 14),
          _ScheduleDaySelector(
            weekdays: weekdays,
            selectedDays: foodWasteDays,
            icon: Icons.compost_rounded,
            label: '음식물',
            onDayTap: onFoodDayTap,
          ),
          const SizedBox(height: 18),
          _PrimaryActionButton(
            title: '저장',
            icon: Icons.check_rounded,
            isLoading: isSaving,
            onTap: isSaving ? null : onSave,
          ),
        ],
      ),
    );
  }
}

class _ScheduleDaySelector extends StatelessWidget {
  const _ScheduleDaySelector({
    required this.weekdays,
    required this.selectedDays,
    required this.icon,
    required this.label,
    required this.onDayTap,
  });

  final List<String> weekdays;
  final Set<String> selectedDays;
  final IconData icon;
  final String label;
  final ValueChanged<String> onDayTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: const Color(0xFF1F6BFF)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF344054),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final day in weekdays)
                _WeekdayChip(
                  day: day,
                  isSelected: selectedDays.contains(day),
                  onTap: () => onDayTap(day),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final String day;
  final bool isSelected;
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
          width: 40,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? blue : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? blue : const Color(0xFFDCE8FF),
            ),
          ),
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF667085),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.title,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 26),
        label: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1F6BFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: isError ? const Color(0xFFE5484D) : const Color(0xFF1F6BFF),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: Color(0xFF344054),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard();

  @override
  Widget build(BuildContext context) {
    return const _WhiteCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF8F98A8), size: 26),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '공공데이터 연동 없이도 오늘 바로 사용할 수 있도록 배출일을 직접 저장합니다. 실제 요일이 바뀌면 이 화면에서 수정해 주세요.',
              style: TextStyle(
                fontSize: 14.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: Color(0xFF667085),
              ),
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
