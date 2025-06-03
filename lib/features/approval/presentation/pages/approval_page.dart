import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/approval_remote_data_source.dart';
import '../../data/repositories/approval_repository_impl.dart';
import '../bloc/approval_bloc.dart';
import '../bloc/monthly_approval_bloc.dart';
import '../widgets/immediate_approval_tab.dart';
import '../widgets/monthly_approval_tab.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ApprovalPage extends StatelessWidget {
  const ApprovalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ApprovalBloc>(
          create: (context) {
            final sharedPreferences = context.read<SharedPreferences>();
            final remoteDataSource = ApprovalRemoteDataSourceImpl(
              client: http.Client(),
              sharedPreferences: sharedPreferences,
            );
            final networkInfo = NetworkInfoImpl(InternetConnectionChecker());
            final repository = ApprovalRepositoryImpl(
              remoteDataSource: remoteDataSource,
              networkInfo: networkInfo,
            );
            return ApprovalBloc(repository: repository);
          },
        ),
        BlocProvider<MonthlyApprovalBloc>(
          create: (context) {
            final sharedPreferences = context.read<SharedPreferences>();
            final remoteDataSource = ApprovalRemoteDataSourceImpl(
              client: http.Client(),
              sharedPreferences: sharedPreferences,
            );
            final networkInfo = NetworkInfoImpl(InternetConnectionChecker());
            final repository = ApprovalRepositoryImpl(
              remoteDataSource: remoteDataSource,
              networkInfo: networkInfo,
            );
            return MonthlyApprovalBloc(repository: repository);
          },
        ),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Persetujuan'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Bulanan'),
                Tab(text: 'Dadakan'),
              ],
            ),
          ),
          body: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              MonthlyApprovalTab(),
              ImmediateApprovalTab(),
            ],
          ),
        ),
      ),
    );
  }
}
