import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/util/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/approval.dart';
import '../bloc/approval_bloc.dart';
import '../bloc/approval_event.dart';
import '../bloc/approval_state.dart';
import 'approval_detail_page.dart';

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
  String _selectedFilter = 'all'; // 'all', 'pending', 'approved', 'rejected'

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

  List<Approval> _filterApprovals(List<Approval> approvals) {
    return approvals.where((approval) {
      // Filter berdasarkan status
      bool matchesFilter = true;
      switch (_selectedFilter) {
        case 'pending':
          matchesFilter = approval.approved == 0;
          break;
        case 'approved':
          matchesFilter = approval.approved == 1;
          break;
        case 'rejected':
          matchesFilter = approval.approved == 2;
          break;
        default:
          matchesFilter = true;
      }

      // Filter berdasarkan pencarian
      bool matchesSearch = _searchQuery.isEmpty ||
          approval.namaBawahan
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          approval.details.any((detail) =>
              detail.tujuanData.namaDokter
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              detail.tglVisit.contains(_searchQuery));

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Persetujuan Jadwal',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan nama atau tanggal...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Belum Disetujui', 'pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Disetujui', 'approved'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Ditolak', 'rejected'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // List Content
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  return BlocConsumer<ApprovalBloc, ApprovalState>(
                    listener: (context, state) {
                      if (state is ApprovalSent) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.response.message),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _loadApprovals();
                      } else if (state is ApprovalError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is ApprovalLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is ApprovalsLoaded) {
                        final filteredApprovals =
                            _filterApprovals(state.approvals);
                        return _buildApprovalList(filteredApprovals);
                      } else if (state is ApprovalsEmpty) {
                        return _buildEmptyState();
                      } else if (state is ApprovalError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 80,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Terjadi Kesalahan',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.message,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadApprovals,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  );
                } else {
                  return const Center(
                    child: Text('Silakan login terlebih dahulu'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Persetujuan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semua jadwal sudah disetujui',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalList(List<Approval> approvals) {
    return approvals.isEmpty
        ? _buildEmptyState()
        : RefreshIndicator(
            onRefresh: () async {
              _loadApprovals();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: approvals.length,
              itemBuilder: (context, index) {
                final approval = approvals[index];
                return _buildApprovalCard(approval);
              },
            ),
          );
  }

  Widget _buildApprovalCard(Approval approval) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (approval.approved) {
      case 1:
        statusText = 'Disetujui';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 2:
        statusText = 'Ditolak';
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusText = 'Belum Disetujui';
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ApprovalDetailPage(
                  approval: approval,
                  userId: authState.user.idUser,
                ),
              ),
            ).then((_) => _loadApprovals());
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: statusColor,
                width: 6,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        approval.namaBawahan,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: statusColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 16,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total Jadwal: ${approval.totalSchedule}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Periode: ${approval.month}/${approval.year}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthAuthenticated) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ApprovalDetailPage(
                                approval: approval,
                                userId: authState.user.idUser,
                              ),
                            ),
                          ).then((_) => _loadApprovals());
                        }
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('Lihat Detail'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
