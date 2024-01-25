import 'package:awign/workforce/banner/data/network/api/banner_api.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:dio/dio.dart';

abstract class BannerRemoteDataSource {
  Future<Response> getBannerList(Map<String, dynamic> headers);
}

class BannerRemoteDataSourceImpl extends BannerAPI
    implements BannerRemoteDataSource {
  @override
  Future<Response> getBannerList(Map<String, dynamic> headers) async {
    try {
      Response response =
          await bffRestClient.get(getBannerListAPI, header: headers);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
