import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../controller/speech_controller.dart';
import '../controller/tts_controller.dart';
import '../models/conversation.dart';

class ChatScene extends StatelessWidget {
  final VoidCallback onClose;

  const ChatScene({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final speechController = Provider.of<SpeechController>(context);
    final ttsController = Provider.of<TTSController>(context);

    return GestureDetector(
      onTap: () {
        // Close chat mode when tapping background
        speechController.stopConversation();
        onClose();
      },
      child: Container(
        width: double.infinity,
        color: Colors.transparent, // Ensure hit test works on empty space
        child: Column(
          children: [
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
                        // Fully transparent - no background color
                        color: Colors.transparent,
                        border: Border.all(
                          color:
                              const Color(0xFF00D9FF).withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      child: _buildConversationDisplay(
                          speechController, ttsController),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationDisplay(
      SpeechController speechController, TTSController ttsController) {
    return Container(
      child: Column(
        children: [
          // Conversation header with glassmorphism
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              // Transparent header
              color: Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF00D9FF).withOpacity(0.15),
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
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D9FF).withValues(alpha: 0.6),
                        blurRadius: 15,
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
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${speechController.conversation.messages.length ~/ 2} exchanges",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF00D9FF).withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Close button
                GestureDetector(
                  onTap: () {
                    speechController.stopConversation();
                    onClose();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 18,
                    ),
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
                    Colors.black.withValues(alpha: 0.05),
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
                    const Color(0xFF00D9FF).withValues(alpha: 0.15),
                    const Color(0xFF00D9FF).withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
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
                      color: Colors.white.withValues(alpha: 0.9),
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
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  timeStr,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00FF88).withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF88).withValues(alpha: 0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFF001122),
                    child: Icon(Icons.auto_awesome,
                        size: 14, color: Color(0xFF00FF88)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? LinearGradient(
                            colors: [
                              const Color(0xFF00D9FF).withValues(alpha: 0.15),
                              const Color(0xFF0088FF).withValues(alpha: 0.1),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              const Color(0xFF00FF88).withValues(alpha: 0.1),
                              const Color(0xFF00D9FF).withValues(alpha: 0.05),
                            ],
                          ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(24),
                      topRight: const Radius.circular(24),
                      bottomLeft: Radius.circular(isUser ? 24 : 6),
                      bottomRight: Radius.circular(isUser ? 6 : 24),
                    ),
                    border: Border.all(
                      color: isUser
                          ? const Color(0xFF00D9FF).withValues(alpha: 0.3)
                          : const Color(0xFF00FF88).withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? const Color(0xFF00D9FF).withValues(alpha: 0.08)
                            : const Color(0xFF00FF88).withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (!isUser && ttsController.isSpeaking) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: const Color(0xFF00FF88)
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Speaking...",
                              style: GoogleFonts.inter(
                                color: const Color(0xFF00FF88)
                                    .withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00D9FF).withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFF001122),
                    child:
                        Icon(Icons.person, size: 14, color: Color(0xFF00D9FF)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
