import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/chatbot_bloc.dart';
import '../bloc/chatbot_event.dart';
import '../bloc/chatbot_state.dart';
import '../../data/datasources/chatbot_local_data_source.dart';
import '../widgets/chat_category_selector.dart';
import '../widgets/chat_feedback_widget.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/chat_question_selector.dart';
import '../widgets/chat_typing_indicator.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isUserScrolling = false;
  bool _shouldAutoScroll = true;
  int _lastMessageCount = 0;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _getUserRoleFromContext();
  }

  void _getUserRoleFromContext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        setState(() {
          _userRole = authState.user.role;
        });
      } else {
        setState(() {
          _userRole = 'UNKNOWN';
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isAtBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50;

      setState(() {
        _isUserScrolling = !isAtBottom;
        _shouldAutoScroll = isAtBottom;
      });
    }
  }

  void _scrollToBottom({bool force = false}) {
    if (_scrollController.hasClients && (_shouldAutoScroll || force)) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _checkForNewMessages(ChatbotState state) {
    final currentMessageCount = _getMessagesCount(state);

    // Auto scroll jika ada pesan baru atau jika di posisi bottom
    if (currentMessageCount > _lastMessageCount || _shouldAutoScroll) {
      _scrollToBottom();
    }

    _lastMessageCount = currentMessageCount;
  }

  /// Get user role from AuthBloc
  String _getUserRole() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.role;
    }
    return 'UNKNOWN'; // Default fallback
  }

  /// Clear cache and reload data fresh from assets
  void _clearCacheAndReload() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Clearing cache and reloading...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Get the local data source and clear cache
      final localDataSource = di.sl<ChatbotLocalDataSource>();
      await localDataSource.clearCache();

      // Reset scroll tracking
      setState(() {
        _lastMessageCount = 0;
        _shouldAutoScroll = true;
        _isUserScrolling = false;
      });

      // Reload categories with fresh data
      if (_userRole != null) {
        context
            .read<ChatbotBloc>()
            .add(LoadCategoriesEvent(userRole: _userRole!));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing cache: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      floatingActionButton: _buildScrollToBottomButton(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.getSurfaceColor(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: AppTheme.getPrimaryTextColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2196F3),
                    Color(0xFF1976D2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tanya Mazbot',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                ),
                Text(
                  'Asisten Virtual Anda',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.refresh,
                color: AppTheme.getPrimaryTextColor(context)),
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  context.read<ChatbotBloc>().add(const RefreshDataEvent());
                  break;
                case 'clear_cache':
                  _clearCacheAndReload();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Refresh Data',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_cache',
                child: Row(
                  children: [
                    const Icon(Icons.clear_all, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Clear Cache & Reload',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              switch (value) {
                case 'new_conversation':
                  // Reset scroll tracking untuk percakapan baru
                  setState(() {
                    _lastMessageCount = 0;
                    _shouldAutoScroll = true;
                    _isUserScrolling = false;
                  });
                  context
                      .read<ChatbotBloc>()
                      .add(StartNewConversationEvent(userRole: _getUserRole()));
                  break;
                case 'help':
                  _showHelpDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'new_conversation',
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Percakapan Baru',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    const Icon(Icons.help_outline, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Bantuan',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _userRole == null
          ? const Center(child: CircularProgressIndicator())
          : BlocProvider(
              create: (context) => di.sl<ChatbotBloc>()
                ..add(LoadCategoriesEvent(userRole: _userRole!)),
              child: BlocConsumer<ChatbotBloc, ChatbotState>(
                listener: (context, state) {
                  if (state is ChatbotError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }

                  // Check for new messages and auto scroll if needed
                  if (state is ChatbotCategoriesLoaded ||
                      state is ChatbotQuestionsLoaded ||
                      state is ChatbotConversation) {
                    _checkForNewMessages(state);
                  }
                },
                builder: (context, state) {
                  if (state is ChatbotLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is ChatbotError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Terjadi kesalahan',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<ChatbotBloc>().add(
                                  LoadCategoriesEvent(userRole: _userRole!));
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Chat messages area
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _getMessagesCount(state) +
                              (_isTyping(state) ? 1 : 0),
                          itemBuilder: (context, index) {
                            final messages = _getMessages(state);

                            // Show typing indicator as last item
                            if (_isTyping(state) && index == messages.length) {
                              return const ChatTypingIndicator();
                            }

                            // Show regular message
                            if (index < messages.length) {
                              return ChatMessageWidget(
                                message: messages[index],
                                onAnimationComplete: () {
                                  // Hanya auto scroll jika user tidak sedang manual scroll
                                  if (_shouldAutoScroll) {
                                    _scrollToBottom();
                                  }
                                },
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),

                      // Action area (categories, questions, or feedback)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, -2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: _buildActionArea(context, state, _userRole!),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildActionArea(
      BuildContext context, ChatbotState state, String userRole) {
    if (state is ChatbotCategoriesLoaded) {
      return ChatCategorySelector(
        categories: state.categories,
        onCategorySelected: (categoryId) {
          context.read<ChatbotBloc>().add(
                LoadQuestionsByCategoryEvent(categoryId: categoryId),
              );
        },
      );
    }

    if (state is ChatbotQuestionsLoaded) {
      return ChatQuestionSelector(
        questions: state.questions,
        onQuestionSelected: (questionId) {
          context.read<ChatbotBloc>().add(
                SelectQuestionEvent(questionId: questionId),
              );
        },
        onBackPressed: () {
          context
              .read<ChatbotBloc>()
              .add(BackToCategoriesEvent(userRole: userRole));
        },
      );
    }

    if (state is ChatbotConversation && state.currentQuestion != null) {
      return ChatFeedbackWidget(
        question: state.currentQuestion!,
        feedbackSubmitted: state.feedbackSubmitted,
        onFeedbackSubmitted: (feedback) {
          context.read<ChatbotBloc>().add(
                SubmitFeedbackEvent(feedback: feedback),
              );
        },
        onNewConversation: () {
          // Reset scroll tracking untuk percakapan baru
          setState(() {
            _lastMessageCount = 0;
            _shouldAutoScroll = true;
            _isUserScrolling = false;
          });
          context
              .read<ChatbotBloc>()
              .add(StartNewConversationEvent(userRole: userRole));
        },
      );
    }

    return const SizedBox.shrink();
  }

  List<dynamic> _getMessages(ChatbotState state) {
    if (state is ChatbotCategoriesLoaded) {
      return state.messages;
    } else if (state is ChatbotQuestionsLoaded) {
      return state.messages;
    } else if (state is ChatbotConversation) {
      return state.messages;
    } else if (state is ChatbotError) {
      return state.chatMessages;
    }
    return [];
  }

  int _getMessagesCount(ChatbotState state) {
    return _getMessages(state).length;
  }

  bool _isTyping(ChatbotState state) {
    if (state is ChatbotCategoriesLoaded) {
      return state.isTyping;
    } else if (state is ChatbotQuestionsLoaded) {
      return state.isTyping;
    } else if (state is ChatbotConversation) {
      return state.isTyping;
    }
    return false;
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Bantuan Mazbot',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cara menggunakan Mazbot:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            _helpItem('1. Pilih kategori pertanyaan'),
            _helpItem('2. Pilih pertanyaan yang sesuai'),
            _helpItem('3. Baca jawaban dari Mazbot'),
            _helpItem('4. Berikan feedback 👍 atau 👎'),
            _helpItem('5. Mulai percakapan baru jika diperlukan'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Widget _helpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 13),
      ),
    );
  }

  Widget? _buildScrollToBottomButton() {
    // Hanya tampilkan tombol jika user sedang scroll dan tidak di bottom
    if (!_shouldAutoScroll && _scrollController.hasClients) {
      return Container(
        margin: const EdgeInsets.only(bottom: 80), // Avoid action area
        child: FloatingActionButton.small(
          onPressed: () {
            setState(() {
              _shouldAutoScroll = true;
              _isUserScrolling = false;
            });
            _scrollToBottom(force: true);
          },
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(
            Icons.keyboard_arrow_down,
            size: 20,
          ),
        ),
      );
    }
    return null;
  }
}
