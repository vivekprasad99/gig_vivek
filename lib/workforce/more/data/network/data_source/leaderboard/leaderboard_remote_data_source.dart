import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/more/data/network/api/bff_api.dart';
import 'package:dio/dio.dart';

abstract class LeaderBoardRemoteDataSource {
  Future<Response> getTopEarnerList(String year, String month, String pillar);

  Future<Response> getUserEarning(int year, int month, String pillar, int? id);

  Future<Response> getUserCertificate(
      int year, int month, String pillar, int? id);
}

class LeaderBoardRemoteDataSourceImpl extends BffAPI
    implements LeaderBoardRemoteDataSource {
  @override
  Future<Response> getTopEarnerList(
      String year, String month, String pillar) async {
    try {
      Response response = await bffRestClient.get(getTopEarnerListAPI,
          queryParams: {"month": month, "year": year, "pillar": pillar});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> getUserEarning(
      int year, int month, String pillar, int? id) async {
    try {
      Response response = await bffRestClient.get(
          getUserEarningAPI,
          queryParams: {"month": month, "year": year, "pillar": pillar});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> getUserCertificate(
      int year, int month, String pillar, int? id) async {
    try {
      Response response = await bffRestClient.get(getUserCertificateAPI,
          queryParams: {"month": month, "year": year, "pillar": pillar});
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
