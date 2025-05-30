import 'package:equatable/equatable.dart';
import 'schedule_model.dart';
import '../../../../core/utils/logger.dart';

class ScheduleDataModel extends Equatable {
  final List<ScheduleModel> data;

  const ScheduleDataModel({required this.data});

  factory ScheduleDataModel.empty() {
    return const ScheduleDataModel(data: []);
  }

  factory ScheduleDataModel.fromJson(Map<String, dynamic> json) {
    Logger.info('ScheduleDataModel', 'Processing JSON data');
    Logger.info('ScheduleDataModel', 'Keys in json: ${json.keys.toList()}');

    if (json['data'] == null) {
      Logger.warning('ScheduleDataModel', 'Data field is null');
      return ScheduleDataModel.empty();
    }

    if (json['data'] is! List) {
      Logger.warning('ScheduleDataModel',
          'Data field is not a List: ${json['data'].runtimeType}');
      return ScheduleDataModel.empty();
    }

    try {
      final List<dynamic> scheduleList = json['data'] as List;
      Logger.info('ScheduleDataModel',
          'Number of schedules in data: ${scheduleList.length}');

      final schedules = scheduleList.map((scheduleJson) {
        Logger.info('ScheduleDataModel', 'Processing schedule: $scheduleJson');
        return ScheduleModel.fromJson(scheduleJson);
      }).toList();

      Logger.info('ScheduleDataModel',
          'Successfully processed ${schedules.length} schedules');
      return ScheduleDataModel(data: schedules);
    } catch (e) {
      Logger.error('ScheduleDataModel', 'Error processing schedules: $e');
      return ScheduleDataModel.empty();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data
          // ignore: unnecessary_type_check
          .map((schedule) => schedule is ScheduleModel
              ? schedule.toJson()
              : throw Exception('Invalid schedule type'))
          .toList(),
    };
  }

  @override
  List<Object?> get props => [data];
}
