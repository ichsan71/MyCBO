import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';
import 'package:test_cbo/features/ranking_achievement/domain/entities/ranking_achievement_entity.dart';
import 'package:test_cbo/features/ranking_achievement/presentation/bloc/ranking_achievement_bloc.dart';
import 'package:test_cbo/features/ranking_achievement/presentation/widgets/ranking_achievement_shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RankingAchievementWidget extends StatefulWidget {
  final String roleId;
  final int currentUserId;

  const RankingAchievementWidget({
    Key? key,
    required this.roleId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<RankingAchievementWidget> createState() =>
      _RankingAchievementWidgetState();
}

class _RankingAchievementWidgetState extends State<RankingAchievementWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _slideController;
  late AnimationController _cloudAnimationController;
  late AnimationController _rocketAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _cloudAnimation;
  late Animation<double> _rocketAnimation;

  // Add scroll controller for ranking list
  final ScrollController _rankingScrollController = ScrollController();
  final GlobalKey _regularListKey = GlobalKey();

  // Add expand/collapse state
  bool _isExpanded = false;

  String _selectedMonth = DateTime.now().month.toString().padLeft(2, '0');
  final List<String> _months = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    _cloudAnimationController.dispose();
    _rocketAnimationController.dispose();
    _rankingScrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cloudAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _rocketAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _cloudAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cloudAnimationController,
      curve: Curves.easeInOut,
    ));

    _rocketAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rocketAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _loadData() {
    context.read<RankingAchievementBloc>().add(
          GetRankingAchievementEvent(widget.roleId, _selectedMonth),
        );
    // Start cloud animation
    _cloudAnimationController.repeat(reverse: true);
    // Start rocket animation (one-way only)
    _rocketAnimationController.repeat();
  }

  void _onMonthChanged(String month) {
    setState(() {
      _selectedMonth = month;
    });

    context.read<RankingAchievementBloc>().add(
          GetRankingAchievementEvent(widget.roleId, month),
        );
  }

  void _refreshData() {
    context.read<RankingAchievementBloc>().add(
          RefreshRankingAchievementEvent(widget.roleId, _selectedMonth),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RankingAchievementBloc, RankingAchievementState>(
      listener: (context, state) {
        if (state is RankingAchievementLoaded) {
          _animationController.forward();
          _slideController.forward();
        }
      },
      builder: (context, state) {
        if (state is RankingAchievementLoading) {
          return const RankingAchievementShimmer();
        } else if (state is RankingAchievementLoaded) {
          return _buildRankingContent(state);
        } else if (state is RankingAchievementError) {
          return _buildErrorWidget(state.message);
        } else {
          return const RankingAchievementShimmer();
        }
      },
    );
  }

  Widget _buildRankingContent(RankingAchievementLoaded state) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildMonthFilter(),
                  const SizedBox(height: 16),
                  _buildRankingList(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.rankingAchievement,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
        IconButton(
          onPressed: _refreshData,
          icon: Icon(
            Icons.refresh_rounded,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildMonthFilter() {
    return Container(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        itemBuilder: (context, index) {
          final month = _months[index];
          final isSelected = month == _selectedMonth;
          final monthNames = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'Mei',
            'Jun',
            'Jul',
            'Ags',
            'Sep',
            'Okt',
            'Nov',
            'Des'
          ];

          return GestureDetector(
            onTap: () => _onMonthChanged(month),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppTheme.getPrimaryColor(context),
                          AppTheme.getPrimaryColor(context).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected
                    ? null
                    : AppTheme.getCardBackgroundColor(context),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.getPrimaryColor(context)
                      : AppTheme.getBorderColor(context),
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.getPrimaryColor(context)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    monthNames[index],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankingList(RankingAchievementLoaded state) {
    if (state.displayRankings.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Column(
            children: [
              // Top 3 Section with blue background
              if (state.sortedRankings.length >= 3) _buildTop3Section(state),

              // Regular list for rank 4+
              if (state.sortedRankings.length > 3) ...[
                const SizedBox(height: 16),
                _buildRegularListSection(state),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTop3Section(RankingAchievementLoaded state) {
    final top3 = state.sortedRankings.take(3).toList();

    return Container(
      width: double.infinity,
      height: 360, // Increased height to fix overflow
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF87CEEB), // Sky blue
            const Color(0xFF4682B4), // Steel blue
            const Color(0xFF1E90FF), // Dodger blue
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF87CEEB).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Rocket animation from bottom-left to top-right (one-way only)
          AnimatedBuilder(
            animation: _rocketAnimation,
            builder: (context, child) {
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = 360.0; // Card height

              // Calculate diagonal movement (one-way only)
              final startX = -30.0;
              final endX = screenWidth + 30.0;
              final startY = screenHeight - 30.0;
              final endY = -30.0;

              // Use only forward movement (0 to 1) without reverse
              final progress = _rocketAnimation.value;
              final currentX = startX + (progress * (endX - startX));
              final currentY = startY + (progress * (endY - startY));

              // Only show rocket when it's within visible bounds
              if (currentX >= -50 &&
                  currentX <= screenWidth + 50 &&
                  currentY >= -50 &&
                  currentY <= screenHeight + 50) {
                return Positioned(
                  top: currentY,
                  left: currentX,
                  child: Transform.rotate(
                    angle: -0.3, // Diagonal upward angle
                    child: Icon(
                      Icons.rocket_launch,
                      color: Colors.white.withOpacity(0.9),
                      size: 28,
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink(); // Hide when out of bounds
              }
            },
          ),

          // Multiple animated background clouds - positioned at top only
          AnimatedBuilder(
            animation: _cloudAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Cloud 1 - Top left, moving slowly
                  Positioned(
                    top: 8 + (_cloudAnimation.value * 6),
                    left: 10 + (_cloudAnimation.value * 2),
                    child: Transform.scale(
                      scale: 0.8 + (_cloudAnimation.value * 0.2),
                      child: Icon(
                        Icons.cloud,
                        color: Colors.white.withOpacity(0.4),
                        size: 28,
                      ),
                    ),
                  ),
                  // Cloud 2 - Top right, moving faster
                  Positioned(
                    top: 12 - (_cloudAnimation.value * 5),
                    right: 15 + (_cloudAnimation.value * 6),
                    child: Transform.scale(
                      scale: 0.6 + (_cloudAnimation.value * 0.3),
                      child: Icon(
                        Icons.cloud,
                        color: Colors.white.withOpacity(0.3),
                        size: 24,
                      ),
                    ),
                  ),
                  // Cloud 3 - Top center
                  Positioned(
                    top: 20 + (_cloudAnimation.value * 3),
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Transform.scale(
                        scale: 0.7 + (_cloudAnimation.value * 0.2),
                        child: Icon(
                          Icons.cloud,
                          color: Colors.white.withOpacity(0.25),
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  // Cloud 4 - Top left center
                  Positioned(
                    top: 15 + (_cloudAnimation.value * 4),
                    left: 80 + (_cloudAnimation.value * 3),
                    child: Transform.scale(
                      scale: 0.5 + (_cloudAnimation.value * 0.2),
                      child: Icon(
                        Icons.cloud,
                        color: Colors.white.withOpacity(0.2),
                        size: 22,
                      ),
                    ),
                  ),
                  // Cloud 5 - Top right center
                  Positioned(
                    top: 18 - (_cloudAnimation.value * 3),
                    right: 80 + (_cloudAnimation.value * 4),
                    child: Transform.scale(
                      scale: 0.55 + (_cloudAnimation.value * 0.25),
                      child: Icon(
                        Icons.cloud,
                        color: Colors.white.withOpacity(0.15),
                        size: 23,
                      ),
                    ),
                  ),
                  // Cloud 6 - Far top left
                  Positioned(
                    top: 5 + (_cloudAnimation.value * 2),
                    left: 5 + (_cloudAnimation.value * 1),
                    child: Transform.scale(
                      scale: 0.45 + (_cloudAnimation.value * 0.15),
                      child: Icon(
                        Icons.cloud,
                        color: Colors.white.withOpacity(0.1),
                        size: 20,
                      ),
                    ),
                  ),
                  // Cloud 7 - Far top right
                  Positioned(
                    top: 8 - (_cloudAnimation.value * 2),
                    right: 5 + (_cloudAnimation.value * 2),
                    child: Transform.scale(
                      scale: 0.4 + (_cloudAnimation.value * 0.1),
                      child: Icon(
                        Icons.cloud,
                        color: Colors.white.withOpacity(0.08),
                        size: 18,
                      ),
                    ),
                  ),
                  // Cloud 8 - Middle top
                  Positioned(
                    top: 25 + (_cloudAnimation.value * 2),
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Transform.translate(
                        offset: Offset((_cloudAnimation.value - 0.5) * 20, 0),
                        child: Transform.scale(
                          scale: 0.6 + (_cloudAnimation.value * 0.1),
                          child: Icon(
                            Icons.cloud,
                            color: Colors.white.withOpacity(0.12),
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Top 3 layout with proper spacing
          Column(
            children: [
              // Spacer for cloud animations
              const SizedBox(height: 24),

              // Top section with medals and names
              Flexible(
                flex: 4,
                fit: FlexFit.loose,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Rank 2 (Left)
                    if (top3.length > 1)
                      Flexible(
                        fit: FlexFit.loose,
                        child: _buildTop3Item(top3[1], 2, false),
                      ),

                    // Rank 1 (Center) - Larger
                    Flexible(
                      flex: 2,
                      fit: FlexFit.loose,
                      child: _buildTop3Item(top3[0], 1, true),
                    ),

                    // Rank 3 (Right)
                    if (top3.length > 2)
                      Flexible(
                        fit: FlexFit.loose,
                        child: _buildTop3Item(top3[2], 3, false),
                      ),
                  ],
                ),
              ),

              // Bottom section with bar charts
              Flexible(
                flex: 3,
                fit: FlexFit.loose,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Rank 2 bar (Left)
                    if (top3.length > 1)
                      Flexible(
                        fit: FlexFit.loose,
                        child: _buildTop3BarChart(top3[1], 2, false),
                      ),

                    // Rank 1 bar (Center) - Larger
                    Flexible(
                      flex: 2,
                      fit: FlexFit.loose,
                      child: _buildTop3BarChart(top3[0], 1, true),
                    ),

                    // Rank 3 bar (Right)
                    if (top3.length > 2)
                      Flexible(
                        fit: FlexFit.loose,
                        child: _buildTop3BarChart(top3[2], 3, false),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTop3Item(
      RankingAchievementEntity ranking, int rank, bool isCenter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Medal badge only (no profile photo)
          Container(
            width: isCenter ? 70 : 60,
            height: isCenter ? 70 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _getMedalGradient(rank),
              ),
              boxShadow: [
                BoxShadow(
                  color: _getMedalGradient(rank)[0].withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: isCenter ? 35 : 30,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Name
          Text(
            ranking.nama,
            style: GoogleFonts.poppins(
              fontSize: isCenter ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Rayon name (smaller text)
          Text(
            ranking.kodeRayon,
            style: GoogleFonts.poppins(
              fontSize: isCenter ? 11 : 10,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTop3BarChart(
      RankingAchievementEntity ranking, int rank, bool isCenter) {
    final achievementValue = ranking.monthlyAchievements[_selectedMonth] ?? '-';
    final achievement = double.tryParse(achievementValue) ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          // Spacer to push bar chart to bottom
          const Spacer(),
          // Bar chart with height based on rank
          Container(
            width: isCenter ? 60 : 50,
            height: _getBarChartHeight(rank, isCenter),
            decoration: BoxDecoration(
              color: _getTop3RankColor(rank),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: _getTop3RankColor(rank).withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Percentage text inside bar chart
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Text(
                    achievementValue == '-'
                        ? '-'
                        : '${achievement.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: isCenter ? 12 : 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Rank number at bottom of bar chart
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Text(
                    rank.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: isCenter ? 16 : 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularListSection(RankingAchievementLoaded state) {
    final regularRankings = state.sortedRankings.skip(3).toList();

    return Container(
      key: _regularListKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with toggle button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Peringkat Lainnya',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                if (regularRankings.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });

                      // Auto-scroll to expanded content after animation
                      if (_isExpanded) {
                        Future.delayed(const Duration(milliseconds: 350), () {
                          // Ensure the expanded content is visible in parent scroll view first
                          final context = this.context;
                          if (context.mounted) {
                            final scrollable = Scrollable.of(context);
                            if (scrollable != null) {
                              // Find the regular list section using the key
                              final regularListContext =
                                  _regularListKey.currentContext;
                              if (regularListContext != null) {
                                final renderBox = regularListContext
                                    .findRenderObject() as RenderBox?;
                                if (renderBox != null) {
                                  scrollable.position.ensureVisible(
                                    renderBox,
                                    alignment:
                                        0.1, // Slightly below top to show header
                                    duration: const Duration(milliseconds: 600),
                                  );
                                }
                              }
                            }
                          }

                          // Then scroll to top of expanded list
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (_rankingScrollController.hasClients) {
                              _rankingScrollController.animateTo(
                                0.0, // Scroll to top of the list
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          });
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            AppTheme.getPrimaryColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.getPrimaryColor(context)
                              .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isExpanded ? 'Sembunyikan' : 'Lihat Semua',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getPrimaryColor(context),
                            ),
                          ),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: AppTheme.getPrimaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Expandable content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded
                ? (regularRankings.length * 70.0).clamp(0.0, 300.0)
                : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isExpanded ? 1.0 : 0.0,
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _rankingScrollController,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: regularRankings.length,
                    itemBuilder: (context, index) {
                      final ranking = regularRankings[index];
                      final actualRank = index + 4; // Start from rank 4
                      final isCurrentUser =
                          ranking.idUser == widget.currentUserId;

                      return _buildRegularRankingItem(
                        ranking: ranking,
                        rank: actualRank,
                        isCurrentUser: isCurrentUser,
                        selectedMonth: state.selectedMonth,
                      );
                    },
                  ),
                  if (regularRankings.length > 5 && _isExpanded)
                    Positioned(
                      bottom: 6,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.getPrimaryColor(context)
                                .withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe_vertical,
                              size: 14,
                              color: AppTheme.getPrimaryColor(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Scroll',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.getPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularRankingItem({
    required RankingAchievementEntity ranking,
    required int rank,
    required bool isCurrentUser,
    required String selectedMonth,
  }) {
    final achievementValue = ranking.monthlyAchievements[selectedMonth] ?? '-';
    final achievement = double.tryParse(achievementValue) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppTheme.getPrimaryColor(context).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? AppTheme.getPrimaryColor(context)
              : AppTheme.getBorderColor(context),
          width: isCurrentUser ? 2.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.getSecondaryTextColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking.nama,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  ranking.kodeRayon,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Achievement percentage
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getAchievementColor(achievement).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getAchievementColor(achievement).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              achievementValue == '-'
                  ? '-'
                  : '${achievement.toStringAsFixed(1)}%',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getAchievementColor(achievement),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getMedalGradient(int rank) {
    switch (rank) {
      case 1:
        return [
          const Color(0xFFFFD700), // Gold
          const Color(0xFFFFA500), // Orange
        ];
      case 2:
        return [
          const Color(0xFFC0C0C0), // Silver
          const Color(0xFFA0A0A0), // Light gray
        ];
      case 3:
        return [
          const Color(0xFFCD7F32), // Bronze
          const Color(0xFFB8860B), // Dark goldenrod
        ];
      default:
        return [
          AppTheme.getPrimaryColor(context),
          AppTheme.getPrimaryColor(context).withOpacity(0.8),
        ];
    }
  }

  Color _getAchievementColor(double achievement) {
    if (achievement >= 80) {
      return Colors.green;
    } else if (achievement >= 60) {
      return Colors.orange;
    } else if (achievement >= 40) {
      return Colors.yellow[700]!;
    } else {
      return Colors.red;
    }
  }

  Color _getTop3RankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold (same as medal)
      case 2:
        return const Color(0xFFC0C0C0); // Silver (same as medal)
      case 3:
        return const Color(0xFFCD7F32); // Bronze (same as medal)
      default:
        return AppTheme.getPrimaryColor(context);
    }
  }

  double _getBarChartHeight(int rank, bool isCenter) {
    // Base height for center (rank 1) is higher
    final baseHeight = isCenter ? 120.0 : 100.0;

    // Adjust height based on rank (1st highest, 3rd lowest)
    switch (rank) {
      case 1:
        return baseHeight; // Highest
      case 2:
        return baseHeight * 0.85; // Medium
      case 3:
        return baseHeight * 0.7; // Lowest
      default:
        return baseHeight * 0.8;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: AppTheme.getSecondaryTextColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data peringkat untuk bulan ini',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
