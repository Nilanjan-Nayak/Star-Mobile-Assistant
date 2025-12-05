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

// Main Star Widget - The root widget of the AI Assistant interface
class StarHome extends StatefulWidget {
  const StarHome({super.key});

  @override
  State<StarHome> createState() => _StarHomeState();
}

class _StarHomeState extends State<StarHome> with TickerProviderStateMixin {
  // State variables for UI control
  bool isBlob = true; // Controls main interface vs listening mode
  bool isBottomMic = false; // Controls bottom bar state

  // Animation controllers for various effects
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _floatController;
  late AnimationController _particleController;
  late AnimationController _rippleController;

  // Animation values
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _rippleAnimation;

  // Controller for waveform
  late WaveformController _waveformController;

  @override
  void initState() {
    super.initState();
    _waveformController = WaveformController();
    _initializeAnimations();
    _setupSystemUI();
  }

  // Initialize all animation controllers and animations
  void _initializeAnimations() {
    // Rotation animation for background elements (30 seconds loop)
    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    // Pulse animation for the main orb (2.5 seconds)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    // Glow animation for status indicators (4 seconds)
    _glowController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Float animation for subtle movement (3 seconds)
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Particle animation for background effects (5 seconds)
    _particleController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    // Ripple effect animation (2 seconds)
    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Define animation curves and values
    _pulseAnimation = Tween<double>(
      begin: 0.98,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  // Setup system UI for premium dark theme
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
    // Properly dispose all animation controllers
    _rotationController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    _particleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access speech controller from provider
    final speechController = Provider.of<SpeechController>(context);

    // Handle post-frame callback for state management
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!speechController.isListening && !isBlob && isBottomMic) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              isBottomMic = false;
            });
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // Premium animated background
          PremiumDarkBackground(
            rotationController: _rotationController,
            particleController: _particleController,
          ),

          // Main content area
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              transitionBuilder: (Widget child, Animation<double> animation) {
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
                  : _buildListeningState(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isBlob ? _buildBottomBar(speechController) : null,
    );
  }

  // Build the main interface when not listening
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

                // Header section with user info
                _buildPremiumHeader(),

                // Central AI orb with animations
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: _buildAIOrb(speechController),
                    );
                  },
                ),

                // Bottom section with assistant name and hints
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

  // Premium header with glassmorphism effect
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
                // Online status indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00FF88),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FF88)
                                    .withOpacity(_glowAnimation.value),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        );
                      },
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

                // Welcome message
                Text(
                  "Welcome back",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 8),

                // User name with gradient
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF00D9FF),
                      Color(0xFF00FF88),
                    ],
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

  // Build the central AI orb
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
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple effect circles
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

            // Main orb with pulse animation
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
                        colors: [
                          Color(0xFF001122),
                          Color(0xFF002244),
                        ],
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
                          // Star AI GIF
                          Image.asset(
                            'assets/gif/star.gif',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if GIF not found
                              return Container(
                                color: const Color(0xFF001122),
                                child: const Icon(
                                  Icons.mic,
                                  size: 70,
                                  color: Color(0xFF00D9FF),
                                ),
                              );
                            },
                          ),

                          // Glass overlay
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

  // Build bottom section with assistant name
  Widget _buildBottomSection() {
    return Column(
      children: [
        // S . T . A . R text animation
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
                atRestEffect: WidgetRestingEffects.pulse(
                  effectStrength: 0.6,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Tap hint
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

  // Build listening state UI
  Widget _buildListeningState() {
    final speechController = Provider.of<SpeechController>(context);
    final ttsController = Provider.of<TTSController>(context);

    return Container(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Header section with user info
          _buildPremiumHeader(),

          const SizedBox(height: 20),

          // Conversation display area with glassmorphism
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.03),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _buildConversationDisplay(
                        speechController, ttsController),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bottom section with assistant name
          _buildBottomSection(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Build conversation display area
  Widget _buildConversationDisplay(
      SpeechController speechController, TTSController ttsController) {
    return Container(
      child: Column(
        children: [
          // Conversation header with glassmorphism
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00D9FF).withOpacity(0.1),
                  const Color(0xFF00FF88).withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D9FF), Color(0xFF00FF88)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D9FF).withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Conversation",
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${speechController.conversation.messages.length ~/ 2} exchanges",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF00D9FF).withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Status indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF00FF88).withOpacity(0.15),
                    border: Border.all(
                      color: const Color(0xFF00FF88).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00FF88),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF88).withOpacity(0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Active",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF00FF88),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Conversation history
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.05),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: speechController.conversation.messages.reversed
                      .map((message) {
                    return _buildMessageBubble(message, ttsController);
                  }).toList(),
                ),
              ),
            ),
          ),

          // Current status indicator
          if (speechController.isProcessingAI)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D9FF).withOpacity(0.15),
                    const Color(0xFF00D9FF).withOpacity(0.08),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF00D9FF).withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D9FF).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: const Color(0xFF00D9FF),
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "S.T.A.R is analyzing...",
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Build individual message bubble
  Widget _buildMessageBubble(
      ConversationMessage message, TTSController ttsController) {
    final isUser = message.isUser;
    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender label with timestamp
          Padding(
            padding: const EdgeInsets.only(left: 44, right: 44, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isUser ? "You" : "S.T.A.R",
                  style: GoogleFonts.inter(
                    color: isUser
                        ? const Color(0xFF00D9FF)
                        : const Color(0xFF00FF88),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  timeStr,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Message content row
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                // AI Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D9FF), Color(0xFF00FF88)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D9FF).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // Message bubble
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isUser ? 18 : 4),
                      topRight: Radius.circular(isUser ? 4 : 18),
                      bottomLeft: const Radius.circular(18),
                      bottomRight: const Radius.circular(18),
                    ),
                    gradient: isUser
                        ? LinearGradient(
                            colors: [
                              const Color(0xFF00D9FF).withOpacity(0.15),
                              const Color(0xFF00D9FF).withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.03),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    border: Border.all(
                      color: isUser
                          ? const Color(0xFF00D9FF).withOpacity(0.4)
                          : Colors.white.withOpacity(0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? const Color(0xFF00D9FF).withOpacity(0.1)
                            : Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message text
                      if (!isUser &&
                          !message.isProcessing &&
                          message.error == null)
                        TextAnimator(
                          message.text,
                          incomingEffect:
                              WidgetTransitionEffects.incomingSlideInFromBottom(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutQuart,
                          ),
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      else
                        Text(
                          message.isProcessing
                              ? "Analyzing your request..."
                              : message.error ?? message.text,
                          style: GoogleFonts.inter(
                            color: message.error != null
                                ? Colors.red.withOpacity(0.9)
                                : Colors.white.withOpacity(0.95),
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                      // Action buttons row
                      if (!message.isUser &&
                          !message.isProcessing &&
                          message.error == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // TTS button with premium styling
                              GestureDetector(
                                onTap: () {
                                  if (ttsController.isSpeaking) {
                                    ttsController.stop();
                                  } else {
                                    ttsController.speak(message.text);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: LinearGradient(
                                      colors: ttsController.isSpeaking
                                          ? [
                                              Colors.red.withOpacity(0.2),
                                              Colors.red.withOpacity(0.1),
                                            ]
                                          : [
                                              const Color(0xFF00D9FF)
                                                  .withOpacity(0.2),
                                              const Color(0xFF00D9FF)
                                                  .withOpacity(0.1),
                                            ],
                                    ),
                                    border: Border.all(
                                      color: ttsController.isSpeaking
                                          ? Colors.red.withOpacity(0.4)
                                          : const Color(0xFF00D9FF)
                                              .withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ttsController.isSpeaking
                                            ? Colors.red.withOpacity(0.2)
                                            : const Color(0xFF00D9FF)
                                                .withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        ttsController.isSpeaking
                                            ? Icons.stop_circle_rounded
                                            : Icons.play_circle_rounded,
                                        color: ttsController.isSpeaking
                                            ? Colors.red
                                            : const Color(0xFF00D9FF),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        ttsController.isSpeaking
                                            ? "Stop"
                                            : "Listen",
                                        style: GoogleFonts.inter(
                                          color: ttsController.isSpeaking
                                              ? Colors.red
                                              : const Color(0xFF00D9FF),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Retry button for errors
                      if (message.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: GestureDetector(
                            onTap: () {
                              final speechController =
                                  Provider.of<SpeechController>(context,
                                      listen: false);
                              speechController.retryLastMessage();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.withOpacity(0.2),
                                    Colors.red.withOpacity(0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Try Again",
                                    style: GoogleFonts.inter(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (isUser) ...[
                const SizedBox(width: 10),
                // User Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color(0xFF00D9FF).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.white.withOpacity(0.9),
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Build bottom bar container
  Widget _buildBottomBar(SpeechController speechController) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: isBottomMic
          ? _buildListeningBar(speechController)
          : _buildNavigationBar(speechController),
    );
  }

  // Build listening bar when mic is active
  Widget _buildListeningBar(SpeechController speechController) {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color(0xFF000000),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF00D9FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 35,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),

                const SizedBox(height: 20),

                // Transcript display
                Container(
                  height: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF00FF88),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "LISTENING",
                            style: GoogleFonts.rajdhani(
                              color: const Color(0xFF00FF88),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            speechController.lastWords.isEmpty
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

                const SizedBox(height: 20),

                // Control buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Stop listening button
                      GestureDetector(
                        onTap: () {
                          speechController.stopListening();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color(0xFF00D9FF).withOpacity(0.1),
                            border: Border.all(
                              color: const Color(0xFF00D9FF).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.stop,
                                color: Color(0xFF00D9FF),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Stop & Process",
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF00D9FF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Waveform visualization
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SiriWaveform.ios9(
                    controller: _waveformController.controller,
                    options: IOS9SiriWaveformOptions(
                      height: 80,
                      width: MediaQuery.of(context).size.width - 40,
                      showSupportBar: false,
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

  // Build navigation bar when not listening
  Widget _buildNavigationBar(SpeechController speechController) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color(0xFF000000),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: BottomNav(
              onMicClick: (isClick) {
                if (isClick) {
                  setState(() {
                    isBottomMic = true;
                    speechController.startListening();
                  });
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Premium dark background with animations
class PremiumDarkBackground extends StatelessWidget {
  final AnimationController rotationController;
  final AnimationController particleController;

  const PremiumDarkBackground({
    Key? key,
    required this.rotationController,
    required this.particleController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF000511), // Very dark blue
                Color(0xFF000000), // Pure black
              ],
            ),
          ),
        ),

        // Animated gradient mesh
        AnimatedBuilder(
          animation: rotationController,
          builder: (context, child) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: GradientMeshPainter(
                animation: rotationController,
              ),
            );
          },
        ),

        // Floating particles
        ...List.generate(10, (index) {
          return AnimatedFloatingParticle(
            animation: particleController,
            delay: index * 0.15,
            initialPosition: Offset(
              math.Random().nextDouble() * MediaQuery.of(context).size.width,
              math.Random().nextDouble() * MediaQuery.of(context).size.height,
            ),
          );
        }),
      ],
    );
  }
}

// Gradient mesh painter for background
class GradientMeshPainter extends CustomPainter {
  final Animation<double> animation;

  GradientMeshPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    final time = animation.value * 2 * math.pi;

    // Blue gradient orb
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF00D9FF).withOpacity(0.08),
        const Color(0xFF00D9FF).withOpacity(0.0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(
        size.width * 0.2 + math.sin(time) * 30,
        size.height * 0.3 + math.cos(time) * 40,
      ),
      radius: 200,
    ));

    canvas.drawCircle(
      Offset(
        size.width * 0.2 + math.sin(time) * 30,
        size.height * 0.3 + math.cos(time) * 40,
      ),
      200,
      paint,
    );

    // Green gradient orb
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF00FF88).withOpacity(0.06),
        const Color(0xFF00FF88).withOpacity(0.0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(
        size.width * 0.8 + math.cos(time) * 40,
        size.height * 0.6 + math.sin(time) * 30,
      ),
      radius: 180,
    ));

    canvas.drawCircle(
      Offset(
        size.width * 0.8 + math.cos(time) * 40,
        size.height * 0.6 + math.sin(time) * 30,
      ),
      180,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Ripple effect painter for orb
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

      canvas.drawCircle(
        center,
        90 + (adjustedProgress * 60),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Animated floating particle widget
class AnimatedFloatingParticle extends StatelessWidget {
  final Animation<double> animation;
  final double delay;
  final Offset initialPosition;

  const AnimatedFloatingParticle({
    Key? key,
    required this.animation,
    required this.delay,
    required this.initialPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = ((animation.value + delay) % 1.0);
        final yOffset = MediaQuery.of(context).size.height * progress;

        return Positioned(
          left: initialPosition.dx + math.sin(progress * math.pi * 2) * 20,
          top: initialPosition.dy - yOffset,
          child: Container(
            width: 2,
            height: 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00D9FF).withOpacity(0.5 * (1 - progress)),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(0xFF00D9FF).withOpacity(0.3 * (1 - progress)),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
