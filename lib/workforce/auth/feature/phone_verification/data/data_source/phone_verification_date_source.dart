import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/remote_data_source.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:dio/dio.dart';

abstract class PhoneVerificationRemoteDataSource {

}

class PhoneVerificationRemoteDataSourceImpl extends RemoteDataSource
implements PhoneVerificationRemoteDataSource {
  get apiName => null;

}