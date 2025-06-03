import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_bar_widget.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../bloc/approval_bloc.dart';
import '../widgets/approval_card.dart';
import '../widgets/shimmer_loading.dart';
import 'approval_detail_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/approval.dart' as approval_entity;
import '../../domain/entities/monthly_approval.dart' as monthly_entity;
import '../widgets/monthly_approval_card.dart';

class ApprovalListPage extends StatelessWidget {
  const ApprovalListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ApprovalBloc>(),
      child: const ApprovalListView(),
    );
  }
}

class ApprovalListView extends StatefulWidget {
  const ApprovalListView({Key? key}) : super(key: key);

  @override
  _ApprovalListViewState createState() => _ApprovalListViewState();
}

class _ApprovalListViewState extends State<ApprovalListView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadApprovals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _loadApprovals();
    }
  }

  void _loadApprovals() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (_tabController.index == 0) {
        context.read<ApprovalBloc>().add(
              GetMonthlyApprovals(userId: authState.user.idUser),
            );
      } else {
        context.read<ApprovalBloc>().add(
              GetApprovals(userId: authState.user.idUser),
            );
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const BackButton(color: Colors.white),
                          Text(
                            'Daftar Persetujuan',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                            onPressed: _loadApprovals,
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Bulanan'),
                        Tab(text: 'Dadakan'),
                      ],
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                      ),
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.white70,
                      indicatorSize: TabBarIndicatorSize.tab,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    hintText: 'Cari nama bawahan...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey[600],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    _buildApprovalList(context, context.read<AuthBloc>().state),
                    _buildApprovalList(context, context.read<AuthBloc>().state),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalList(BuildContext context, AuthState authState) {
    if (authState is! AuthAuthenticated) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocBuilder<ApprovalBloc, ApprovalState>(
      builder: (context, state) {
        if (state is ApprovalLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ApprovalError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: GoogleFonts.poppins(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadApprovals,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is ApprovalLoaded || state is MonthlyApprovalLoaded) {
          final approvals = _tabController.index == 0
              ? (state is MonthlyApprovalLoaded ? state.approvals : [])
              : (state is ApprovalLoaded ? state.approvals : []);

          if (approvals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada persetujuan',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final filteredApprovals = _filterApprovals(approvals);

          if (filteredApprovals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada hasil pencarian',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredApprovals.length,
            itemBuilder: (context, index) {
              final currentApproval = filteredApprovals[index];
              if (_tabController.index == 0) {
                if (currentApproval is monthly_entity.MonthlyApproval) {
                  return MonthlyApprovalCard(
                    approval: currentApproval,
                    onTap: () => _navigateToDetail(currentApproval, true),
                  );
                }
              } else {
                if (currentApproval is approval_entity.Approval) {
                  return ApprovalCard(
                    approval: currentApproval,
                    onTap: () => _navigateToDetail(currentApproval, false),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  List<dynamic> _filterApprovals(List<dynamic> approvals) {
    if (_searchQuery.isEmpty) {
      return approvals;
    }

    return approvals.where((approval) {
      final namaBawahan = approval is monthly_entity.MonthlyApproval
          ? approval.namaBawahan.toLowerCase()
          : (approval as approval_entity.Approval).namaBawahan.toLowerCase();
      return namaBawahan.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _navigateToDetail(dynamic approval, bool isMonthlyTab) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApprovalDetailPage(
          approval: approval,
          userId: (context.read<AuthBloc>().state as AuthAuthenticated)
              .user
              .idUser
              .toString(),
          isMonthlyTab: isMonthlyTab,
        ),
      ),
    ).then((_) => _loadApprovals());
  }
}
