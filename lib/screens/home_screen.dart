import 'package:flutter/material.dart';
import '../services/location_preference_service.dart';
import '../services/recent_search_service.dart';
import '../widgets/app_side_menu.dart';
import 'ai_recognition_screen.dart';
import 'location_settings_screen.dart';
import 'search_screen.dart';

class AppColors {
  static const blue = Color(0xFF1F5BEA);
  static const deepBlue = Color(0xFF174EDB);
  static const lightBlue = Color(0xFFEAF3FF);
  static const textDark = Color(0xFF151515);
  static const textGray = Color(0xFF666B73);
  static const cardBorder = Color(0xFFE9EEF6);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationPreferenceService _locationService =
      LocationPreferenceService();
  final RecentSearchService _recentSearchService = RecentSearchService();
  String? _regionName;
  WasteSchedulePreference _schedule = WasteSchedulePreference.defaultSchedule;
  List<String> _recentSearches = const [];

  @override
  void initState() {
    super.initState();
    _loadRegionName();
  }

  Future<void> _loadRegionName() async {
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
    });
  }

  void _goToCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiRecognitionScreen()),
    );
  }

  Future<void> _goToSearch(BuildContext context, {String? initialQuery}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          initialQuery: initialQuery,
          searchOnOpen: initialQuery != null,
        ),
      ),
    );
    await _loadRegionName();
  }

  Future<void> _goToLocationSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationSettingsScreen()),
    );
    await _loadRegionName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(onMenuTap: () => showAppSideMenu(context)),
              const SizedBox(height: 26),
              const _HeroSection(),
              const SizedBox(height: 30),

              _PhotoCheckButton(onTap: () => _goToCamera(context)),

              const SizedBox(height: 18),

              _SearchButton(onTap: () => _goToSearch(context)),

              const SizedBox(height: 22),

              _ScheduleCard(
                regionName: _regionName,
                schedule: _schedule,
                onLocationTap: () => _goToLocationSettings(context),
              ),

              const SizedBox(height: 18),

              _RecentSearchCard(
                searches: _recentSearches,
                onSearchTap: (query) =>
                    _goToSearch(context, initialQuery: query),
                onViewAllTap: () => _goToSearch(context),
              ),

              const SizedBox(height: 18),

              const _EcoBanner(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onMenuTap;

  const _TopBar({required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onMenuTap,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.menu_rounded,
                size: 34,
                color: Color(0xFF111111),
              ),
            ),
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              size: 32,
              color: Color(0xFF111111),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4B3E),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isSmall = width < 360;

        final heroHeight = isSmall ? 215.0 : 235.0;
        final titleSize = isSmall ? 48.0 : 54.0;
        final subtitleSize = isSmall ? 17.0 : 19.0;
        final illustrationSize = isSmall ? 135.0 : 160.0;

        return SizedBox(
          height: heroHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 10,
                child: SizedBox(
                  width: width * 0.62,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이거 어디\n버려?',
                        style: TextStyle(
                          fontSize: titleSize,
                          height: 1.08,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepBlue,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '버리기 어려운 물건을\n사진으로 확인해보세요',
                        style: TextStyle(
                          fontSize: subtitleSize,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                right: -4,
                top: isSmall ? 42 : 36,
                child: SizedBox(
                  width: illustrationSize,
                  height: illustrationSize,
                  child: CustomPaint(painter: _EarthRecyclePainter()),
                ),
              ),

              Positioned(
                left: width * 0.47,
                top: 0,
                child: Transform.rotate(
                  angle: -0.55,
                  child: const Icon(
                    Icons.eco_rounded,
                    size: 25,
                    color: Color(0xFF58B957),
                  ),
                ),
              ),

              Positioned(
                left: width * 0.58,
                top: 60,
                child: Transform.rotate(
                  angle: 0.45,
                  child: const Icon(
                    Icons.eco_rounded,
                    size: 18,
                    color: Color(0xFF58B957),
                  ),
                ),
              ),

              Positioned(
                left: width * 0.66,
                top: 34,
                child: const _Cloud(width: 34, height: 14),
              ),

              const Positioned(
                right: 68,
                top: 4,
                child: _Cloud(width: 44, height: 18),
              ),

              const Positioned(
                right: 8,
                top: 34,
                child: _Cloud(width: 42, height: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PhotoCheckButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PhotoCheckButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 360;

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              height: isSmall ? 58 : 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2F7BFF), Color(0xFF1F5BEA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: 64,
                    bottom: -38,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 96,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),

                  // 왼쪽 카메라 아이콘
                  Positioned(
                    left: isSmall ? 20 : 24,
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: isSmall ? 28 : 31,
                    ),
                  ),

                  // 가운데 텍스트
                  Center(
                    child: Text(
                      '사진으로 확인하기',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmall ? 20 : 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // 오른쪽 화살표
                  Positioned(
                    right: isSmall ? 20 : 24,
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 360;

        return _WhiteCard(
          height: isSmall ? 54 : 58,
          borderRadius: 14,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 왼쪽 돋보기 아이콘
                  Positioned(
                    left: isSmall ? 20 : 24,
                    child: Icon(
                      Icons.search_rounded,
                      size: isSmall ? 29 : 32,
                      color: AppColors.deepBlue,
                    ),
                  ),

                  // 가운데 텍스트
                  Center(
                    child: Text(
                      '직접 검색하기',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmall ? 18 : 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),

                  // 오른쪽 화살표
                  Positioned(
                    right: isSmall ? 20 : 24,
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 30,
                      color: Color(0xFF111111),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.regionName,
    required this.schedule,
    required this.onLocationTap,
  });

  final String? regionName;
  final WasteSchedulePreference schedule;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      borderRadius: 22,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.deepBlue,
                  size: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    regionName ?? '내 지역 배출일',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: onLocationTap,
                    borderRadius: BorderRadius.circular(18),
                    child: Ink(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD8E2F3)),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 17,
                            color: AppColors.deepBlue,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '지역 설정',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.deepBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _ScheduleRow(
              icon: Icons.delete_rounded,
              iconColor: Color(0xFF6B6B6B),
              title: '일반쓰레기',
              day: schedule.generalWasteDays,
            ),

            const _DividerLine(),

            _ScheduleRow(
              icon: Icons.recycling_rounded,
              iconColor: AppColors.blue,
              title: '재활용',
              day: schedule.recyclingDays,
            ),

            const _DividerLine(),

            _ScheduleRow(
              icon: Icons.compost_rounded,
              iconColor: Color(0xFF54AE3D),
              title: '음식물',
              day: schedule.foodWasteDays,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String day;

  const _ScheduleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          SizedBox(width: 34, child: Icon(icon, size: 30, color: iconColor)),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          SizedBox(
            width: 118,
            child: Text(
              day,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentSearchCard extends StatelessWidget {
  const _RecentSearchCard({
    required this.searches,
    required this.onSearchTap,
    required this.onViewAllTap,
  });

  final List<String> searches;
  final ValueChanged<String> onSearchTap;
  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final visibleSearches = searches.take(5).toList(growable: false);

    return _WhiteCard(
      borderRadius: 22,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.deepBlue,
                  size: 28,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    '최근 검색',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                _ViewAllButton(onTap: onViewAllTap),
              ],
            ),
            const SizedBox(height: 18),
            if (visibleSearches.isEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '직접 검색하면 여기에 기록이 남아요.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGray,
                  ),
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final search in visibleSearches)
                      _SearchChip(
                        text: search,
                        onTap: () => onSearchTap(search),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton({required this.onTap});

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
          height: 34,
          padding: const EdgeInsets.only(left: 13, right: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD8E2F3)),
            color: Colors.white,
          ),
          child: const Row(
            children: [
              Text(
                '전체 보기',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepBlue,
                ),
              ),
              SizedBox(width: 3),
              Icon(
                Icons.chevron_right_rounded,
                size: 23,
                color: AppColors.deepBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SearchChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Ink(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(21),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.deepBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EcoBanner extends StatelessWidget {
  const _EcoBanner();

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 380;

    return Container(
      height: isNarrow ? 122 : 112,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD5E8FF), width: 1.2),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 14,
            bottom: 0,
            child: CustomPaint(
              size: const Size(105, 58),
              painter: _CityPainter(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: CustomPaint(painter: _CuteEarthPainter()),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '함께 지키는\n깨끗한 지구',
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: isNarrow ? 18 : 19,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF174EDB),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '올바른 분리배출로 지구를 지켜요!',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isNarrow ? 14 : 15,
                          height: 1.32,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5B6878),
                        ),
                      ),
                    ],
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
  final Widget child;
  final double? height;
  final double borderRadius;

  const _WhiteCard({required this.child, this.height, this.borderRadius = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 46),
      color: const Color(0xFFE9EDF4),
    );
  }
}

class _Cloud extends StatelessWidget {
  final double width;
  final double height;

  const _Cloud({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(width, height), painter: _CloudPainter());
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD8ECFF);

    final path = Path()
      ..moveTo(size.width * 0.08, size.height)
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.48,
        size.width * 0.34,
        size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.05,
        size.width * 0.63,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.2,
        size.width * 0.92,
        size.height,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EarthRecyclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final earthCenter = Offset(size.width * 0.64, size.height * 0.56);
    final earthRadius = size.width * 0.38;

    final earthPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8BD7FF), Color(0xFF2B82E6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: earthCenter, radius: earthRadius));

    canvas.drawCircle(earthCenter, earthRadius, earthPaint);

    final landPaint = Paint()..color = const Color(0xFF61BC63);

    canvas.drawOval(
      Rect.fromCenter(
        center: earthCenter + Offset(-earthRadius * 0.22, -earthRadius * 0.23),
        width: earthRadius * 0.72,
        height: earthRadius * 0.45,
      ),
      landPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: earthCenter + Offset(earthRadius * 0.27, earthRadius * 0.05),
        width: earthRadius * 0.54,
        height: earthRadius * 0.86,
      ),
      landPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: earthCenter + Offset(-earthRadius * 0.23, earthRadius * 0.38),
        width: earthRadius * 0.42,
        height: earthRadius * 0.28,
      ),
      landPaint,
    );

    final binRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.14,
        size.height * 0.46,
        size.width * 0.34,
        size.height * 0.42,
      ),
      const Radius.circular(8),
    );

    final binPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF629EFF), Color(0xFF1E57E6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(binRect.outerRect);

    canvas.drawRRect(binRect, binPaint);

    final lidPaint = Paint()..color = const Color(0xFF5D8DFF);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.4,
          size.width * 0.42,
          size.height * 0.08,
        ),
        const Radius.circular(4),
      ),
      lidPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.25,
          size.height * 0.31,
          size.width * 0.16,
          size.height * 0.1,
        ),
        const Radius.circular(4),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = const Color(0xFF7FAAFF),
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '♻',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(size.width * 0.24, size.height * 0.57));

    final leafPaint = Paint()..color = const Color(0xFF62B94E);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.93, size.height * 0.7),
        width: size.width * 0.14,
        height: size.height * 0.34,
      ),
      leafPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CuteEarthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.52);
    final radius = size.width * 0.38;

    final earthPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8EDBFF), Color(0xFF4AA3F1)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, earthPaint);

    final landPaint = Paint()..color = const Color(0xFF62BE5A);

    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-radius * 0.35, -radius * 0.15),
        width: radius * 0.75,
        height: radius * 0.45,
      ),
      landPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(radius * 0.25, radius * 0.1),
        width: radius * 0.5,
        height: radius * 0.75,
      ),
      landPaint,
    );

    final facePaint = Paint()..color = const Color(0xFF2F5B8C);

    canvas.drawCircle(
      center + Offset(-radius * 0.25, radius * 0.1),
      3,
      facePaint,
    );

    canvas.drawCircle(
      center + Offset(radius * 0.25, radius * 0.1),
      3,
      facePaint,
    );

    final mouthPaint = Paint()
      ..color = const Color(0xFF2F5B8C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCenter(
        center: center + Offset(0, radius * 0.18),
        width: 16,
        height: 10,
      ),
      0,
      3.14,
      false,
      mouthPaint,
    );

    final leafPaint = Paint()..color = const Color(0xFF56B84E);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.48, size.height * 0.08),
        width: 18,
        height: 38,
      ),
      leafPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.67, size.height * 0.16),
        width: 16,
        height: 34,
      ),
      leafPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final buildingPaint = Paint()..color = const Color(0xFFC6DDF5);
    final treePaint = Paint()..color = const Color(0xFF5DBB57);
    final groundPaint = Paint()..color = const Color(0xFFD8EFD5);

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.4,
        14,
        size.height * 0.6,
      ),
      buildingPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.26,
        size.height * 0.26,
        18,
        size.height * 0.74,
      ),
      buildingPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.5,
        size.height * 0.55,
        20,
        size.height * 0.45,
      ),
      buildingPaint,
    );

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.64, size.height * 0.52, 34, 36),
      treePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.77, size.height * 0.75, 4, 20),
      Paint()..color = const Color(0xFF8A6B3F),
    );

    canvas.drawOval(
      Rect.fromLTWH(0, size.height * 0.82, size.width, size.height * 0.35),
      groundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
