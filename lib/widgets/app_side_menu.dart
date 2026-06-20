import 'package:flutter/material.dart';

import '../screens/ai_recognition_screen.dart';
import '../screens/location_settings_screen.dart';
import '../screens/recycling_guide_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../services/location_preference_service.dart';

void showAppSideMenu(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'menu',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _SideMenuDialog();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

class _SideMenuDialog extends StatelessWidget {
  const _SideMenuDialog();

  void _goHome(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.popUntil((route) => route.isFirst);
  }

  void _goTo(BuildContext context, Widget screen) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final menuWidth = screenWidth < 420 ? screenWidth * 0.86 : 360.0;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 메뉴 바깥 빈 공간 터치 시 닫기
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(color: Colors.transparent),
            ),
          ),

          // 왼쪽 메뉴 영역
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // 메뉴 내부를 눌렀을 때는 닫히지 않게 막음
              },
              child: Container(
                width: menuWidth,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFBFCFF),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(34),
                    bottomRight: Radius.circular(34),
                  ),
                ),
                child: SafeArea(
                  top: true,
                  bottom: true,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _MenuHeader(),

                        const SizedBox(height: 22),

                        const _LocationBox(),

                        const SizedBox(height: 28),

                        const _SectionTitle(title: '빠른 메뉴'),

                        const SizedBox(height: 12),

                        _MenuItem(
                          icon: Icons.home_outlined,
                          title: '홈',
                          isSelected: true,
                          onTap: () {
                            _goHome(context);
                          },
                        ),

                        const SizedBox(height: 12),

                        _MenuItem(
                          icon: Icons.camera_alt_rounded,
                          title: '사진으로 확인하기',
                          onTap: () {
                            _goTo(context, const AiRecognitionScreen());
                          },
                        ),

                        const SizedBox(height: 12),

                        _MenuItem(
                          icon: Icons.search_rounded,
                          title: '직접 검색하기',
                          onTap: () {
                            _goTo(context, const SearchScreen());
                          },
                        ),

                        const SizedBox(height: 12),

                        _MenuItem(
                          icon: Icons.access_time_rounded,
                          title: '최근 검색 기록',
                          onTap: () {
                            _goTo(context, const SearchScreen());
                          },
                        ),

                        const SizedBox(height: 12),

                        _MenuItem(
                          icon: Icons.location_on_outlined,
                          title: '내 지역 설정',
                          onTap: () {
                            _goTo(context, const LocationSettingsScreen());
                          },
                        ),

                        const SizedBox(height: 28),

                        const _SectionTitle(title: '도움말'),

                        const SizedBox(height: 12),

                        _MenuItem(
                          icon: Icons.menu_book_outlined,
                          title: '분리배출 가이드',
                          onTap: () {
                            _goTo(context, const RecyclingGuideScreen());
                          },
                        ),

                        const SizedBox(height: 12),

                        _MenuItem(
                          icon: Icons.settings_outlined,
                          title: '앱 설정',
                          onTap: () {
                            _goTo(context, const SettingsScreen());
                          },
                        ),

                        const SizedBox(height: 28),

                        const _BottomBanner(),

                        const SizedBox(height: 18),

                        const Center(
                          child: Text(
                            'v1.0.0',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9AA1AC),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _MiniEarthIcon(),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            '이거 어디 버려?',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F5BEA),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationBox extends StatelessWidget {
  const _LocationBox();

  @override
  Widget build(BuildContext context) {
    final locationService = LocationPreferenceService();

    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_on_rounded,
            size: 22,
            color: Color(0xFF1F5BEA),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FutureBuilder<String?>(
              future: locationService.loadRegionName(),
              builder: (context, snapshot) {
                final regionName = snapshot.data;
                return Text(
                  regionName == null || regionName.isEmpty
                      ? '현재 지역을 설정해 주세요'
                      : '현재 지역: $regionName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F5BEA),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFF1F5BEA),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Color(0xFF171717),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? const Color(0xFF1F6BFF) : Colors.white;

    final contentColor = isSelected ? Colors.white : const Color(0xFF162A56);

    final arrowColor = isSelected ? Colors.white : const Color(0xFF111111);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 27, color: contentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF202020),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, size: 28, color: arrowColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBanner extends StatelessWidget {
  const _BottomBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD5E8FF), width: 1.1),
      ),
      child: Row(
        children: [
          const _CuteEarth(),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '올바른 분리배출로\n지구를 지켜요 🌱',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                height: 1.32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F5BEA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniEarthIcon extends StatelessWidget {
  const _MiniEarthIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 18,
            top: 2,
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF88D7FF), Color(0xFF4C9FF2)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 34,
            top: 10,
            child: Container(
              width: 22,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF68BF59),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            left: 2,
            top: 30,
            child: Icon(
              Icons.delete_rounded,
              size: 36,
              color: const Color(0xFF2F7BFF),
            ),
          ),
          Positioned(
            right: -2,
            bottom: 4,
            child: Transform.rotate(
              angle: -0.5,
              child: const Icon(
                Icons.eco_rounded,
                size: 30,
                color: Color(0xFF57B957),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CuteEarth extends StatelessWidget {
  const _CuteEarth();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 78,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF8EDBFF), Color(0xFF4AA3F1)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 22,
            child: Container(
              width: 28,
              height: 17,
              decoration: BoxDecoration(
                color: const Color(0xFF65BE5B),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 16,
            child: Container(
              width: 23,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF65BE5B),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const Positioned(left: 23, top: 40, child: _FaceDot()),
          const Positioned(right: 23, top: 40, child: _FaceDot()),
          Positioned(
            left: 36,
            top: 48,
            child: Container(
              width: 10,
              height: 5,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF2F5B8C), width: 2),
                ),
              ),
            ),
          ),
          Positioned(
            top: -10,
            left: 24,
            child: Transform.rotate(
              angle: -0.4,
              child: const Icon(
                Icons.eco_rounded,
                size: 34,
                color: Color(0xFF58B957),
              ),
            ),
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
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: Color(0xFF2F5B8C),
        shape: BoxShape.circle,
      ),
    );
  }
}
