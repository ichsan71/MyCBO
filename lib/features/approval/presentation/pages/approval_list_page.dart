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

class _ApprovalListViewState extends State<ApprovalListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: Semua, 1: Menunggu, 2: Disetujui, 3: Ditolak

  @override
  void initState() {
    super.initState();
    _loadApprovals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadApprovals() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ApprovalBloc>().add(
            GetApprovalsEvent(userId: authState.user.idUser),
          );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _onFilterChanged(int value) {
    setState(() {
      _selectedFilter = value;
    });
  }

  List<Widget> _buildFilterChips() {
    return [
      FilterChip(
        label: const Text('Semua'),
        selected: _selectedFilter == 0,
        onSelected: (bool selected) {
          if (selected) _onFilterChanged(0);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.primaryColor.withOpacity(0.15),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: GoogleFonts.poppins(
          color: _selectedFilter == 0
              ? AppTheme.primaryColor
              : AppTheme.primaryTextColor,
          fontWeight:
              _selectedFilter == 0 ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: _selectedFilter == 0
              ? AppTheme.primaryColor.withOpacity(0.5)
              : Colors.transparent,
        ),
      ),
      const SizedBox(width: 8),
      FilterChip(
        label: const Text('Menunggu'),
        selected: _selectedFilter == 1,
        onSelected: (bool selected) {
          if (selected) _onFilterChanged(1);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.warningColor.withOpacity(0.15),
        checkmarkColor: AppTheme.warningColor,
        labelStyle: GoogleFonts.poppins(
          color: _selectedFilter == 1
              ? AppTheme.warningColor
              : AppTheme.primaryTextColor,
          fontWeight:
              _selectedFilter == 1 ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: _selectedFilter == 1
              ? AppTheme.warningColor.withOpacity(0.5)
              : Colors.transparent,
        ),
      ),
      const SizedBox(width: 8),
      FilterChip(
        label: const Text('Disetujui'),
        selected: _selectedFilter == 2,
        onSelected: (bool selected) {
          if (selected) _onFilterChanged(2);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.successColor.withOpacity(0.15),
        checkmarkColor: AppTheme.successColor,
        labelStyle: GoogleFonts.poppins(
          color: _selectedFilter == 2
              ? AppTheme.successColor
              : AppTheme.primaryTextColor,
          fontWeight:
              _selectedFilter == 2 ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: _selectedFilter == 2
              ? AppTheme.successColor.withOpacity(0.5)
              : Colors.transparent,
        ),
      ),
      const SizedBox(width: 8),
      FilterChip(
        label: const Text('Ditolak'),
        selected: _selectedFilter == 3,
        onSelected: (bool selected) {
          if (selected) _onFilterChanged(3);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.errorColor.withOpacity(0.15),
        checkmarkColor: AppTheme.errorColor,
        labelStyle: GoogleFonts.poppins(
          color: _selectedFilter == 3
              ? AppTheme.errorColor
              : AppTheme.primaryTextColor,
          fontWeight:
              _selectedFilter == 3 ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: _selectedFilter == 3
              ? AppTheme.errorColor.withOpacity(0.5)
              : Colors.transparent,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Daftar Persetujuan',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari nama bawahan...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadiusSmall,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _buildFilterChips(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  return BlocBuilder<ApprovalBloc, ApprovalState>(
                    builder: (context, state) {
                      if (state is ApprovalLoading) {
                        return ListView.builder(
                          itemCount: 5,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            return const ShimmerApprovalCard();
                          },
                        );
                      } else if (state is ApprovalError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              AppButton(
                                text: 'Coba Lagi',
                                onPressed: _loadApprovals,
                                type: AppButtonType.primary,
                              ),
                            ],
                          ),
                        );
                      } else if (state is ApprovalLoaded) {
                        final approvals = state.approvals.where((approval) {
                          final matchesSearch = approval.namaBawahan
                              .toLowerCase()
                              .contains(_searchQuery);
                          final matchesFilter = _selectedFilter == 0 ||
                              (_selectedFilter == 1 &&
                                  approval.approved == 0) ||
                              (_selectedFilter == 2 &&
                                  approval.approved == 1) ||
                              (_selectedFilter == 3 && approval.approved == 2);
                          return matchesSearch && matchesFilter;
                        }).toList();

                        if (approvals.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Tidak ada data persetujuan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppButton(
                                  text: 'Muat Ulang',
                                  onPressed: _loadApprovals,
                                  type: AppButtonType.primary,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: approvals.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final approval = approvals[index];
                            return ApprovalCard(
                              approval: approval,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ApprovalDetailPage(
                                      approval: approval,
                                      userId: authState.user.idUser,
                                    ),
                                  ),
                                ).then((_) => _loadApprovals());
                              },
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
