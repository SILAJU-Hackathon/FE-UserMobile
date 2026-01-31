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
