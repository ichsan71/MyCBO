import 'package:equatable/equatable.dart';
import 'schedule_model.dart';
import '../../../../core/utils/logger.dart';

class ScheduleResponseModel extends Equatable {
  final bool status;
  final String desc;
  final ScheduleDataModel data;

  const ScheduleResponseModel({
    required this.status,
    required this.desc,
    required this.data,
  });

  factory ScheduleResponseModel.fromJson(dynamic json) {
    Logger.info('ScheduleResponseModel', 'Raw input type: ${json.runtimeType}');
    Logger.info('ScheduleResponseModel', 'Raw input: $json');

    if (json == null) {
      Logger.warning('ScheduleResponseModel', 'Input is null');
      return ScheduleResponseModel(
        status: false,
        desc: 'Data kosong',
        data: ScheduleDataModel.empty(),
      );
    }
    if (json is List) {
      Logger.info(
          'ScheduleResponseModel', 'Input is List with ${json.length} items');
      // Jika API mengembalikan List langsung, bungkus ke dalam Map
      if (json.isNotEmpty) {
        Logger.info(
            'ScheduleResponseModel', 'First item in data array: ${json.first}');
      }
      return ScheduleResponseModel(
        status: true,
        desc: '',
        data: ScheduleDataModel.fromJson({'data': json}),
      );
    }
    if (json is Map<String, dynamic>) {
      Logger.info('ScheduleResponseModel',
          'Input is Map with keys: ${json.keys.toList()}');
      if (json.isEmpty) {
        Logger.warning('ScheduleResponseModel', 'Input Map is empty');
        return ScheduleResponseModel(
          status: false,
          desc: 'Data kosong',
          data: ScheduleDataModel.empty(),
        );
      }
      if (json['data'] is List && (json['data'] as List).isNotEmpty) {
        Logger.info('ScheduleResponseModel',
            'First item in data array: ${(json['data'] as List).first}');
      } else if (json['data'] is Map<String, dynamic> &&
          json['data']['data'] is List &&
          (json['data']['data'] as List).isNotEmpty) {
        Logger.info('ScheduleResponseModel',
            'First item in nested data array: ${(json['data']['data'] as List).first}');
      }
      return ScheduleResponseModel(
        status: json['status'] ?? false,
        desc: json['desc'] ?? '',
        data: ScheduleDataModel.fromJson(json['data'] ?? {}),
      );
    }
    // Fallback jika tipe tidak dikenali
    Logger.error('ScheduleResponseModel',
        'Unrecognized input type: ${json.runtimeType}');
    return ScheduleResponseModel(
      status: false,
      desc: 'Format data tidak dikenali',
      data: ScheduleDataModel.empty(),
    );
  }

  factory ScheduleResponseModel.fromList(List<dynamic> list) {
    // Bungkus List ke dalam struktur Map yang diharapkan
    return ScheduleResponseModel(
      status: true,
      desc: '',
      data: ScheduleDataModel.fromJson({'data': list}),
    );
  }

  @override
  List<Object?> get props => [status, desc, data];
}

class ScheduleDataModel extends Equatable {
  final int currentPage;
  final List<ScheduleModel> data;
  final String firstPageUrl;
  final dynamic from;
  final int lastPage;
  final String lastPageUrl;
  final List<LinkModel> links;
  final dynamic nextPageUrl;
  final String path;
  final int perPage;
  final dynamic prevPageUrl;
  final dynamic to;
  final int total;

  const ScheduleDataModel({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory ScheduleDataModel.empty() {
    return const ScheduleDataModel(
      currentPage: 1,
      data: [],
      firstPageUrl: '',
      from: null,
      lastPage: 1,
      lastPageUrl: '',
      links: [],
      nextPageUrl: null,
      path: '',
      perPage: 10,
      prevPageUrl: null,
      to: null,
      total: 0,
    );
  }

  factory ScheduleDataModel.fromJson(dynamic json) {
    if (json == null) {
      return ScheduleDataModel.empty();
    }
    if (json is List) {
      // Jika langsung List, bungkus ke dalam Map
      return ScheduleDataModel.fromJson({'data': json});
    }
    if (json is! Map<String, dynamic> || json.isEmpty) {
      return ScheduleDataModel.empty();
    }

    List<ScheduleModel> schedules = [];
    if (json['data'] != null && json['data'] is List) {
      try {
        schedules = List<ScheduleModel>.from(
          (json['data'] as List).map(
            (schedule) => ScheduleModel.fromJson(schedule),
          ),
        );
      } catch (e) {
        schedules = [];
      }
    } else {
      // Jika bukan List, kembalikan list kosong
      schedules = [];
    }

    List<LinkModel> linksList = [];
    if (json['links'] != null && json['links'] is List) {
      try {
        linksList = List<LinkModel>.from(
          (json['links'] as List).map(
            (link) => LinkModel.fromJson(link),
          ),
        );
      } catch (e) {
        linksList = [];
      }
    }

    return ScheduleDataModel(
      currentPage: json['current_page'] ?? 1,
      data: schedules,
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links: linksList,
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        currentPage,
        data,
        firstPageUrl,
        from,
        lastPage,
        lastPageUrl,
        links,
        nextPageUrl,
        path,
        perPage,
        prevPageUrl,
        to,
        total,
      ];
}

class LinkModel extends Equatable {
  final String? url;
  final String label;
  final bool active;

  const LinkModel({
    required this.url,
    required this.label,
    required this.active,
  });

  factory LinkModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return const LinkModel(
        url: null,
        label: '',
        active: false,
      );
    }

    return LinkModel(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }

  @override
  List<Object?> get props => [url, label, active];
}
