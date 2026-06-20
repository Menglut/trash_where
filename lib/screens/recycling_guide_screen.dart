import 'package:flutter/material.dart';

class RecyclingGuideScreen extends StatelessWidget {
  const RecyclingGuideScreen({super.key});

  static const Color _blue = Color(0xFF1F6BFF);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textGray = Color(0xFF667085);

  static const List<_GuideItem> _guideItems = [
    _GuideItem(
      icon: Icons.description_outlined,
      title: '종이류',
      disposal: '물기와 이물질을 제거한 뒤 종이류로 배출',
      tips: ['테이프, 송장, 코팅지는 제거하세요.', '기름 묻은 종이는 일반쓰레기가 더 안전해요.'],
      color: Color(0xFF4E8DF5),
    ),
    _GuideItem(
      icon: Icons.local_drink_outlined,
      title: '플라스틱',
      disposal: '내용물을 비우고 헹군 뒤 라벨과 뚜껑을 분리',
      tips: ['재질 표시를 확인하세요.', '오염이 심하면 일반쓰레기로 배출하세요.'],
      color: Color(0xFF27A4F2),
    ),
    _GuideItem(
      icon: Icons.inventory_2_outlined,
      title: '비닐류',
      disposal: '깨끗한 비닐만 모아서 비닐류로 배출',
      tips: ['음식물, 기름, 양념이 묻은 비닐은 일반쓰레기예요.', '여러 재질이 붙은 포장은 분리가 어려울 수 있어요.'],
      color: Color(0xFF8B7CF6),
    ),
    _GuideItem(
      icon: Icons.recycling_rounded,
      title: '캔·고철',
      disposal: '내용물을 비우고 가능한 압착해서 배출',
      tips: ['부탄가스, 스프레이 캔은 구멍을 뚫지 말고 지자체 안내를 확인하세요.', '캔 안에 담배꽁초를 넣지 마세요.'],
      color: Color(0xFF64748B),
    ),
    _GuideItem(
      icon: Icons.wine_bar_outlined,
      title: '유리병',
      disposal: '병 안을 비우고 뚜껑을 분리한 뒤 배출',
      tips: ['깨진 유리는 신문지 등으로 감싸 일반쓰레기로 배출하세요.', '도자기, 거울, 전구는 유리병류가 아니에요.'],
      color: Color(0xFF20A983),
    ),
    _GuideItem(
      icon: Icons.battery_4_bar_rounded,
      title: '폐건전지·소형 전자',
      disposal: '전용 수거함이나 주민센터 수거함 이용',
      tips: ['일반 종량제봉투에 넣지 마세요.', '보조배터리는 화재 위험이 있어 별도 배출이 필요해요.'],
      color: Color(0xFFE5484D),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _GuideTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeaderSection(),
                    const SizedBox(height: 22),
                    const _RuleCard(),
                    const SizedBox(height: 18),
                    const _SectionTitle(title: '품목별 기본 가이드'),
                    const SizedBox(height: 12),
                    for (final item in _guideItems) ...[
                      _GuideItemCard(item: item),
                      const SizedBox(height: 12),
                    ],
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

class _GuideTopBar extends StatelessWidget {
  const _GuideTopBar();

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
            '분리배출 가이드',
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
          '헷갈리는 배출 기준을\n한눈에 확인해요',
          style: TextStyle(
            fontSize: 34,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: RecyclingGuideScreen._textDark,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '사진 인식이나 직접 검색 전에 기본 기준을 빠르게 확인할 수 있어요.',
          style: TextStyle(
            fontSize: 15.5,
            height: 1.45,
            fontWeight: FontWeight.w600,
            color: RecyclingGuideScreen._textGray,
          ),
        ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard();

  @override
  Widget build(BuildContext context) {
    return const _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 26,
                color: RecyclingGuideScreen._blue,
              ),
              SizedBox(width: 10),
              Text(
                '기본 원칙',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: RecyclingGuideScreen._textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _RuleText(text: '내용물을 비우고, 가능한 한 헹군 뒤 배출해요.'),
          _RuleText(text: '라벨, 뚜껑, 테이프처럼 다른 재질은 분리해요.'),
          _RuleText(text: '오염이 심하거나 재질이 섞여 있으면 일반쓰레기일 수 있어요.'),
        ],
      ),
    );
  }
}

class _RuleText extends StatelessWidget {
  const _RuleText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(top: 9),
            decoration: const BoxDecoration(
              color: RecyclingGuideScreen._blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: RecyclingGuideScreen._textGray,
              ),
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
        color: RecyclingGuideScreen._textDark,
      ),
    );
  }
}

class _GuideItemCard extends StatelessWidget {
  const _GuideItemCard({required this.item});

  final _GuideItem item;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 28, color: item.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: RecyclingGuideScreen._textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.disposal,
                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: RecyclingGuideScreen._textDark,
                  ),
                ),
                const SizedBox(height: 10),
                for (final tip in item.tips)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '- $tip',
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: RecyclingGuideScreen._textGray,
                      ),
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

class _NoticeCard extends StatelessWidget {
  const _NoticeCard();

  @override
  Widget build(BuildContext context) {
    return const _WhiteCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 26, color: Color(0xFF8F98A8)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '세부 기준과 배출 요일은 지역마다 다를 수 있어요. 앱의 지역 설정에 저장한 배출일도 함께 확인해 주세요.',
              style: TextStyle(
                fontSize: 14.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: RecyclingGuideScreen._textGray,
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

class _GuideItem {
  const _GuideItem({
    required this.icon,
    required this.title,
    required this.disposal,
    required this.tips,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String disposal;
  final List<String> tips;
  final Color color;
}
