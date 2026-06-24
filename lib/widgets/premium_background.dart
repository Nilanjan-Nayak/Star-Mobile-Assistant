import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

// ═══════════════════════════════════════════════════════════════
// DATA MODELS - Cosmic & AI Elements
// ═══════════════════════════════════════════════════════════════

/// Background star field with depth and optional color halo
class CosmicStar {
  final double x;
  final double y;
  final double size;
  final double brightness;
  final Color color;
  final double depth; // 0.0 (far) to 1.0 (near)
  final double twinklePhase;
  final double twinkleSpeed;
  final bool hasHalo;
  final Color haloColor;

  CosmicStar({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
    required this.color,
    required this.depth,
    required this.twinklePhase,
    required this.twinkleSpeed,
    this.hasHalo = false,
    this.haloColor = Colors.transparent,
  });
}

/// Nebula gas cloud with multi-layered rendering
class NebulaCloud {
  final double x;
  final double y;
  final double radius;
  final List<Color> colors;
  final double rotation;
  final double density;
  final double animationSpeed;

  NebulaCloud({
    required this.x,
    required this.y,
    required this.radius,
    required this.colors,
    required this.rotation,
    required this.density,
    required this.animationSpeed,
  });
}

/// AI Neural network node
class NeuralNode {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double size;
  final double pulsePhase;
  final double energy; // 0.0 to 1.0

  NeuralNode({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.pulsePhase,
    required this.energy,
  });
}

/// Data stream particle (AI visualization)
class DataParticle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double speed;
  final double delay;
  final Color color;
  final double size;

  DataParticle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.speed,
    required this.delay,
    required this.color,
    required this.size,
  });
}

/// Cosmic dust particle with parallax
class DustParticle {
  final double x;
  final double y;
  final double size;
  final double depth;
  final double driftSpeed;
  final double angle;

  DustParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.depth,
    required this.driftSpeed,
    required this.angle,
  });
}

/// Photorealistic shooting star
class ShootingStar {
  final double startX;
  final double startY;
  final double angle;
  final double speed;
  final double length;
  final double thickness;
  final double startTime;
  final double lifetime;

  ShootingStar({
    required this.startX,
    required this.startY,
    required this.angle,
    required this.speed,
    required this.length,
    required this.thickness,
    required this.startTime,
    required this.lifetime,
  });
}

// ═══════════════════════════════════════════════════════════════
// MAIN BACKGROUND WIDGET
// ═══════════════════════════════════════════════════════════════

class PremiumDarkBackground extends StatefulWidget {
  final AnimationController rotationController;
  final AnimationController particleController;
  final bool isChatView;

  const PremiumDarkBackground({
    super.key,
    required this.rotationController,
    required this.particleController,
    this.isChatView = false,
  });

  @override
  State<PremiumDarkBackground> createState() => PremiumDarkBackgroundState();
}

class PremiumDarkBackgroundState extends State<PremiumDarkBackground> {
  late List<CosmicStar> _stars;
  late List<NebulaCloud> _nebulae;
  late List<NeuralNode> _nodes;
  late List<DataParticle> _dataStreams;
  late List<DustParticle> _dust;
  late List<ShootingStar> _shootingStars;

  Offset? _currentWarpCenter;
  Offset? _targetWarpCenter;

  void updateTargetWarpCenter(Offset? pos) {
    _targetWarpCenter = pos;
  }

  void _updateWarpCenter() {
    if (!mounted) return;
    if (_targetWarpCenter == null) {
      if (_currentWarpCenter != null) {
        final defaultCenter = Offset(
          MediaQuery.of(context).size.width * 0.5,
          MediaQuery.of(context).size.height * 0.45,
        );
        final dist = (_currentWarpCenter! - defaultCenter).distance;
        if (dist < 1.0) {
          setState(() {
            _currentWarpCenter = null;
          });
        } else {
          setState(() {
            _currentWarpCenter = Offset.lerp(_currentWarpCenter, defaultCenter, 0.08);
          });
        }
      }
    } else {
      setState(() {
        _currentWarpCenter = Offset.lerp(
          _currentWarpCenter ?? Offset(
            MediaQuery.of(context).size.width * 0.5,
            MediaQuery.of(context).size.height * 0.45,
          ),
          _targetWarpCenter,
          0.08,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeUniverse();
    widget.rotationController.addListener(_updateWarpCenter);
  }

  void _initializeUniverse() {
    final random = math.Random(42); // Deterministic seed for consistency

    // ────────────────────────────────────────────────
    // 1. STAR FIELD - Multiple depth layers with color halos
    // ────────────────────────────────────────────────
    _stars = List.generate(300, (i) {
      final depth = math.pow(random.nextDouble(), 2.0).toDouble(); // More far stars
      
      // Realistic star core colors based on temperature
      Color starColor;
      final colorRand = random.nextDouble();
      if (colorRand < 0.6) {
        starColor = const Color(0xFFFFFFFF); // White
      } else if (colorRand < 0.8) {
        starColor = const Color(0xFFAABBFF); // Blue (hot stars)
      } else if (colorRand < 0.93) {
        starColor = const Color(0xFFFFDDAA); // Orange (cool stars)
      } else {
        starColor = const Color(0xFFFFAAAA); // Red giants
      }

      // Bright stars (first 15) get spectacular pulsing color halos
      final hasHalo = i < 15;
      Color haloColor = Colors.transparent;
      if (hasHalo) {
        final haloRand = random.nextInt(5);
        switch (haloRand) {
          case 0:
            haloColor = const Color(0xFF80DEEA); // Soft Ice Teal
            break;
          case 1:
            haloColor = const Color(0xFF90A4AE); // Soft Ice Blue-gray
            break;
          case 2:
            haloColor = const Color(0xFF9FA8DA); // Soft Slate Blue
            break;
          case 3:
            haloColor = const Color(0xFFB3E5FC); // Soft Sky Blue
            break;
          case 4:
            haloColor = const Color(0xFFC5CAE9); // Soft Indigo
            break;
        }
      }

      return CosmicStar(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: (random.nextDouble() * 1.4 + 0.3) * (depth * 0.4 + 0.6),
        brightness: random.nextDouble() * 0.8 + 0.2,
        color: starColor,
        depth: depth,
        twinklePhase: random.nextDouble() * math.pi * 2,
        twinkleSpeed: random.nextDouble() * 0.5 + 0.2,
        hasHalo: hasHalo,
        haloColor: haloColor,
      );
    });

    // ────────────────────────────────────────────────
    // 2. NEBULA CLOUDS - Photorealistic gas formations
    // ────────────────────────────────────────────────
    _nebulae = [
      NebulaCloud(
        x: 0.28,
        y: 0.35,
        radius: 0.55,
        colors: [
          const Color(0xFF0C1033).withOpacity(0.1), // Deep space navy
          const Color(0xFF050820).withOpacity(0.05),
          const Color(0xFF01020A).withOpacity(0.0),
        ],
        rotation: 0.3,
        density: 0.75,
        animationSpeed: 0.08,
      ),
      NebulaCloud(
        x: 0.72,
        y: 0.58,
        radius: 0.5,
        colors: [
          const Color(0xFF140A24).withOpacity(0.06), // Soft amethyst purple
          const Color(0xFF0D0518).withOpacity(0.03),
          const Color(0xFF05010B).withOpacity(0.0),
        ],
        rotation: -0.4,
        density: 0.65,
        animationSpeed: 0.06,
      ),
      NebulaCloud(
        x: 0.5,
        y: 0.48,
        radius: 0.4,
        colors: [
          const Color(0xFF04181F).withOpacity(0.05), // Soft deep teal
          const Color(0xFF021014).withOpacity(0.02),
          const Color(0xFF000508).withOpacity(0.0),
        ],
        rotation: 0.1,
        density: 0.55,
        animationSpeed: 0.05,
      ),
      // Obscuring dark dust nebula for cosmic realism
      NebulaCloud(
        x: 0.45,
        y: 0.52,
        radius: 0.35,
        colors: [
          const Color(0xFF000000).withOpacity(0.3),
          const Color(0xFF000000).withOpacity(0.12),
          const Color(0xFF000000).withOpacity(0.0),
        ],
        rotation: 0.2,
        density: 0.8,
        animationSpeed: 0.04,
      ),
    ];

    // ────────────────────────────────────────────────
    // 3. COSMIC DUST - Parallax drifting particles
    // ────────────────────────────────────────────────
    _dust = List.generate(120, (i) {
      final depth = random.nextDouble();
      return DustParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 0.8 + 0.2,
        depth: depth,
        driftSpeed: (1.0 - depth) * 0.015,
        angle: random.nextDouble() * math.pi * 2,
      );
    });

    // ────────────────────────────────────────────────
    // 4. NEURAL NETWORK NODES (AI Theme)
    // ────────────────────────────────────────────────
    _nodes = List.generate(15, (i) {
      return NeuralNode(
        x: random.nextDouble(),
        y: random.nextDouble(),
        vx: (random.nextDouble() - 0.5) * 0.005,
        vy: (random.nextDouble() - 0.5) * 0.005,
        size: random.nextDouble() * 2.2 + 1.2,
        pulsePhase: random.nextDouble() * math.pi * 2,
        energy: random.nextDouble() * 0.4 + 0.6,
      );
    });

    // ────────────────────────────────────────────────
    // 5. DATA STREAMS (AI Data Flow Trails)
    // ────────────────────────────────────────────────
    _dataStreams = List.generate(20, (i) {
      final startX = random.nextDouble();
      final startY = random.nextDouble();
      final angle = random.nextDouble() * math.pi * 2;
      final length = random.nextDouble() * 0.25 + 0.15;
      
      return DataParticle(
        startX: startX,
        startY: startY,
        endX: startX + math.cos(angle) * length,
        endY: startY + math.sin(angle) * length,
        speed: random.nextDouble() * 0.4 + 0.3,
        delay: random.nextDouble(),
        color: i % 2 == 0
            ? const Color(0xFF80DEEA) // Soft ice teal
            : const Color(0xFF9FA8DA), // Soft slate blue
        size: random.nextDouble() * 1.3 + 0.5,
      );
    });

    // ────────────────────────────────────────────────
    // 6. SHOOTING STARS (Comets)
    // ────────────────────────────────────────────────
    _shootingStars = [
      ShootingStar(
        startX: 0.1,
        startY: 0.15,
        angle: math.pi / 4,
        speed: 1.1,
        length: 0.16,
        thickness: 1.8,
        startTime: 0.1,
        lifetime: 0.14,
      ),
      ShootingStar(
        startX: 0.85,
        startY: 0.25,
        angle: 3 * math.pi / 4,
        speed: 0.95,
        length: 0.14,
        thickness: 1.6,
        startTime: 0.45,
        lifetime: 0.12,
      ),
      ShootingStar(
        startX: 0.25,
        startY: 0.7,
        angle: -math.pi / 6,
        speed: 1.05,
        length: 0.18,
        thickness: 2.0,
        startTime: 0.75,
        lifetime: 0.16,
      ),
    ];
  }

  @override
  void didUpdateWidget(PremiumDarkBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rotationController != widget.rotationController) {
      oldWidget.rotationController.removeListener(_updateWarpCenter);
      widget.rotationController.addListener(_updateWarpCenter);
    }
  }

  @override
  void dispose() {
    widget.rotationController.removeListener(_updateWarpCenter);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isChatView) {
      // ═══════════════════════════════════════════════
      // HOME SCREEN - Elegant Minimalist Version
      // ═══════════════════════════════════════════════
      return Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0E27),
                  Color(0xFF000000),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: widget.rotationController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: MinimalAmbientPainter(
                  animation: widget.rotationController.value,
                ),
              );
            },
          ),
          ...List.generate(8, (i) {
            final random = math.Random(i * 77);
            return AnimatedFloatingParticle(
              animation: widget.particleController,
              delay: i * 0.15,
              initialPosition: Offset(
                random.nextDouble() * MediaQuery.of(context).size.width,
                random.nextDouble() * MediaQuery.of(context).size.height,
              ),
            );
          }),
        ],
      );
    }

    // ═══════════════════════════════════════════════
    // CHAT SCREEN - Full AI Universe Experience
    // ═══════════════════════════════════════════════
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.rotationController,
        widget.particleController,
      ]),
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: AIUniversePainter(
            time: widget.rotationController.value,
            particleTime: widget.particleController.value,
            stars: _stars,
            nebulae: _nebulae,
            nodes: _nodes,
            dataStreams: _dataStreams,
            dust: _dust,
            shootingStars: _shootingStars,
            customWarpCenter: _currentWarpCenter,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HOME SCREEN PAINTER - Minimal & Elegant
// ═══════════════════════════════════════════════════════════════

class MinimalAmbientPainter extends CustomPainter {
  final double animation;

  MinimalAmbientPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final time = animation * 2 * math.pi;

    // Ambient glow orb 1
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0B2466).withOpacity(0.08),
          const Color(0xFF0B2466).withOpacity(0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width * 0.25 + math.sin(time * 0.5) * 40,
          size.height * 0.3 + math.cos(time * 0.5) * 50,
        ),
        radius: 220,
      ))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    canvas.drawCircle(
      Offset(
        size.width * 0.25 + math.sin(time * 0.5) * 40,
        size.height * 0.3 + math.cos(time * 0.5) * 50,
      ),
      220,
      paint1,
    );

    // Ambient glow orb 2
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF280B52).withOpacity(0.07),
          const Color(0xFF280B52).withOpacity(0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width * 0.75 + math.cos(time * 0.6) * 50,
          size.height * 0.65 + math.sin(time * 0.6) * 40,
        ),
        radius: 200,
      ))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    canvas.drawCircle(
      Offset(
        size.width * 0.75 + math.cos(time * 0.6) * 50,
        size.height * 0.65 + math.sin(time * 0.6) * 40,
      ),
      200,
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant MinimalAmbientPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// ═══════════════════════════════════════════════════════════════
// HOME SCREEN FLOATING PARTICLE
// ═══════════════════════════════════════════════════════════════

class AnimatedFloatingParticle extends StatelessWidget {
  final Animation<double> animation;
  final double delay;
  final Offset initialPosition;

  const AnimatedFloatingParticle({
    super.key,
    required this.animation,
    required this.delay,
    required this.initialPosition,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = ((animation.value + delay) % 1.0);
        final yOffset = MediaQuery.of(context).size.height * progress;
        final opacity = (1.0 - progress) * 0.6;

        return Positioned(
          left: initialPosition.dx + math.sin(progress * math.pi * 4) * 25,
          top: initialPosition.dy - yOffset,
          child: Container(
            width: 2.5,
            height: 2.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withOpacity(opacity),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(opacity * 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CHAT SCREEN PAINTER - Photorealistic AI Universe
// ═══════════════════════════════════════════════════════════════

class AIUniversePainter extends CustomPainter {
  final double time;
  final double particleTime;
  final List<CosmicStar> stars;
  final List<NebulaCloud> nebulae;
  final List<NeuralNode> nodes;
  final List<DataParticle> dataStreams;
  final List<DustParticle> dust;
  final List<ShootingStar> shootingStars;
  final Offset? customWarpCenter;

  AIUniversePainter({
    required this.time,
    required this.particleTime,
    required this.stars,
    required this.nebulae,
    required this.nodes,
    required this.dataStreams,
    required this.dust,
    required this.shootingStars,
    this.customWarpCenter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Deep Space Gradient Base
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF000428), // Deep cosmic blue
          Color(0xFF000000), // Pure black
          Color(0xFF000315), // Deep dark tint
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Nebula Gas Clouds
    for (final nebula in nebulae) {
      _drawNebula(canvas, size, nebula);
    }

    // 2.5. Aurora Borealis waving curtains
    _drawAurora(canvas, size);

    // 3. Cosmic Dust with Parallax
    final dustPaint = Paint()..style = PaintingStyle.fill;
    for (final particle in dust) {
      final x = ((particle.x + math.cos(particle.angle) * particle.driftSpeed * time * 10) % 1.0) * size.width;
      final y = ((particle.y + math.sin(particle.angle) * particle.driftSpeed * time * 10) % 1.0) * size.height;
      
      final opacity = 0.04 + particle.depth * 0.08;
      dustPaint.color = const Color(0xFFB0BEC5).withOpacity(opacity);
      canvas.drawCircle(
        Offset(x, y),
        particle.size * (0.5 + particle.depth * 0.5),
        dustPaint,
      );
    }

    // 4. Background Star Field (Depth Sorted)
    final starPaint = Paint()..style = PaintingStyle.fill;
    final starGlowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final sortedStars = List<CosmicStar>.from(stars)
      ..sort((a, b) => a.depth.compareTo(b.depth));

    for (final star in sortedStars) {
      final x = star.x * size.width;
      final y = star.y * size.height;
      
      // Dynamic Twinkling
      final twinkle = math.sin(time * math.pi * 2 * star.twinkleSpeed + star.twinklePhase);
      final brightness = (star.brightness * (0.6 + twinkle * 0.4)).clamp(0.0, 1.0);
      
      // Draw pulsing colorful soft halo for primary stars
      if (star.hasHalo && brightness > 0.4) {
        final double pulse = 0.5 + 0.5 * math.sin(time * math.pi * 3 * star.twinkleSpeed + star.twinklePhase);
        final double haloRadius = star.size * (11.0 + pulse * 5.0);
        final double haloOpacity = (0.12 + pulse * 0.12) * brightness;
        
        final haloPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              star.haloColor.withOpacity(haloOpacity),
              star.haloColor.withOpacity(haloOpacity * 0.3),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(Rect.fromCircle(center: Offset(x, y), radius: haloRadius))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
          
        canvas.drawCircle(Offset(x, y), haloRadius, haloPaint);
      }
      
      // Ambient glow core for bright stars
      if (star.size > 0.8 && brightness > 0.5) {
        starGlowPaint.color = star.color.withOpacity(brightness * 0.22);
        canvas.drawCircle(Offset(x, y), star.size * 3.5, starGlowPaint);
      }
      
      // Star Core
      starPaint.color = star.color.withOpacity(brightness);
      canvas.drawCircle(Offset(x, y), star.size, starPaint);
      
      // Diffraction spikes for larger, very bright stars
      if (star.size > 1.2 && brightness > 0.72) {
        _drawDiffractionSpikes(canvas, Offset(x, y), star.size, brightness);
      }
    }

    // 5. Space-Time Gravity Warp Grid
    _drawSpaceTimeGrid(canvas, size);

    // 6. Neural Network Connections
    _drawNeuralNetwork(canvas, size);

    // 7. AI Data Flow Streams
    _drawDataStreams(canvas, size);

    // 8. Shooting Stars
    for (final shootingStar in shootingStars) {
      _drawShootingStar(canvas, size, shootingStar);
    }

    // 8.5. Gravitational Singularity (Einstein Ring / Accretion Glow)
    final activeCenter = customWarpCenter ?? Offset(size.width * 0.5, size.height * 0.45);
    _drawGravitationalSingularity(canvas, activeCenter, size);

    // 9. Vignette Overlay
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.transparent,
          const Color(0xFF000000).withOpacity(0.35),
        ],
        stops: const [0.6, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);
  }

  // ────────────────────────────────────────────────────
  // Paint Helper: Wavelength Warp (Gravitational Lensing)
  // ────────────────────────────────────────────────────
  Offset _warpPoint(Offset point, Offset center, double maxDist) {
    final activeCenter = customWarpCenter ?? center;
    final dir = point - activeCenter;
    final dist = dir.distance;
    if (dist == 0) return point;

    final normalized = dist / maxDist;
    final warpStrength = 0.88 + 0.12 * math.pow(normalized, 2.0);
    final wave = math.sin(normalized * 7.0 + time * 2.0 * math.pi) * 1.5;
    
    return activeCenter + dir * warpStrength + Offset(wave, wave * 0.5);
  }

  // ────────────────────────────────────────────────────
  // Paint Helper: Draw Aurora Borealis Curtains
  // ────────────────────────────────────────────────────
  void _drawAurora(Canvas canvas, Size size) {
    final center = customWarpCenter ?? Offset(size.width * 0.5, size.height * 0.45);
    final maxDist = math.max(size.width, size.height);

    // 1. Far background aurora layer (Deep Space Blue -> Slate Blue)
    _drawAuroraCurtain(
      canvas,
      size,
      center,
      maxDist,
      baseY: size.height * 0.40,
      baseHeight: size.height * 0.35,
      color1: const Color(0xFF0A1C42), // Dark Blue
      color2: const Color(0xFF1B2C66), // Slate Blue
      speed: 0.012, // Slowed down for premium, calm drift
      phaseOffset: math.pi * 0.2,
      scaleX: 0.85,
      opacity: 0.07, // Subtle atmospheric blend
    );

    // 2. Middle background aurora layer (Slate Blue -> Slate Purple)
    _drawAuroraCurtain(
      canvas,
      size,
      center,
      maxDist,
      baseY: size.height * 0.45,
      baseHeight: size.height * 0.40,
      color1: const Color(0xFF1B2C66),
      color2: const Color(0xFF3E2D70), // Soft Slate Purple
      speed: 0.018,
      phaseOffset: math.pi * 0.5,
      scaleX: 1.15,
      opacity: 0.09,
    );

    // 3. Foreground aurora layer (Slate Purple -> Soft Ocean Teal)
    _drawAuroraCurtain(
      canvas,
      size,
      center,
      maxDist,
      baseY: size.height * 0.50,
      baseHeight: size.height * 0.46,
      color1: const Color(0xFF3E2D70),
      color2: const Color(0xFF004D40), // Soft Ocean Teal
      speed: 0.024,
      phaseOffset: 0.0,
      scaleX: 1.7,
      opacity: 0.11,
      isForeground: true,
    );
  }

  void _drawAuroraCurtain(
    Canvas canvas,
    Size size,
    Offset center,
    double maxDist, {
    required double baseY,
    required double baseHeight,
    required Color color1,
    required Color color2,
    required double speed,
    required double phaseOffset,
    required double scaleX,
    required double opacity,
    bool isForeground = false,
  }) {
    // Overlapping vertical columns create high-fidelity curtains with vertical rays
    final double colWidth = size.width / 32;
    const int numCols = 45;
    final double waveTime = time * 2.0 * math.pi;

    for (int i = 0; i <= numCols; i++) {
      final double xRatio = i / numCols;
      final double x = xRatio * size.width;

      // Organic waving equations based on time and sine frequencies
      final double wave1 = math.sin(xRatio * math.pi * 2.8 * scaleX + waveTime * 1.5 + phaseOffset);
      final double wave2 = math.cos(xRatio * math.pi * 4.2 * scaleX - waveTime * 1.0 + phaseOffset * 1.3);

      final double yBottom = baseY + wave1 * 40.0 + wave2 * 18.0;
      final double h = baseHeight + wave2 * 35.0 + wave1 * 25.0;
      final double yTop = yBottom - h;

      // Warp points to create General Relativity gravitational lensing curvature ( aurora curves around center )
      final Offset bottomPt = _warpPoint(Offset(x, yBottom), center, maxDist);
      final Offset topPt = _warpPoint(Offset(x, yTop), center, maxDist);

      // Color variation across the canvas
      final Color activeColor = Color.lerp(color1, color2, xRatio)!;

      final List<Color> gradientColors;
      final List<double> gradientStops;

      if (isForeground) {
        // Foreground curtain includes a soft cyan lower boundary
        gradientColors = [
          Colors.transparent,
          const Color(0xFF00E5FF).withOpacity(opacity * 0.4), // Soft Cyan edge
          activeColor.withOpacity(opacity), // Main Body
          activeColor.withOpacity(opacity * 0.5),
          Colors.transparent, // Top fade
        ];
        gradientStops = const [0.0, 0.08, 0.25, 0.55, 1.0];
      } else {
        // Smooth background curtain gradient
        gradientColors = [
          Colors.transparent,
          activeColor.withOpacity(opacity),
          activeColor.withOpacity(opacity * 0.45),
          Colors.transparent,
        ];
        gradientStops = const [0.0, 0.15, 0.45, 1.0];
      }

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = colWidth
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          bottomPt,
          topPt,
          gradientColors,
          gradientStops,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawLine(bottomPt, topPt, paint);

      // Render organic vertical ray details for natural curtain texture
      final double rayStrength = (math.sin(i * 1.45 + waveTime * 2.2) * 0.5 + 0.5) *
                                 (math.cos(i * 0.85 - waveTime * 1.1) * 0.5 + 0.5);
      if (rayStrength > 0.38) {
        final double rayOpacity = (opacity * 1.4 * rayStrength).clamp(0.0, 1.0);
        final rayPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 + rayStrength * 1.8
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(
            bottomPt,
            topPt,
            [
              Colors.transparent,
              Colors.white.withOpacity(rayOpacity),
              activeColor.withOpacity(rayOpacity * 0.8),
              Colors.transparent,
            ],
            const [0.0, 0.15, 0.45, 1.0],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawLine(bottomPt, topPt, rayPaint);
      }
    }
  }

  // ────────────────────────────────────────────────────
  // Paint Helper: Draw Nebula Gaseous Clouds
  // ────────────────────────────────────────────────────
  void _drawNebula(Canvas canvas, Size size, NebulaCloud nebula) {
    final center = Offset(nebula.x * size.width, nebula.y * size.height);
    final radius = nebula.radius * size.width;
    final rotationAngle = nebula.rotation + time * nebula.animationSpeed * 2 * math.pi;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    for (int i = 0; i < nebula.colors.length; i++) {
      final layerRadius = radius * (1.0 - i * 0.22);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            nebula.colors[i],
            nebula.colors[i].withOpacity(0.0),
          ],
          stops: [0.0, nebula.density],
        ).createShader(Rect.fromCircle(center: center, radius: layerRadius))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 90.0 + i * 20.0);

      canvas.drawCircle(center, layerRadius, paint);
    }

    canvas.restore();
  }

  // ────────────────────────────────────────────────────
  // Paint Helper: Star Lens Flare (Diffraction Spikes)
  // ────────────────────────────────────────────────────
  void _drawDiffractionSpikes(Canvas canvas, Offset center, double size, double brightness) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(brightness * 0.35)
      ..strokeWidth = 0.35
      ..style = PaintingStyle.stroke;

    final length = size * 6.5 * brightness;

    // Horizontal Spike
    canvas.drawLine(
      Offset(center.dx - length, center.dy),
      Offset(center.dx + length, center.dy),
      paint,
    );

    // Vertical Spike
    canvas.drawLine(
      Offset(center.dx, center.dy - length),
      Offset(center.dx, center.dy + length),
      paint,
    );
  }

  // ────────────────────────────────────────────────────
  // Paint Helper: Gravitational Grid Warp
  // ────────────────────────────────────────────────────
  void _drawSpaceTimeGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3
      ..color = const Color(0xFF1565C0).withOpacity(0.035);

    final center = Offset(size.width * 0.5, size.height * 0.45);
    final maxDist = math.max(size.width, size.height);

    const gridSize = 14;
    const gridRows = 22;

    // Draw horizontal grid lines
    for (int r = 0; r <= gridRows; r++) {
      final path = Path();
      for (int c = 0; c <= gridSize; c++) {
        final pt = Offset(
          c * size.width / gridSize,
          r * size.height / gridRows,
        );
        final warped = _warpPoint(pt, center, maxDist);
        if (c == 0) {
          path.moveTo(warped.dx, warped.dy);
        } else {
          path.lineTo(warped.dx, warped.dy);
        }
      }
      canvas.drawPath(path, gridPaint);
    }

    // Draw vertical grid lines
    for (int c = 0; c <= gridSize; c++) {
      final path = Path();
      for (int r = 0; r <= gridRows; r++) {
        final pt = Offset(
          c * size.width / gridSize,
          r * size.height / gridRows,
        );
        final warped = _warpPoint(pt, center, maxDist);
        if (r == 0) {
          path.moveTo(warped.dx, warped.dy);
        } else {
          path.lineTo(warped.dx, warped.dy);
        }
      }
      canvas.drawPath(path, gridPaint);
    }
  }

  // ────────────────────────────────────────────────────
  // Paint Helper: Neural Constellation
  // ────────────────────────────────────────────────────
  void _drawNeuralNetwork(Canvas canvas, Size size) {
    final positions = <Offset>[];
    for (final node in nodes) {
      // Rotate / move nodes based on animation time
      double cx = (node.x + node.vx * time * 4.0) % 1.0;
      double cy = (node.y + node.vy * time * 4.0) % 1.0;
      if (cx < 0) cx += 1.0;
      if (cy < 0) cy += 1.0;
      
      positions.add(Offset(cx * size.width, cy * size.height));
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.45;

    final maxConnectionDist = size.width * 0.22;
    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        final dist = (positions[i] - positions[j]).distance;
        
        if (dist < maxConnectionDist) {
          final opacity = 1.0 - dist / maxConnectionDist;
          final energy = (nodes[i].energy + nodes[j].energy) / 2;
          
          linePaint.shader = ui.Gradient.linear(
            positions[i],
            positions[j],
            [
              Color.lerp(
                const Color(0xFF009688), // Soft Teal
                const Color(0xFF3F51B5), // Soft Indigo
                energy,
              )!.withOpacity(opacity * 0.05), // Faint network lines
              Color.lerp(
                const Color(0xFF009688),
                const Color(0xFF3F51B5),
                1.0 - energy,
              )!.withOpacity(opacity * 0.05),
            ],
          );
          
          canvas.drawLine(positions[i], positions[j], linePaint);
        }
      }
    }

    // Paint Node Circles
    final nodePaint = Paint()..style = PaintingStyle.fill;
    final nodeGlowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (int i = 0; i < positions.length; i++) {
      final node = nodes[i];
      final pulse = 0.8 + 0.2 * math.sin(time * math.pi * 2 + node.pulsePhase);
      final activeColor = Color.lerp(
        const Color(0xFF009688), // Soft Teal
        const Color(0xFF3F51B5), // Soft Indigo
        node.energy,
      )!;

      // Glow aura
      nodeGlowPaint.color = activeColor.withOpacity(0.08 * pulse);
      canvas.drawCircle(positions[i], node.size * 2.8, nodeGlowPaint);
      
      // Node core halo
      nodePaint.color = activeColor.withOpacity(0.20 * pulse);
      canvas.drawCircle(positions[i], node.size * 1.4, nodePaint);
      
      // Hard center core
      nodePaint.color = Colors.white.withOpacity(0.60 * pulse);
      canvas.drawCircle(positions[i], node.size * 0.6, nodePaint);
    }
  }

  // ────────────────────────────────────────────────────
  // Paint Helper: AI Data Stream Particles
  // ────────────────────────────────────────────────────
  void _drawDataStreams(Canvas canvas, Size size) {
    for (final stream in dataStreams) {
      final progress = ((particleTime * stream.speed + stream.delay) % 1.0);
      
      final x = (stream.startX + (stream.endX - stream.startX) * progress) * size.width;
      final y = (stream.startY + (stream.endY - stream.startY) * progress) * size.height;
      
      final opacity = math.sin(progress * math.pi);
      
      // Draw faded particle trail
      final trailPaint = Paint()
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      const trailLength = 7;
      for (int i = 0; i < trailLength; i++) {
        final trailProgress = (progress - i * 0.025).clamp(0.0, 1.0);
        final tx = (stream.startX + (stream.endX - stream.startX) * trailProgress) * size.width;
        final ty = (stream.startY + (stream.endY - stream.startY) * trailProgress) * size.height;
        
        final trailOpacity = opacity * (1.0 - i / trailLength) * 0.35;
        trailPaint.color = stream.color.withOpacity(trailOpacity);
        canvas.drawCircle(Offset(tx, ty), stream.size * (1.0 - i / trailLength), trailPaint);
      }
      
      // Bright Flow Head
      final headPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = stream.color.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), stream.size, headPaint);
      
      // Flow glow aura
      final glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..color = stream.color.withOpacity(opacity * 0.45);
      canvas.drawCircle(Offset(x, y), stream.size * 2.2, glowPaint);
    }
  }

  // ────────────────────────────────────────────────────
  // Paint Helper: Shooting Star (Comet)
  // ────────────────────────────────────────────────────
  void _drawShootingStar(Canvas canvas, Size size, ShootingStar star) {
    final cycle = (time + star.startTime) % 1.0;
    
    if (cycle > star.lifetime) return;
    
    final progress = cycle / star.lifetime;
    final travel = size.width * 1.1 * progress;
    
    final dx = math.cos(star.angle);
    final dy = math.sin(star.angle);
    
    final headX = size.width * star.startX + travel * dx;
    final headY = size.height * star.startY + travel * dy;
    
    final tailLength = size.width * star.length;
    final tailX = headX - tailLength * dx;
    final tailY = headY - tailLength * dy;
    
    final head = Offset(headX, headY);
    final tail = Offset(tailX, tailY);
    
    // Cone-shaped trail path
    final path = Path();
    final perpDx = -dy * star.thickness;
    final perpDy = dx * star.thickness;
    
    path.moveTo(headX, headY);
    path.lineTo(tailX + perpDx, tailY + perpDy);
    path.lineTo(tailX - perpDx, tailY - perpDy);
    path.close();
    
    final tailPaint = Paint()
      ..shader = ui.Gradient.linear(
        tail,
        head,
        [
          const Color(0xFF00E5FF).withOpacity(0.0),
          const Color(0xFF00FFD1).withOpacity(0.35 * (1.0 - progress)),
          Colors.white.withOpacity(0.85 * (1.0 - progress)),
        ],
        [0.0, 0.5, 1.0],
      )
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawPath(path, tailPaint);
    
    // Core head
    final headPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(1.0 - progress);
    canvas.drawCircle(head, 1.6, headPaint);
    
    // Head glow
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..color = const Color(0xFF00FFD1).withOpacity(0.5 * (1.0 - progress));
    canvas.drawCircle(head, 3.5, glowPaint);
  }

  // ────────────────────────────────────────────────────
  // Paint Helper: Einstein Ring Accretion Disk Singularity Glow
  // ────────────────────────────────────────────────────
  void _drawGravitationalSingularity(Canvas canvas, Offset center, Size size) {
    // 1. Accretion Glow (Outer soft blue/violet halo)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0D47A1).withOpacity(0.10), // Deep Sapphire Blue
          const Color(0xFF3F51B5).withOpacity(0.04), // Faint Slate Indigo
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 90))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, 90, glowPaint);

    // 2. Einstein Ring (Faint light lens circle that warps space-time)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.20),
          const Color(0xFF00D9FF).withOpacity(0.08),
          Colors.transparent,
        ],
        stops: const [0.9, 0.95, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 45))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(center, 45, ringPaint);

    // 3. Faint swirling accretion dust particles
    final dustPaint = Paint()..style = PaintingStyle.fill;
    final double baseAngle = time * 2.0 * math.pi;
    for (int i = 0; i < 6; i++) {
      final double angle = baseAngle * (0.8 + i * 0.1) + i * (math.pi / 3);
      final double radius = 35.0 + i * 8.0;
      final double dx = center.dx + math.cos(angle) * radius;
      final double dy = center.dy + math.sin(angle) * radius;
      final double scale = 0.5 + 0.5 * math.sin(time * math.pi + i);
      
      // Faint blue-gray dust, no magenta/pink
      dustPaint.color = const Color(0xFFB0BEC5).withOpacity(0.10 * scale);
      
      canvas.drawCircle(Offset(dx, dy), 1.5 * scale, dustPaint);
    }
  }

  @override
  bool shouldRepaint(covariant AIUniversePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.particleTime != particleTime ||
        oldDelegate.customWarpCenter != customWarpCenter;
  }
}
