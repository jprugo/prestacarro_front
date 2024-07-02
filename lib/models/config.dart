class Config {
  late String title;
  late String backendBaseUrl;
  late String cameraBaseUrl;
  late List<String> nodes;
  late String logoPath;
  late String logo2;
  late String avatar;
  late bool selectionMenuEnabled;
  late bool isDebug;

  Config({
    required this.title,
    required this.backendBaseUrl,
    required this.cameraBaseUrl,
    required this.nodes,
    required this.logoPath,
    required this.logo2,
    required this.avatar,
    required this.selectionMenuEnabled,
    required this.isDebug
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      title: json['title'] as String,
      backendBaseUrl: json['backendBaseUrl'] as String,
      cameraBaseUrl: json['cameraBaseUrl'] as String,
      nodes: (json['nodes'] as List<dynamic>).cast<String>(),
      logoPath: json['logoPath'] as String,
      logo2: json['logo2'] as String,
      avatar: json['avatar'] as String,
      selectionMenuEnabled: json['selectionMenuEnabled'] as bool,
      isDebug: json['isDebug'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': backendBaseUrl,
      'backendBaseUrl': backendBaseUrl,
      'cameraBaseUrl': cameraBaseUrl,
      'nodes': nodes,
      'logoPath': logoPath,
      'logo2': logo2,
      'avatar': avatar,
      'selectionMenuEnabled': selectionMenuEnabled,
      'isDebug': isDebug
    };
  }
}
