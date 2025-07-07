import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/chat_message.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onAnimationComplete;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onAnimationComplete,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.message.type == MessageType.user
          ? const Offset(0.3, 0)
          : const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward().then((_) {
      if (widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: widget.message.type == MessageType.user
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.message.type == MessageType.bot) ...[
                    _buildBotAvatar(),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Column(
                      crossAxisAlignment:
                          widget.message.type == MessageType.user
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: widget.message.type == MessageType.user
                                ? AppTheme.getPrimaryColor(context)
                                : AppTheme.getCardBackgroundColor(context),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft:
                                  widget.message.type == MessageType.user
                                      ? const Radius.circular(20)
                                      : const Radius.circular(4),
                              bottomRight:
                                  widget.message.type == MessageType.user
                                      ? const Radius.circular(4)
                                      : const Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            widget.message.content,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: widget.message.type == MessageType.user
                                  ? Colors.white
                                  : AppTheme.getPrimaryTextColor(context),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(widget.message.timestamp),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.message.type == MessageType.user) ...[
                    const SizedBox(width: 8),
                    _buildUserAvatar(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2196F3),
            Color(0xFF1976D2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Icon(
        Icons.smart_toy,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.getBorderColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.person,
        color: AppTheme.getSecondaryTextColor(context),
        size: 18,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
