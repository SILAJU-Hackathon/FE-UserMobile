import 'dart:convert';

class ReportRequest {
  final double latitude;
  final double longitude;
  final String description;
  final String roadName;

  ReportRequest({
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.roadName,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'road_name': roadName,
    };
  }

  String toJson() => json.encode(toMap());
}

class Report {
  final String id;
  final String roadName;
  final String description;
  final String status;
  final String createdAt;
  final String? beforeImageUrl;
  final String? afterImageUrl;
  final String? adminNotes;
  final double latitude;
  final double longitude;

  Report({
    required this.id,
    required this.roadName,
    required this.description,
    required this.status,
    required this.createdAt,
    this.beforeImageUrl,
    this.afterImageUrl,
    this.adminNotes,
    required this.latitude,
    required this.longitude,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String? ?? '',
      roadName: json['road_name'] as String? ?? 'Lokasi tidak diketahui',
      description: json['description'] as String? ?? '-',
      status: json['status'] as String? ?? 'Pending',
      createdAt: json['created_at'] as String? ?? '',
      beforeImageUrl: json['before_image_url'] as String?,
      afterImageUrl: json['after_image_url'] as String?,
      adminNotes: json['admin_notes'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReportResponse {
  final List<Report> reports;
  final int totalCount;

  ReportResponse({
    required this.reports,
    required this.totalCount,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      reports: (json['reports'] as List<dynamic>?)
              ?.map((e) => Report.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}
