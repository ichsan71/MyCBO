import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/chat_question.dart';
import '../../domain/entities/chat_feedback.dart';

class ChatFeedbackWidget extends StatefulWidget {
  final ChatQuestion question;
  final bool feedbackSubmitted;
  final Function(ChatFeedback) onFeedbackSubmitted;
  final VoidCallback onNewConversation;

  const ChatFeedbackWidget({
    super.key,
    required this.question,
    required this.feedbackSubmitted,
    required this.onFeedbackSubmitted,
    required this.onNewConversation,
  });

  @override
  State<ChatFeedbackWidget> createState() => _ChatFeedbackWidgetState();
}

class _ChatFeedbackWidgetState extends State<ChatFeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  FeedbackType? _selectedFeedback;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (!widget.feedbackSubmitted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ChatFeedbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feedbackSubmitted && !oldWidget.feedbackSubmitted) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _submitFeedback(FeedbackType type) {
    if (widget.feedbackSubmitted) return;

    setState(() {
      _selectedFeedback = type;
    });

    final feedback = ChatFeedback(
      id: 'feedback_${DateTime.now().millisecondsSinceEpoch}',
      questionId: widget.question.id,
      feedbackType: type,
      timestamp: DateTime.now(),
      userId: 'current_user', // This should come from auth
    );

    widget.onFeedbackSubmitted(feedback);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.feedbackSubmitted) ...[
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Apakah jawaban ini membantu?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FeedbackButton(
                  icon: Icons.thumb_up_outlined,
                  filledIcon: Icons.thumb_up,
                  label: 'Membantu',
                  isSelected: _selectedFeedback == FeedbackType.helpful,
                  color: Colors.green,
                  onTap: () => _submitFeedback(FeedbackType.helpful),
                ),
                const SizedBox(width: 24),
                _FeedbackButton(
                  icon: Icons.thumb_down_outlined,
                  filledIcon: Icons.thumb_down,
                  label: 'Tidak Membantu',
                  isSelected: _selectedFeedback == FeedbackType.notHelpful,
                  color: Colors.red,
                  onTap: () => _submitFeedback(FeedbackType.notHelpful),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Terima kasih atas feedback Anda!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onNewConversation,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: Text(
                    'Percakapan Baru',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: Text(
                    'Tutup Chat',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedbackButton extends StatefulWidget {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.filledIcon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  State<_FeedbackButton> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends State<_FeedbackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              _animationController.forward();
            },
            onTapUp: (_) {
              _animationController.reverse();
              widget.onTap();
            },
            onTapCancel: () {
              _animationController.reverse();
            },
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? widget.color
                        : widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: widget.isSelected
                          ? widget.color
                          : widget.color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    widget.isSelected ? widget.filledIcon : widget.icon,
                    color: widget.isSelected ? Colors.white : widget.color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: widget.isSelected ? widget.color : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
