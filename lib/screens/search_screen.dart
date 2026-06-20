import 'package:flutter/material.dart';

import '../models/waste_recognition_result.dart';
import '../services/location_preference_service.dart';
import '../services/recent_search_service.dart';
import '../services/waste_ai_service.dart';
import 'result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery, this.searchOnOpen = false});

  final String? initialQuery;
  final bool searchOnOpen;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final WasteAiService _aiService = WasteAiService();
  final LocationPreferenceService _locationService =
      LocationPreferenceService();
  final RecentSearchService _recentSearchService = RecentSearchService();

  bool _isSearching = false;
  String? _errorMessage;
  String? _regionName;
  WasteSchedulePreference _schedule = WasteSchedulePreference.defaultSchedule;
  List<String> _recentSearches = const [];

  static const List<String> _suggestions = [
    '컵라면 용기',
    '치킨 박스',
    '건전지',
    '보조배터리',
    '깨진 유리컵',
    '비닐 포장지',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final regionName = await _locationService.loadRegionName();
    final schedule = await _locationService.loadWasteSchedule();
    final recentSearches = await _recentSearchService.loadRecentSearches();
    if (!mounted) {
      return;
    }
    setState(() {
      _regionName = regionName;
      _schedule = schedule;
      _recentSearches = recentSearches;
      _controller.text = widget.initialQuery ?? '';
    });

    final initialQuery = widget.initialQuery?.trim();
    if (widget.searchOnOpen &&
        initialQuery != null &&
        initialQuery.isNotEmpty) {
      await _search(initialQuery);
    }
  }

  Future<void> _clearRecentSearches() async {
    await _recentSearchService.clearRecentSearches();
    if (!mounted) {
      return;
    }
    setState(() {
      _recentSearches = const [];
    });
  }

  Future<void> _search([String? value]) async {
    final query = (value ?? _controller.text).trim();
    if (query.isEmpty || _isSearching) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _controller.text = query;
    });

    try {
      final WasteRecognitionResult result = await _aiService.searchWaste(
        query,
        regionName: _regionName,
        scheduleText: _schedule.toPromptText(),
      );
      final recentSearches = await _recentSearchService.addSearch(query);
      if (!mounted) {
        return;
      }
      setState(() {
        _recentSearches = recentSearches;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } on MissingOpenAiApiKeyException {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = '.env에 OPENAI_API_KEY를 입력해 주세요.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
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
            const _SearchTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeaderSection(),
                    if (_regionName != null) ...[
                      const SizedBox(height: 16),
                      _RegionPill(regionName: _regionName!),
                    ],
                    const SizedBox(height: 22),
                    _SearchBox(
                      controller: _controller,
                      isSearching: _isSearching,
                      onSubmitted: _search,
                      onSearchTap: _search,
                    ),
                    if (_recentSearches.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _RecentSearchSection(
                        searches: _recentSearches,
                        onSearchTap: _search,
                        onClearTap: _clearRecentSearches,
                      ),
                    ],
                    const SizedBox(height: 22),
                    const _SectionTitle(title: '빠른 검색'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final suggestion in _suggestions)
                          _SuggestionChip(
                            text: suggestion,
                            onTap: () => _search(suggestion),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    if (_errorMessage != null) ...[
                      _InfoCard(
                        icon: Icons.error_outline_rounded,
                        title: '검색할 수 없어요',
                        message: _errorMessage!,
                        isError: true,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const _InfoCard(
                      icon: Icons.tips_and_updates_outlined,
                      title: '검색 팁',
                      message: '재질이나 상태를 함께 적으면 더 정확해요. 예: 기름 묻은 치킨 박스',
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

class _RegionPill extends StatelessWidget {
  const _RegionPill({required this.regionName});

  final String regionName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFDCE8FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_rounded,
            size: 20,
            color: Color(0xFF1F6BFF),
          ),
          const SizedBox(width: 6),
          Text(
            regionName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF174EDB),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchTopBar extends StatelessWidget {
  const _SearchTopBar();

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
            '직접 검색',
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
          '버릴 물건을\n검색해 보세요',
          style: TextStyle(
            fontSize: 36,
            height: 1.18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121826),
          ),
        ),
        SizedBox(height: 12),
        Text(
          '물건 이름이나 상태를 입력하면 알맞은 분리배출 방법을 안내합니다.',
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

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.isSearching,
    required this.onSubmitted,
    required this.onSearchTap,
  });

  final TextEditingController controller;
  final bool isSearching;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE8FF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 30, color: Color(0xFF1F6BFF)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isSearching,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              decoration: const InputDecoration(
                hintText: '예: 우유팩, 건전지, 컵라면 용기',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB0B0B0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            height: 48,
            child: FilledButton(
              onPressed: isSearching ? null : onSearchTap,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: const Color(0xFF1F6BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isSearching
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_forward_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }
}

class _RecentSearchSection extends StatelessWidget {
  const _RecentSearchSection({
    required this.searches,
    required this.onSearchTap,
    required this.onClearTap,
  });

  final List<String> searches;
  final ValueChanged<String> onSearchTap;
  final VoidCallback onClearTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 24,
                color: Color(0xFF1F6BFF),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '최근 검색',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              TextButton(
                onPressed: onClearTap,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF667085),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 34),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '지우기',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final search in searches)
                _SuggestionChip(text: search, onTap: () => onSearchTap(search)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF174EDB),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
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
    final color = isError ? const Color(0xFFE5484D) : const Color(0xFF1F6BFF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
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
