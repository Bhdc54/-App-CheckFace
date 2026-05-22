import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = AppColorHelper.textSecondary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: CustomPaint(
                painter: _CheckFaceLogoPainter(isDark: isDark),
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                colors: [AppColors.blue, AppColors.purple],
              ).createShader(rect),
              child: const Text(
                'CHECKFACE',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Controle de Acesso',
              style: TextStyle(fontSize: 12, color: secondaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckFaceLogoPainter extends CustomPainter {
  final bool isDark;
  const _CheckFaceLogoPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final center = Offset(cx, cy);
    final rect = Offset.zero & size;

    final colorA = isDark ? const Color(0xFF00A3FF) : const Color(0xFF0077EE);
    final colorB = isDark ? const Color(0xFF7C3AED) : const Color(0xFF6D28D9);

    canvas.drawCircle(
      center, size.width * 0.48,
      Paint()
        ..color = colorA.withOpacity(0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    canvas.drawCircle(
      center, size.width * 0.40,
      Paint()
        ..color = colorA.withOpacity(0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colorA, colorB],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, size.width * 0.32, borderPaint);

    final gradShader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [colorA, colorB],
    ).createShader(rect);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.20),
      0.45, 5.38, false,
      Paint()
        ..shader = gradShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.030
        ..strokeCap = StrokeCap.round,
    );

    final eyePaint = Paint()
      ..shader = gradShader
      ..style = PaintingStyle.fill;
    final eyeR = size.width * 0.028;
    canvas.drawCircle(
        Offset(cx - size.width * 0.065, cy - size.height * 0.04), eyeR, eyePaint);
    canvas.drawCircle(
        Offset(cx + size.width * 0.065, cy - size.height * 0.04), eyeR, eyePaint);

    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(cx, cy + size.height * 0.02),
          radius: size.width * 0.075),
      0.2, 2.75, false,
      Paint()
        ..shader = gradShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.028
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CheckFaceLogoPainter old) => old.isDark != isDark;
}