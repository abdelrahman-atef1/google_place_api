class Northeast {
  final double? lat;
  final double? lng;

  Northeast({this.lat, this.lng});

  factory Northeast.fromJson(Map<String, dynamic> json) {
    return Northeast(
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
    );
  }
}
