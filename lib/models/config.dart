class Config {
  late String backendBaseUrl;
  late String cameraBaseUrl;
  late List<String> nodes;
  late String logoPath;

  Config({
    required this.backendBaseUrl,
    required this.cameraBaseUrl,
    required this.nodes,
    required this.logoPath
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      backendBaseUrl: json['backendBaseUrl'] as String,
      cameraBaseUrl: json['cameraBaseUrl'] as String,
      nodes: (json['nodes'] as List<dynamic>).cast<String>(),
      logoPath: json['logoPath'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backendBaseUrl': backendBaseUrl,
      'cameraBaseUrl': cameraBaseUrl,
      'nodes': nodes,
      'logoPath': logoPath
    };
  }
}
