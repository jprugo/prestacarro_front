class Config {
  late String backendBaseUrl;
  late String cameraBaseUrl;
  late List<String> nodes;
  late String logoPath;
  late String logo2;
  late bool selectionMenuEnabled;

  Config({
    required this.backendBaseUrl,
    required this.cameraBaseUrl,
    required this.nodes,
    required this.logoPath,
    required this.logo2,
    required this.selectionMenuEnabled
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      backendBaseUrl: json['backendBaseUrl'] as String,
      cameraBaseUrl: json['cameraBaseUrl'] as String,
      nodes: (json['nodes'] as List<dynamic>).cast<String>(),
      logoPath: json['logoPath'] as String,
      logo2: json['logo2'] as String,
      selectionMenuEnabled: json['selectionMenuEnabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backendBaseUrl': backendBaseUrl,
      'cameraBaseUrl': cameraBaseUrl,
      'nodes': nodes,
      'logoPath': logoPath,
      'logo2': logo2,
      'selectionMenuEnabled': selectionMenuEnabled
    };
  }
}
