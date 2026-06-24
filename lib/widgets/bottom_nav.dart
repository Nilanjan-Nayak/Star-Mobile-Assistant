import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glow_container/glow_container.dart';

class BottomNav extends StatefulWidget {
  final VoidCallback onMicTap;
  final VoidCallback? onHomeTap;
  final VoidCallback? onSettingsTap;

  const BottomNav({
    super.key,
    required this.onMicTap,
    this.onHomeTap,
    this.onSettingsTap,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlowContainer(
      glowRadius: 30, // Softer, wider glow
      gradientColors: [
        const Color(0xFF00E5FF).withValues(alpha: 0.4), // Cyan
        const Color(0xFF8E2DE2).withValues(alpha: 0.4), // Electric Purple
        const Color(0xFF00FF88).withValues(alpha: 0.4), // Neon Green
      ],
      rotationDuration: const Duration(seconds: 4), // Smoother rotation
      glowLocation: GlowLocation.both,
      transitionDuration: const Duration(milliseconds: 500),
      showAnimatedBorder: true,
      containerOptions: ContainerOptions(
        height: 100,
        width: MediaQuery.of(context).size.width,
        borderRadius: 32, // Slightly more rounded
        backgroundColor: const Color(0xFF05050A)
            .withValues(alpha: 0.85), // Deep dark background
        borderSide: BorderSide(
          width: 1.0,
          color: Colors.white.withValues(alpha: 0.08), // Subtle border
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home Button
                _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  label: "Dashboard",
                  isActive: false,
                  onTap: widget.onHomeTap ?? () {},
                ),

                // Center Mic Button
                _buildMicButton(onTap: widget.onMicTap),

                // Settings Button
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  label: "Settings",
                  isActive: false,
                  onTap: widget.onSettingsTap ?? () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive
                    ? const Color(0xFF00D9FF)
                    : Colors.white.withValues(alpha: 0.5),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isActive
                      ? const Color(0xFF00D9FF)
                      : Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80, // Enlarged
        height: 80, // Enlarged
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main orb with pulse animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 80, // Enlarged
                    height: 80, // Enlarged
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Removed blue gradient and border
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF00D9FF).withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Center(
                        child: Transform.translate(
                          offset: const Offset(0.5, -5),
                          child: SizedBox(
                            width: 92,
                            height: 90,
                            child: Image.asset(
                              'assets/gif/star.gif',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.mic_rounded,
                                  size: 45, // Enlarged
                                  color: Color(0xFF00D9FF),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}





