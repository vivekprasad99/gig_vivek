import 'dart:convert';

import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'how_app_works_state.dart';

class HowAppWorksCubit extends Cubit<HowAppWorksState> {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _firebaseRemoteConfig = BehaviorSubject<List>();
  Stream<List> get firebaseRemoteConfig => _firebaseRemoteConfig.stream;
  Function(List) get addFirebaseRemoteConfig => _firebaseRemoteConfig.sink.add;

  HowAppWorksCubit() : super(HowAppWorksInitial());

  void setRemoteConfig() async {
    try {
      changeUIStatus(UIStatus(isOnScreenLoading: true));
      await remoteConfig.fetch();
      await remoteConfig.activate();
      _firebaseRemoteConfig.sink.add(jsonDecode(remoteConfig.getString('how_app_works')));
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: e.message!, isOnScreenLoading: false));
      if (!_firebaseRemoteConfig.isClosed) {
        _firebaseRemoteConfig.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: e.message!, isOnScreenLoading: false));
      if (!_firebaseRemoteConfig.isClosed) {
        _firebaseRemoteConfig.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('fetchResource : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr,
          isOnScreenLoading: false));
      if (!_firebaseRemoteConfig.isClosed) {
        _firebaseRemoteConfig.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }
}
