// To parse this JSON data, do
//
//     final modelplus = modelplusFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Modelplus modelplusFromJson(String str) => Modelplus.fromJson(json.decode(str));

String modelplusToJson(Modelplus data) => json.encode(data.toJson());

class Modelplus {
  Downloads downloads;

  Modelplus({
    required this.downloads,
  });

  factory Modelplus.fromJson(Map<String, dynamic> json) => Modelplus(
    downloads: Downloads.fromJson(json["downloads"]),
  );

  Map<String, dynamic> toJson() => {
    "downloads": downloads.toJson(),
  };
}

class Downloads {
  int status;
  String customerSupport;
  EDownload fileDownload;
  EDownload licenceDownload;
  MoreApi moreApi;

  Downloads({
    required this.status,
    required this.customerSupport,
    required this.fileDownload,
    required this.licenceDownload,
    required this.moreApi,
  });

  factory Downloads.fromJson(Map<String, dynamic> json) => Downloads(
    status: json["status"],
    customerSupport: json["customer_support"],
    fileDownload: EDownload.fromJson(json["file_download"]),
    licenceDownload: EDownload.fromJson(json["licence_download"]),
    moreApi: MoreApi.fromJson(json["more_api"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "customer_support": customerSupport,
    "file_download": fileDownload.toJson(),
    "licence_download": licenceDownload.toJson(),
    "more_api": moreApi.toJson(),
  };
}

class EDownload {
  String link;
  String expire;

  EDownload({
    required this.link,
    required this.expire,
  });

  factory EDownload.fromJson(Map<String, dynamic> json) => EDownload(
    link: json["link"],
    expire: json["expire"],
  );

  Map<String, dynamic> toJson() => {
    "link": link,
    "expire": expire,
  };
}

class MoreApi {
  FreerApi freepikDownloaderApi;
  FreerApi freeGoogleTranslatorApi;

  MoreApi({
    required this.freepikDownloaderApi,
    required this.freeGoogleTranslatorApi,
  });

  factory MoreApi.fromJson(Map<String, dynamic> json) => MoreApi(
    freepikDownloaderApi: FreerApi.fromJson(json["freepik_downloader_api"]),
    freeGoogleTranslatorApi: FreerApi.fromJson(json["free_google_translator_api"]),
  );

  Map<String, dynamic> toJson() => {
    "freepik_downloader_api": freepikDownloaderApi.toJson(),
    "free_google_translator_api": freeGoogleTranslatorApi.toJson(),
  };
}

class FreerApi {
  String link;

  FreerApi({
    required this.link,
  });

  factory FreerApi.fromJson(Map<String, dynamic> json) => FreerApi(
    link: json["link"],
  );

  Map<String, dynamic> toJson() => {
    "link": link,
  };
}
