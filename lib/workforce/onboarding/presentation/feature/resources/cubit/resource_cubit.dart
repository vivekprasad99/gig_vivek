import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/execution_in_house/data/model/resource.dart';
import 'package:awign/workforce/onboarding/data/repository/work_application/work_application_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'resource_state.dart';

class ResourceCubit extends Cubit<ResourceState> {
  final WorkApplicationRemoteRepository _workApplicationRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _resourceModel = BehaviorSubject<ResourceResponse>();

  Stream<ResourceResponse> get resourceModelStream => _resourceModel.stream;

  Function(ResourceResponse) get changeresourceModelStream =>
      _resourceModel.sink.add;

  ResourceCubit(this._workApplicationRemoteRepository) : super(ResourceInitial());

  @override
  Future<void> close() {
    _uiStatus.close();
    _resourceModel.close();
    return super.close();
  }

  void fetchResources(int userID, int applicationID) async {
    try {
      changeUIStatus(UIStatus(isOnScreenLoading: true));
      ResourceResponse resourceModel = await _workApplicationRemoteRepository
          .fetchResource(userID, applicationID);
      _resourceModel.sink.add(resourceModel);
      changeUIStatus(UIStatus(isOnScreenLoading: false));
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: e.message!, isOnScreenLoading: false));
      if (!_resourceModel.isClosed) {
        _resourceModel.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: e.message!, isOnScreenLoading: false));
      if (!_resourceModel.isClosed) {
        _resourceModel.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('fetchResource : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr,
          isOnScreenLoading: false));
      if (!_resourceModel.isClosed) {
        _resourceModel.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }

}
