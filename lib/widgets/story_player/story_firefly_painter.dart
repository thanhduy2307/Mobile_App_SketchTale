import 'package:flutter/material.dart';

/// Particle model for glowing fireflies
class FireflyParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double life;
  double maxLife;
  Color color;

  FireflyParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.size = 4.0,
    required this.color,
    num? life,
    num? maxLife,
  })  : maxLife = (maxLife ?? 1.0).toDouble(),
        life = (life ?? maxLife ?? 1.0).toDouble();

  void update() {
    x += vx;
    y += vy;
    life -= 0.02;
  }
}

/// Custom painter for rendering magical glowing fireflies on canvas
class FireflyCanvasPainter extends CustomPainter {
  final List<FireflyParticle> particles;

  FireflyCanvasPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.life <= 0) continue;
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.life * 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      final center = Offset(p.x * size.width, p.y * size.height);
      canvas.drawCircle(center, p.size * (1.0 + (1.0 - p.life)), paint);

      final corePaint = Paint()..color = Colors.white.withValues(alpha: p.life);
      canvas.drawCircle(center, p.size * 0.4, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant FireflyCanvasPainter oldDelegate) => true;
}
