class Config {
  String? backendBaseUrl;
  String? cameraBaseUrl;
  String? nodeUrl1;
  String? nodeUrl2;
  String? nodeUrl3;
  String? separator;

  Config(
      {this.backendBaseUrl,
      this.cameraBaseUrl,
      this.nodeUrl1,
      this.nodeUrl2,
      this.nodeUrl3,
      this.separator});

  Config.fromJson(Map<String, dynamic> json) {
    backendBaseUrl = json['backendBaseUrl'];
    cameraBaseUrl = json['cameraBaseUrl'];
    nodeUrl1 = json['nodeUrl1'];
    nodeUrl2 = json['nodeUrl2'];
    nodeUrl3 = json['nodeUrl3'];
    separator = json['separator'] ?? '>';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['backendBaseUrl'] = this.backendBaseUrl;
    data['cameraBaseUrl'] = this.cameraBaseUrl;
    data['nodeUrl1'] = this.nodeUrl1;
    data['nodeUrl2'] = this.nodeUrl2;
    data['nodeUrl3'] = this.nodeUrl3;
    data['separator'] = this.separator;
    return data;
  }
}
