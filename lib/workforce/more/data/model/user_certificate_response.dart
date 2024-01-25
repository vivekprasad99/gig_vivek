class UserCertificateResponse {
  Urls? urls;
  String? pillar;
  String? performance;
  int? month;
  int? year;

  UserCertificateResponse(
      {this.urls, this.pillar, this.performance, this.month, this.year});

  UserCertificateResponse.fromJson(Map<String, dynamic> json) {
    urls = json['urls'] != null ? Urls.fromJson(json['urls']) : null;
    pillar = json['pillar'];
    performance = json['performance'];
    month = json['month'];
    year = json['year'];
  }
}

class Urls {
  String? pdfUrl;
  String? imageUrl;

  Urls({this.pdfUrl, this.imageUrl});

  Urls.fromJson(Map<String, dynamic> json) {
    pdfUrl = json['pdf_url'];
    imageUrl = json['image_url'];
  }
}

