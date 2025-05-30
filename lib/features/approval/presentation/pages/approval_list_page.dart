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
  final List<String> _filterOptions = [
    'Semua',
    'Menunggu',
    'Disetujui',
    'Ditolak'
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Daftar Persetujuan',
        actions: [
          // Dropdown filter
          PopupMenuButton<int>(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.filter_list),
                if (_selectedFilter != 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _selectedFilter == 1
                            ? AppTheme.warningColor
                            : _selectedFilter == 2
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Filter',
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onSelected: (int index) {
              _onFilterChanged(index);
            },
            itemBuilder: (BuildContext context) {
              return List.generate(_filterOptions.length, (index) {
                return PopupMenuItem<int>(
                  value: index,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _filterOptions[index],
                        style: GoogleFonts.poppins(
                          color: index == 0
                              ? Colors.grey[800]
                              : index == 1
                                  ? AppTheme.warningColor
                                  : index == 2
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor,
                          fontWeight: _selectedFilter == index
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (_selectedFilter == index)
                        Icon(
                          Icons.check,
                          color: index == 0
                              ? Colors.grey[800]
                              : index == 1
                                  ? AppTheme.warningColor
                                  : index == 2
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor,
                          size: 18,
                        ),
                    ],
                  ),
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApprovals,
            tooltip: 'Refresh',
          ),
        ],
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
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    // Tambahkan suffix icon untuk menampilkan filter yang dipilih
                    suffixIcon: _selectedFilter != 0
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(
                                _filterOptions[_selectedFilter],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _selectedFilter == 1
                                      ? AppTheme.warningColor
                                      : _selectedFilter == 2
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: _selectedFilter == 1
                                  ? AppTheme.warningColor.withOpacity(0.1)
                                  : _selectedFilter == 2
                                      ? AppTheme.successColor.withOpacity(0.1)
                                      : AppTheme.errorColor.withOpacity(0.1),
                              deleteIcon: Icon(
                                Icons.close,
                                size: 16,
                                color: _selectedFilter == 1
                                    ? AppTheme.warningColor
                                    : _selectedFilter == 2
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor,
                              ),
                              onDeleted: () => _onFilterChanged(0),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  // Cek apakah user memiliki role yang diizinkan
                  final allowedRoles = [
                    'ADMIN',
                    'GM',
                    'BCO',
                    'RSM',
                    'DM',
                    'AM'
                  ];
                  if (!allowedRoles.contains(authState.user.role)) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Anda tidak memiliki akses ke fitur ini',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Silakan hubungi administrator untuk informasi lebih lanjut',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

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
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: AppTheme.errorColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Gagal memuat data',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                AppButton(
                                  text: 'Coba Lagi',
                                  onPressed: _loadApprovals,
                                  type: AppButtonType.primary,
                                  prefixIcon:
                                      const Icon(Icons.refresh, size: 18),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (state is ApprovalLoaded) {
                        final approvals = state.approvals.where((approval) {
                          final matchesSearch = approval.namaBawahan
                              .toLowerCase()
                              .contains(_searchQuery);

                          bool matchesFilter = true;
                          if (_selectedFilter != 0) {
                            // Filter berdasarkan status
                            // 1: Menunggu (approved = 0)
                            // 2: Disetujui (approved = 1)
                            // 3: Ditolak (approved = 2)
                            matchesFilter =
                                approval.approved == (_selectedFilter - 1);
                          }

                          return matchesSearch && matchesFilter;
                        }).toList();

                        if (approvals.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _searchQuery.isNotEmpty
                                        ? Icons.search_off
                                        : Icons.inbox_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Tidak ada persetujuan yang sesuai dengan pencarian'
                                        : 'Tidak ada persetujuan yang perlu diproses',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty) ...[
                                    const SizedBox(height: 24),
                                    AppButton(
                                      text: 'Reset Pencarian',
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                      type: AppButtonType.outline,
                                      prefixIcon:
                                          const Icon(Icons.refresh, size: 18),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async => _loadApprovals(),
                          child: ListView.builder(
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
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
