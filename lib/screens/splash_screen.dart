import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinnerController;

  @override
  void initState() {
    super.initState();
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat();
    _goHome();
  }

  Future<void> _goHome() async {
    await Future<void>.delayed(const Duration(milliseconds: 2300));
    if (!mounted) {
      return;
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 360),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _spinnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFFEAF7FF),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _SplashBackground()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final height = constraints.maxHeight;
                  final width = constraints.maxWidth;
                  final isCompact = height < 720;
                  final isVeryCompact = height < 640;
                  final heroSize = math.min(
                    width * 0.74,
                    isVeryCompact
                        ? 226.0
                        : isCompact
                            ? 270.0
                            : 330.0,
                  );
                  final topGap = math.max(
                    isVeryCompact ? 14.0 : 24.0,
                    height * (isVeryCompact ? 0.035 : 0.055),
                  );
                  final titleGap = isVeryCompact
                      ? 12.0
                      : isCompact
                          ? 18.0
                          : 24.0;
                  final loadingGap = isVeryCompact
                      ? 18.0
                      : isCompact
                          ? 28.0
                          : 48.0;
                  final bottomGap = math.max(
                    isVeryCompact ? 12.0 : 20.0,
                    height * 0.035,
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        SizedBox(height: topGap),
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              'assets/images/splash_hero.png',
                              width: heroSize,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        SizedBox(height: titleGap),
                        _SplashTitle(
                          titleSize: isVeryCompact
                              ? 32
                              : isCompact
                                  ? 37
                                  : 42,
                          subtitleSize: isVeryCompact ? 15 : 18,
                        ),
                        SizedBox(height: loadingGap),
                        _LoadingStatus(controller: _spinnerController),
                        SizedBox(height: bottomGap),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashTitle extends StatelessWidget {
  const _SplashTitle({
    required this.titleSize,
    required this.subtitleSize,
  });

  final double titleSize;
  final double subtitleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '이거 어디 버려?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleSize,
            height: 1.12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1356D9),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'AI로 쉽게 확인하는 분리배출',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64708A),
          ),
        ),
      ],
    );
  }
}

class _LoadingStatus extends StatelessWidget {
  const _LoadingStatus({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RotationTransition(
          turns: controller,
          child: CustomPaint(
            size: const Size(44, 44),
            painter: _LoadingDotsPainter(),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          '앱을 준비하고 있어요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1356D9),
          ),
        ),
      ],
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SplashBackgroundPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9FDFF), Color(0xFFE8F7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  const _SplashBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.86);
    final softBlue = Paint()..color = const Color(0xFFD8EEFF);
    final hillPaint = Paint()..color = const Color(0xFFCFEFCC);
    final hillPaint2 = Paint()..color = const Color(0xFFBFE6B2);
    final cityPaint = Paint()..color = const Color(0xFFD8ECFF);
    final riverPaint = Paint()..color = const Color(0xFFBEE4FF);

    _drawCloud(
      canvas,
      Offset(size.width * 0.12, size.height * 0.34),
      68,
      cloudPaint,
    );
    _drawCloud(
      canvas,
      Offset(size.width * 0.78, size.height * 0.22),
      48,
      cloudPaint,
    );

    _drawLeaf(canvas, Offset(size.width * 0.22, size.height * 0.22), -0.7, 28);
    _drawLeaf(canvas, Offset(size.width * 0.72, size.height * 0.18), 0.7, 22);
    _drawLeaf(canvas, Offset(size.width * 0.2, size.height * 0.78), 0.65, 25);
    _drawLeaf(canvas, Offset(size.width * 0.88, size.height * 0.72), -0.5, 34);

    final cityBase = size.height * 0.86;
    for (var i = 0; i < 8; i++) {
      final left = size.width * (0.06 + i * 0.12);
      final buildingHeight = size.height * (0.05 + (i % 3) * 0.025);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left,
            cityBase - buildingHeight,
            size.width * 0.06,
            buildingHeight,
          ),
          const Radius.circular(3),
        ),
        cityPaint,
      );
    }

    canvas.drawOval(
      Rect.fromLTWH(
        -size.width * 0.1,
        size.height * 0.86,
        size.width * 0.75,
        size.height * 0.18,
      ),
      hillPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.42,
        size.height * 0.84,
        size.width * 0.76,
        size.height * 0.2,
      ),
      hillPaint2,
    );

    final riverPath = Path()
      ..moveTo(size.width * 0.42, size.height)
      ..cubicTo(
        size.width * 0.52,
        size.height * 0.94,
        size.width * 0.4,
        size.height * 0.91,
        size.width * 0.5,
        size.height * 0.87,
      )
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.84,
        size.width * 0.47,
        size.height * 0.82,
        size.width * 0.54,
        size.height * 0.79,
      )
      ..lineTo(size.width * 0.6, size.height)
      ..close();
    canvas.drawPath(riverPath, riverPaint);

    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.88),
      22,
      Paint()..color = const Color(0xFF77BE72),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.575, size.height * 0.88, 6, 48),
      Paint()..color = const Color(0xFF9D8A63),
    );

    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.36,
        size.height * 0.92,
        size.width * 0.2,
        size.height * 0.05,
      ),
      softBlue,
    );
  }

  void _drawCloud(Canvas canvas, Offset center, double width, Paint paint) {
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: width * 0.32),
      paint,
    );
    canvas.drawCircle(
      center + Offset(-width * 0.2, -width * 0.08),
      width * 0.18,
      paint,
    );
    canvas.drawCircle(
      center + Offset(width * 0.03, -width * 0.16),
      width * 0.23,
      paint,
    );
    canvas.drawCircle(
      center + Offset(width * 0.25, -width * 0.09),
      width * 0.17,
      paint,
    );
  }

  void _drawLeaf(Canvas canvas, Offset center, double angle, double size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB9F171), Color(0xFF61BF42)],
      ).createShader(Rect.fromCircle(center: center, radius: size));
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size * 0.68, height: size),
      paint,
    );
    canvas.drawLine(
      Offset.zero,
      Offset(0, size * 0.35),
      Paint()
        ..color = const Color(0xFF54A735)
        ..strokeWidth = 1.4,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoadingDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.34;

    for (var i = 0; i < 10; i++) {
      final progress = i / 10;
      final angle = (math.pi * 2 * progress) - math.pi / 2;
      final dotCenter = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final opacity = 0.18 + progress * 0.82;
      final dotSize = 3.5 + progress * 1.6;
      canvas.drawCircle(
        dotCenter,
        dotSize,
        Paint()..color = const Color(0xFF1F6BFF).withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
