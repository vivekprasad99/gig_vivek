import 'dart:collection';

import 'package:awign/workforce/banner/data/model/banner_entity.dart';
import 'package:awign/workforce/banner/data/repository/banner/banner_remote_repository.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'banner_state.dart';

class BannerCubit extends Cubit<BannerState> {
  final BannerRemoteRepository _bannerRemoteRepository;
  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _bannerResponse = BehaviorSubject<List<BannerData>>();
  Stream<List<BannerData>> get bannerResponseStream => _bannerResponse.stream;
  List<BannerData> get bannerResponse => _bannerResponse.value;
  Function(List<BannerData>) get changeBannerResponse => _bannerResponse.sink.add;

  static const accessToken = 'access-token';
  static const client = 'client';
  static const uID = 'uid';

  BannerCubit(this._bannerRemoteRepository) : super(BannerInitial());

  Future<List<BannerData>?> getBannerList() async {
    try {
      Map<String, dynamic> headers = HashMap();
      SPUtil? spUtil = await SPUtil.getInstance();
      UserData? _currentUser = spUtil?.getUserData();
      String? accessTokenValue = spUtil?.getAccessToken();
      if (_currentUser != null) {
        headers.putIfAbsent(accessToken, () => accessTokenValue);
        String? clientValue = spUtil?.getClient();
        headers.putIfAbsent(client, () => clientValue);
        String? uIDValue = spUtil?.getUID();
        headers.putIfAbsent(uID, () => uIDValue);
      }
      BannerResponse data =
      await _bannerRemoteRepository.getBannerList(headers);
      _bannerResponse.sink.add(data.bannerData!);
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e) {
      AppLog.e('getBannerList : ${e.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
