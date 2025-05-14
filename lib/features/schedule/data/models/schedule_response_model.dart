import 'package:equatable/equatable.dart';
import 'schedule_model.dart';

class ScheduleResponseModel extends Equatable {
  final bool status;
  final String desc;
  final ScheduleDataModel data;

  const ScheduleResponseModel({
    required this.status,
    required this.desc,
    required this.data,
  });

  factory ScheduleResponseModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return ScheduleResponseModel(
        status: false,
        desc: 'Data kosong',
        data: ScheduleDataModel.empty(),
      );
    }

    return ScheduleResponseModel(
      status: json['status'] ?? false,
      desc: json['desc'] ?? '',
      data: ScheduleDataModel.fromJson(json['data'] ?? {}),
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

  factory ScheduleDataModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return ScheduleDataModel.empty();
    }

    List<ScheduleModel> schedules = [];
    if (json['data'] != null) {
      try {
        schedules = List<ScheduleModel>.from(
          (json['data'] as List).map(
            (schedule) => ScheduleModel.fromJson(schedule),
          ),
        );
      } catch (e) {
        schedules = [];
      }
    }

    List<LinkModel> linksList = [];
    if (json['links'] != null) {
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
