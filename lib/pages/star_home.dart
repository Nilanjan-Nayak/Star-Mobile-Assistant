import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:star_assistant/controller/speech_controller.dart';
import 'package:star_assistant/controller/tts_controller.dart';
import 'package:star_assistant/controller/waveform_controller.dart';
import 'package:star_assistant/models/conversation.dart';
import 'package:star_assistant/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:glow_container/glow_container.dart';
import 'package:star_assistant/widgets/premium_background.dart';

class StarHome extends StatefulWidget {
  const StarHome({super.key});

  @override
  State<StarHome> createState() => _StarHomeState();
}

class _StarHomeState extends State<StarHome> with TickerProviderStateMixin {
  // isBlob = true means main screen with orb
  // isBlob = false means chat/conversation screen
  bool isBlob = true;

  // isBottomMic = true means listening bar is expanded
  // isBottomMic = false means normal navigation bar
  bool isBottomMic = false;

  final GlobalKey<PremiumDarkBackgroundState> _backgroundKey = GlobalKey();

  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _floatController;
  late AnimationController _particleController;
  late AnimationController _rippleController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _rippleAnimation;

  late WaveformController _waveformController;

  @override
  void initState() {
    super.initState();
    _waveformController = WaveformController();
    _initializeAnimations();
    _setupSystemUI();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF000000),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    _particleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  /// Closes the chat mode completely and returns to main interface
  void _closeChat() {
    final speechController =
        Provider.of<SpeechController>(context, listen: false);
    speechController.stopConversation();
    setState(() {
      isBlob = true;
      isBottomMic = false;
    });
  }

  /// Opens the listening bar (expands bottom section)
  void _openListeningBar() {
    final speechController =
        Provider.of<SpeechController>(context, listen: false);
    setState(() {
      isBottomMic = true;
    });
    speechController.startListening();
  }

  /// Closes only the listening bar (keeps chat view open)
  void _closeListeningBar() {
    final speechController =
        Provider.of<SpeechController>(context, listen: false);
    speechController.stopListening();
    setState(() {
      isBottomMic = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final speechController = Provider.of<SpeechController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: MouseRegion(
        onHover: (event) {
          _backgroundKey.currentState
              ?.updateTargetWarpCenter(event.localPosition);
        },
        onExit: (event) {
          _backgroundKey.currentState?.updateTargetWarpCenter(null);
        },
        child: GestureDetector(
          onPanUpdate: (event) {
            _backgroundKey.currentState
                ?.updateTargetWarpCenter(event.localPosition);
          },
          onPanCancel: () {
            _backgroundKey.currentState?.updateTargetWarpCenter(null);
          },
          onPanEnd: (event) {
            _backgroundKey.currentState?.updateTargetWarpCenter(null);
          },
          child: Stack(
            children: [
              // Premium animated background
              PremiumDarkBackground(
                key: _backgroundKey,
                rotationController: _rotationController,
                particleController: _particleController,
                isChatView: !isBlob,
              ),

              // Main content area
              SafeArea(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: animation.drive(
                          Tween(begin: const Offset(0, 0.05), end: Offset.zero)
                              .chain(CurveTween(curve: Curves.easeOutQuart)),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: isBlob
                      ? _buildMainInterface(speechController)
                      : _buildChatState(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: !isBlob ? _buildBottomBar(speechController) : null,
    );
  }

  Widget _buildMainInterface(SpeechController speechController) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 30),
                _buildPremiumHeader(),
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: _buildAIOrb(speechController),
                    );
                  },
                ),
                Column(
                  children: [
                    _buildBottomSection(),
                    const SizedBox(height: 50),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlowContainer(
                      glowRadius: 10,
                      gradientColors: const [
                        Color(0xFF00FF88),
                        Color(0xFF00FF88),
                      ],
                      rotationDuration: const Duration(seconds: 2),
                      glowLocation: GlowLocation.both,
                      transitionDuration: const Duration(milliseconds: 300),
                      showAnimatedBorder: false,
                      containerOptions: ContainerOptions(
                        width: 6,
                        height: 6,
                        borderRadius: 3, // Circular
                        backgroundColor: const Color(0xFF00FF88),
                      ),
                      child: const SizedBox(width: 6, height: 6),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "SYSTEM ONLINE",
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00FF88),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Welcome back",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF00FF88)],
                  ).createShader(bounds),
                  child: Text(
                    "Nilanjan",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIOrb(SpeechController speechController) {
    return GestureDetector(
      onTap: () {
        // Handle tap to start listening
        setState(() {
          isBlob = false;
          isBottomMic = true;
        });

        // Toggle speech recognition
        if (speechController.isListening) {
          speechController.stopListening();
        } else {
          speechController.startListening();
        }
      },
      child: Container(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cyber Orbit Telemetry Rings
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(280, 280),
                  painter: CyberOrbitPainter(
                    progress: _rotationController.value,
                    color: const Color(0xFF00D9FF),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _rippleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(250, 250),
                  painter: RipplePainter(
                    progress: _rippleAnimation.value,
                    color: const Color(0xFF00D9FF),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF001122), Color(0xFF002244)],
                      ),
                      border: Border.all(
                        color: const Color(0xFF00D9FF).withOpacity(0.5),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D9FF).withOpacity(0.35),
                          blurRadius: 35,
                          spreadRadius: 12,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(
                            child: Transform.translate(
                              offset: const Offset(1, -14),
                              child: SizedBox(
                                width: 252,
                                height: 250,
                                child: Image.asset(
                                  'assets/gif/star.gif',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFF001122),
                                      child: const Icon(
                                        Icons.mic,
                                        size: 90,
                                        color: Color(0xFF00D9FF),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF00D9FF).withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildBottomSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: TextAnimatorSequence(
            loop: true,
            children: [
              TextAnimator(
                "S . T . A . R ",
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 5,
                ),
                atRestEffect: WidgetRestingEffects.pulse(effectStrength: 0.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF00D9FF).withOpacity(0.1),
            border: Border.all(
              color: const Color(0xFF00D9FF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.touch_app_rounded,
                color: Color(0xFF00D9FF),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                "Tap to speak",
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build the chat/conversation state
  Widget _buildChatState() {
    final speechController = Provider.of<SpeechController>(context);
    final ttsController = Provider.of<TTSController>(context);

    return Stack(
      children: [
        // Background tap detector - closes chat when tapping outside content
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _closeChat,
            child: Container(color: Colors.transparent),
          ),
        ),

        // Main content
        Column(
          children: [
            const SizedBox(height: 12),

            // Conversation display area - unified glassmorphic panel
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF0C0F24).withOpacity(0.15),
                            const Color(0xFF070913).withOpacity(0.35),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {}, // Absorb taps on the conversation area
                        behavior: HitTestBehavior.opaque,
                        child: _buildConversationDisplay(
                            speechController, ttsController),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bottom section - only show when listening bar is NOT open
            if (!isBottomMic) ...[
              GestureDetector(
                onTap: () {}, // Absorb taps
                behavior: HitTestBehavior.opaque,
                child: _buildChatBottomSection(),
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildChatBottomSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Text(
            "S . T . A . R",
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConversationDisplay(
      SpeechController speechController, TTSController ttsController) {
    return Column(
      children: [
        // ─── PREMIUM HEADER ─────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "S.T.A.R",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _rippleAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      width: 14 * _rippleAnimation.value,
                                      height: 14 * _rippleAnimation.value,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF00FF88)
                                            .withValues(
                                                alpha: 0.4 *
                                                    (1.0 -
                                                        _rippleAnimation
                                                            .value)),
                                      ),
                                    );
                                  },
                                ),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF00FF88),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              speechController.conversation.messages.isEmpty
                                  ? "Online • Ready to assist"
                                  : "Online • ${speechController.conversation.messages.length} messages",
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.35),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // New chat button
                  _buildHeaderIconButton(
                    icon: Icons.add_rounded,
                    onTap: () {
                      final sc =
                          Provider.of<SpeechController>(context, listen: false);
                      sc.clearConversation();
                    },
                  ),
                  const SizedBox(width: 8),
                  // Close button
                  _buildHeaderIconButton(
                    icon: Icons.keyboard_arrow_down_rounded,
                    onTap: _closeChat,
                  ),
                ],
              ),
              // Thin gradient divider with animated shimmer effect
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  final double progress = _rotationController.value;
                  return Container(
                    margin: const EdgeInsets.only(top: 14),
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-2.0 + progress * 4.0, 0),
                        end: Alignment(-0.5 + progress * 4.0, 0),
                        colors: [
                          Colors.transparent,
                          const Color(0xFF00D9FF).withValues(alpha: 0.1),
                          const Color(0xFF7B61FF).withValues(alpha: 0.45),
                          const Color(0xFF00FF88).withValues(alpha: 0.45),
                          const Color(0xFF00D9FF).withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // ─── MESSAGES AREA ──────────────────────────────────
        Expanded(
          child: Container(
            color: Colors.transparent,
            child: speechController.conversation.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount:
                        speechController.conversation.messages.reversed.length,
                    itemBuilder: (context, index) {
                      final message = speechController
                          .conversation.messages.reversed
                          .toList()[index];
                      return _buildMessageBubble(message, ttsController);
                    },
                  ),
          ),
        ),

        // ─── TYPING INDICATOR ───────────────────────────────
        if (speechController.isProcessingAI)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.015),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.04),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Mini avatar
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D9FF), Color(0xFF7B61FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 12),
                ),
                const SizedBox(width: 12),
                // Animated dots
                const TypingIndicator(),
                const SizedBox(width: 14),
                Text(
                  "Generating response…",
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child:
              Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 18),
        ),
      ),
    );
  }

  // Bouncing dots are handled by TypingIndicator stateful widget

  // ─── EMPTY STATE ──────────────────────────────────────────
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo glow
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00D9FF).withValues(alpha: 0.1),
                  const Color(0xFF7B61FF).withValues(alpha: 0.04),
                  Colors.transparent,
                ],
                radius: 0.8,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10101C).withValues(alpha: 0.5),
                border: Border.all(
                  color: const Color(0xFF1E1E32),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D9FF).withValues(alpha: 0.12),
                    blurRadius: 40,
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00D9FF), Color(0xFF00FF88)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFFA0A0B8)],
            ).createShader(bounds),
            child: Text(
              "What can I help you with?",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the mic and start speaking",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── MESSAGE BUBBLE ───────────────────────────────────────
  Widget _buildMessageBubble(
      ConversationMessage message, TTSController ttsController) {
    final isUser = message.isUser;
    final timeStr =
        "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}";

    if (isUser) {
      return _buildUserMessage(message, timeStr);
    } else {
      return _buildAIMessage(message, ttsController, timeStr);
    }
  }

  // ── User message: right-aligned solid gradient bubble ─────
  Widget _buildUserMessage(ConversationMessage message, String timeStr) {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 24, bottom: 12, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(4),
              ),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2563EB).withOpacity(0.85),
                  const Color(0xFF1D4ED8).withOpacity(0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFF60A5FA).withOpacity(0.35),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D4ED8).withOpacity(0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.97),
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 4),
            child: Text(
              timeStr,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AI message: full-width card style with left accent ─────
  Widget _buildAIMessage(ConversationMessage message,
      TTSController ttsController, String timeStr) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.015),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.04),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI label row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF00FF88)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "S.T.A.R",
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.18),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Message content with left accent bar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accent bar
              Container(
                width: 3,
                constraints: const BoxConstraints(minHeight: 20),
                margin: const EdgeInsets.only(left: 12, right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF00D9FF), Color(0xFF00FF88)],
                  ),
                ),
              ),
              // Text content
              Expanded(
                child: _buildAIMessageContent(message),
              ),
            ],
          ),
          // Action bar
          if (!message.isProcessing && message.error == null) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(left: 31),
              child: Row(
                children: [
                  _buildActionButton(
                    icon: ttsController.isSpeaking
                        ? Icons.stop_rounded
                        : Icons.volume_up_rounded,
                    label: ttsController.isSpeaking ? "Stop" : "Listen",
                    color: ttsController.isSpeaking
                        ? const Color(0xFFFF6B7A)
                        : const Color(0xFF00D9FF),
                    onTap: () {
                      if (ttsController.isSpeaking) {
                        ttsController.stop();
                      } else {
                        ttsController.speak(message.text);
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                  _buildActionButton(
                    icon: Icons.copy_rounded,
                    label: "Copy",
                    color: Colors.white.withValues(alpha: 0.4),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: message.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF00FF88), size: 16),
                              const SizedBox(width: 8),
                              Text('Copied to clipboard',
                                  style: GoogleFonts.inter(fontSize: 13)),
                            ],
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF1A1A2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          // Retry for errors
          if (message.error != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 31),
              child: _buildActionButton(
                icon: Icons.refresh_rounded,
                label: "Retry",
                color: const Color(0xFFFF6B7A),
                onTap: () {
                  final sc =
                      Provider.of<SpeechController>(context, listen: false);
                  sc.retryLastMessage();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAIMessageContent(ConversationMessage message) {
    if (message.isProcessing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.6),
              strokeWidth: 1.5,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "Generating response…",
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    if (message.error != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFFF4757).withValues(alpha: 0.08),
          border: Border.all(
            color: const Color(0xFFFF4757).withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFFF6B7A),
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message.error!,
                style: GoogleFonts.inter(
                  color: const Color(0xFFFF6B7A),
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SelectableText(
      message.text,
      style: GoogleFonts.inter(
        color: Colors.white.withValues(alpha: 0.88),
        fontSize: 14,
        height: 1.7,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withValues(alpha: 0.08),
            border: Border.all(
              color: color.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(SpeechController speechController) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: isBottomMic
          ? _buildListeningBar(speechController)
          : _buildNavigationBar(speechController),
    );
  }

  Widget _buildListeningBar(SpeechController speechController) {
    final ttsController = Provider.of<TTSController>(context);

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (speechController.isProcessingAI) {
      statusText = "PROCESSING";
      statusColor = const Color(0xFF00D9FF);
      statusIcon = Icons.psychology_rounded;
    } else if (ttsController.isSpeaking) {
      statusText = "SPEAKING";
      statusColor = const Color(0xFFFF9500);
      statusIcon = Icons.volume_up_rounded;
    } else if (speechController.isListening) {
      statusText = "LISTENING";
      statusColor = const Color(0xFF00FF88);
      statusIcon = Icons.mic_rounded;
    } else {
      statusText = "READY";
      statusColor = const Color(0xFF00D9FF);
      statusIcon = Icons.mic_none_rounded;
    }

    return GestureDetector(
      onTap: () {}, // Prevent taps from closing chat
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 380,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              const Color(0xFF0A0A0F).withOpacity(0.35),
              const Color(0xFF0A0A0F).withOpacity(0.65),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D12).withOpacity(0.55),
                border: Border(
                  top: BorderSide(
                    color: statusColor.withOpacity(0.45),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.2),
                    blurRadius: 45,
                    spreadRadius: 2,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar - can be used to close the listening bar
                  GestureDetector(
                    onTap: _closeListeningBar,
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),

                  // Close button row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _closeListeningBar,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white.withOpacity(0.05),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white.withOpacity(0.7),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Transcript display
                  Container(
                    height: 110,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF15151D).withValues(alpha: 0.35),
                      border: Border.all(
                        color: statusColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: statusColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(statusIcon, color: statusColor, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              statusText,
                              style: GoogleFonts.rajdhani(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              speechController.isProcessingAI
                                  ? "Processing your message..."
                                  : ttsController.isSpeaking
                                      ? "AI is speaking..."
                                      : speechController.lastWords.isEmpty
                                          ? "Start speaking..."
                                          : speechController.lastWords,
                              style: GoogleFonts.inter(
                                color: speechController.lastWords.isEmpty
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Control buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (speechController.isListening)
                          _buildControlButton(
                            icon: Icons.send_rounded,
                            label: "Send Now",
                            color: const Color(0xFF00D9FF),
                            onTap: () => speechController.stopListening(),
                          ),
                        if (!speechController.isListening &&
                            !speechController.isProcessingAI &&
                            !ttsController.isSpeaking)
                          _buildControlButton(
                            icon: Icons.mic_rounded,
                            label: "Tap to Speak",
                            color: const Color(0xFF00FF88),
                            onTap: () => speechController.startListening(),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Waveform
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SiriWaveform.ios9(
                      controller: _waveformController.controller,
                      options: IOS9SiriWaveformOptions(
                        height: 70,
                        width: MediaQuery.of(context).size.width - 40,
                        showSupportBar: false,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar(SpeechController speechController) {
    return BottomNav(
      onMicTap: _openListeningBar,
      onHomeTap: _closeChat,
      onSettingsTap: () {
        // Handle settings tap
      },
    );
  }
}

class RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  RipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 3; i++) {
      final adjustedProgress = (progress + i * 0.33) % 1.0;
      final opacity = (1.0 - adjustedProgress) * 0.3;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, 90 + (adjustedProgress * 60), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double delay = index * 0.2;
            double progress = _controller.value - delay;
            if (progress < 0) progress += 1.0;

            final double offset = math.sin(progress * 2 * math.pi) * 4;
            final double adjustedOffset = offset < 0 ? 0 : offset;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D9FF)
                    .withValues(alpha: 0.45 + (adjustedOffset / 4) * 0.55),
                boxShadow: [
                  if (adjustedOffset > 1)
                    BoxShadow(
                      color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                ],
              ),
              transform: Matrix4.translationValues(0, -adjustedOffset, 0),
            );
          },
        );
      }),
    );
  }
}

class CyberOrbitPainter extends CustomPainter {
  final double progress;
  final Color color;

  CyberOrbitPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double angle = progress * 2 * math.pi;

    // 1. Sleek thin outer boundary ring
    final outerRingPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, 128, outerRingPaint);

    // 2. Dash/Segmented Telemetry Ring
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final segmentPaint = Paint()
      ..color = color.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw 4 symmetric segments
    const int segmentsCount = 4;
    const double segmentSweep = math.pi / 4; // 45 degrees
    for (int i = 0; i < segmentsCount; i++) {
      final double startAngle =
          i * (2 * math.pi / segmentsCount) - (segmentSweep / 2);
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 124),
        startAngle,
        segmentSweep,
        false,
        segmentPaint,
      );

      // Fine ticks at the end of each segment
      final double end1 = startAngle;
      final double end2 = startAngle + segmentSweep;
      final endPaint = Paint()
        ..color = color.withOpacity(0.8)
        ..strokeWidth = 1.5;

      canvas.drawLine(
        Offset(math.cos(end1) * 120, math.sin(end1) * 120),
        Offset(math.cos(end1) * 128, math.sin(end1) * 128),
        endPaint,
      );
      canvas.drawLine(
        Offset(math.cos(end2) * 120, math.sin(end2) * 120),
        Offset(math.cos(end2) * 128, math.sin(end2) * 128),
        endPaint,
      );
    }

    // 3. Telemetry Ticks Ring (inner)
    final tickPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 1.0;
    const int ticksCount = 36;
    for (int i = 0; i < ticksCount; i++) {
      final double tickAngle = i * (2 * math.pi / ticksCount);
      const double startRadius = 114;
      const double endRadius = 119;
      canvas.drawLine(
        Offset(math.cos(tickAngle) * startRadius,
            math.sin(tickAngle) * startRadius),
        Offset(
            math.cos(tickAngle) * endRadius, math.sin(tickAngle) * endRadius),
        tickPaint,
      );
    }

    canvas.restore();

    // 4. Counter-rotating inner dot telemetry ring
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-angle * 1.5); // Counter rotate faster

    final dotPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    const int dotsCount = 8;
    for (int i = 0; i < dotsCount; i++) {
      final double dotAngle = i * (2 * math.pi / dotsCount);
      canvas.drawCircle(
        Offset(math.cos(dotAngle) * 106, math.sin(dotAngle) * 106),
        1.5,
        dotPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CyberOrbitPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
