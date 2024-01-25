import 'package:awign/workforce/more/data/model/earning_response.dart';
import 'package:awign/workforce/more/data/model/user_certificate_response.dart';
import 'package:awign/workforce/more/data/model/user_earning_response.dart';
import 'package:awign/workforce/more/data/network/data_source/leaderboard/leaderboard_remote_data_source.dart';

import '../../../../core/utils/app_log.dart';

abstract class LeaderBoardRemoteRepository {
  Future<EarningResponse> getTopEarnerList(String year,String month,String item);

  Future<UserEarningResponse> getUserEarning(int year,int month,int? id,String item);

  Future<UserCertificateResponse> getUserCertificate(int year,int month,int? id,String item);
}

class LeaderBoardRemoteRepositoryImpl implements LeaderBoardRemoteRepository {
  final LeaderBoardRemoteDataSource _dataSource;
  LeaderBoardRemoteRepositoryImpl(this._dataSource);

  @override
  Future<EarningResponse> getTopEarnerList(String year,String month,String item) async {
    try {
      final apiResponse = await _dataSource.getTopEarnerList(year,month,item);
      return EarningResponse.fromJson(apiResponse.data);
    } catch (e, stacktrace) {
      AppLog.e('getTopEarnerList : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<UserEarningResponse> getUserEarning(int year,int month,int? id,String item) async {
    try {
      final apiResponse = await _dataSource.getUserEarning(year,month,item,id);
      return UserEarningResponse.fromJson(apiResponse.data);
    } catch (e, stacktrace) {
      AppLog.e('getUserEarning : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }

  @override
  Future<UserCertificateResponse> getUserCertificate(int year,int month,int? id,String item) async {
    try {
      final apiResponse = await _dataSource.getUserCertificate(year,month,item,id);
      return UserCertificateResponse.fromJson(apiResponse.data);
    } catch (e, stacktrace) {
      AppLog.e('getUserCertificate : ${e.toString()} \n${stacktrace.toString()}');
      rethrow;
    }
  }
}