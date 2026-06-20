import 'package:flutter/material.dart';

import '../services/app_settings_service.dart';
import '../services/location_preference_service.dart';
import 'location_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _blue = Color(0xFF1688F8);
  static const Color _deepBlue = Color(0xFF0F7EEA);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textGray = Color(0xFF667085);

  final LocationPreferenceService _locationService =
      LocationPreferenceService();
  final AppSettingsService _settingsService = AppSettingsService();

  String? _regionName;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final regionName = await _locationService.loadRegionName();
    await _settingsService.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _regionName = regionName;
      _darkModeEnabled = AppSettingsService.darkModeEnabled.value;
    });
  }

  Future<void> _goToLocationSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationSettingsScreen()),
    );
    await _loadSettings();
  }

  Future<void> _setDarkModeEnabled(bool value) async {
    setState(() {
      _darkModeEnabled = value;
    });
    await _settingsService.saveDarkModeEnabled(value);
  }

  void _showInfoDialog(String title, String body) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          content: Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: _textGray,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, size: 31),
        ),
        title: const Text(
          '설정',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1688F8), Color(0xFF0F91FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
        child: Column(
          children: [
            const _SettingsHeroCard(),
            const SizedBox(height: 18),
            _SettingsSectionCard(
              title: '기본 설정',
              children: [
                _SettingsRow(
                  icon: Icons.location_on_outlined,
                  title: '내 지역',
                  value: _regionName ?? '지역 설정',
                  onTap: _goToLocationSettings,
                ),
                _SettingsDivider(),
                _SettingsRow(
                  icon: Icons.dark_mode_outlined,
                  title: '다크 모드',
                  trailing: Switch.adaptive(
                    value: _darkModeEnabled,
                    activeThumbColor: _blue,
                    onChanged: _setDarkModeEnabled,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SettingsSectionCard(
              title: '앱 정보',
              children: [
                _SettingsRow(
                  icon: Icons.shield_outlined,
                  title: '개인정보 처리방침',
                  onTap: () => _showInfoDialog(
                    '개인정보 처리방침',
                    '사진 인식과 검색 기능 제공을 위해 사용자가 선택한 이미지와 검색어가 AI 분석 요청에 사용될 수 있어요. 지역 설정과 최근 검색 기록은 기기 안에 저장됩니다.',
                  ),
                ),
                _SettingsDivider(),
                _SettingsRow(
                  icon: Icons.code_rounded,
                  title: '오픈소스 라이선스',
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: '이거 어디 버려?',
                    applicationVersion: '1.0.0',
                  ),
                ),
                _SettingsDivider(),
                const _SettingsRow(
                  icon: Icons.info_outline_rounded,
                  title: '앱 버전',
                  value: 'v1.0.0',
                  showChevron: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsHeroCard extends StatelessWidget {
  const _SettingsHeroCard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final badgeSize = isNarrow ? 72.0 : 86.0;
        final binSize = isNarrow ? 58.0 : 70.0;

        return Container(
          height: isNarrow ? 104 : 112,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.fromLTRB(isNarrow ? 14 : 18, 12, 16, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD5EAFB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _HeroBackgroundPainter()),
              ),
              Row(
                children: [
                  _HeroEarthBadge(size: badgeSize),
                  SizedBox(width: isNarrow ? 14 : 18),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '이거 어디 버려?',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '분리배출을 더 쉽게',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _SettingsScreenState._textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isNarrow ? 8 : 14),
                  CustomPaint(
                    size: Size(binSize, binSize),
                    painter: _HeroBinPainter(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroEarthBadge extends StatelessWidget {
  const _HeroEarthBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: size * 0.22,
            top: size * 0.34,
            child: Container(
              width: size * 0.51,
              height: size * 0.51,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF8EDBFF), Color(0xFF4AA3F1)],
                ),
              ),
            ),
          ),
          Positioned(
            left: size * 0.13,
            top: size * 0.4,
            child: Container(
              width: size * 0.32,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: const Color(0xFF65BE5B),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Positioned(
            right: size * 0.15,
            top: size * 0.25,
            child: Icon(
              Icons.eco_rounded,
              color: const Color(0xFF4DBB50),
              size: size * 0.29,
            ),
          ),
          Positioned(
            right: size * 0.14,
            bottom: size * 0.15,
            child: Container(
              width: size * 0.37,
              height: size * 0.37,
              decoration: const BoxDecoration(
                color: Color(0xFF22B579),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.recycling_rounded,
                color: Colors.white,
                size: size * 0.26,
              ),
            ),
          ),
          Positioned(
            left: size * 0.37,
            top: size * 0.59,
            child: const _FaceDot(),
          ),
          Positioned(
            left: size * 0.58,
            top: size * 0.59,
            child: const _FaceDot(),
          ),
        ],
      ),
    );
  }
}

class _FaceDot extends StatelessWidget {
  const _FaceDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Color(0xFF173F61),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EDF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.065),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: _SettingsScreenState._deepBlue,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.value,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Row(
        children: [
          _IconBox(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _SettingsScreenState._textDark,
              ),
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _SettingsScreenState._textGray,
                ),
              ),
            ),
          ],
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ] else if (showChevron && onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: Color(0xFF6B7280),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: row,
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 23, color: _SettingsScreenState._blue),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 52),
      color: const Color(0xFFE5EAF1),
    );
  }
}

class _HeroBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cityPaint = Paint()..color = const Color(0xFFBDE7FB);
    final leafPaint = Paint()..color = const Color(0xFF67C982);
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);

    for (final x in [size.width * 0.68, size.width * 0.78, size.width * 0.91]) {
      canvas.drawRect(
        Rect.fromLTWH(x, size.height * 0.54, 12, size.height * 0.34),
        cityPaint,
      );
    }

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.64, size.height * 0.78, 120, 48),
      Paint()..color = const Color(0xFFBDEBC5),
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.84, size.height * 0.62, 50, 84),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.72, size.height * 0.78, 38, 54),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.64, size.height * 0.12, 38, 18),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.86, size.height * 0.08, 50, 22),
      cloudPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroBinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.23,
        size.width * 0.62,
        size.height * 0.68,
      ),
      const Radius.circular(7),
    );
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1DA3FF), Color(0xFF0976DB)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bodyRect.outerRect);

    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.12,
          size.height * 0.16,
          size.width * 0.74,
          size.height * 0.13,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF138EF2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.32,
          size.height * 0.06,
          size.width * 0.34,
          size.height * 0.12,
        ),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF0D76D7),
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '♻',
        style: TextStyle(
          fontSize: 31,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(size.width * 0.33, size.height * 0.43));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
