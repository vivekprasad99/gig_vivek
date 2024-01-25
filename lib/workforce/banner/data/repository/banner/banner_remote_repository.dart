import 'package:awign/workforce/banner/data/network/data_source/banner/banner_remote_data_source.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import '../../model/banner_entity.dart';

abstract class BannerRemoteRepository {
  Future<BannerResponse> getBannerList(Map<String, dynamic> headers);
}

class BannerRemoteRepositoryImpl implements BannerRemoteRepository {
  final BannerRemoteDataSource _dataSource;
  BannerRemoteRepositoryImpl(this._dataSource);

  @override
  Future<BannerResponse> getBannerList(Map<String, dynamic> headers) async {
    try {
      final apiResponse = await _dataSource.getBannerList(headers);
      return BannerResponse.fromJson(apiResponse.data);
    } catch (e, stacktrace) {
      AppLog.e('getBannerList : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }
}
