import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/payment/data/repository/payment_bff_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'nps_bottom_sheet_state.dart';

class NpsBottomSheetCubit extends Cubit<NpsBottomSheetState> {
  final PaymentBffRemoteRepository _paymentBffRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());

  Stream<UIStatus> get uiStatus => _uiStatus.stream;

  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _numberRating = BehaviorSubject<int>();

  Stream<int> get numberRatingStream => _numberRating.stream;

  Function(int) get changeNumberRating => _numberRating.sink.add;

  int get numberRatingValue => _numberRating.value;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());

  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  NpsBottomSheetCubit(this._paymentBffRemoteRepository)
      : super(NpsBottomSheetInitial());

  @override
  Future<void> close() {
    _numberRating.close();
    buttonStatus.close();
    return super.close();
  }

  void npsRating(String userId,int rating) async {
    try {
      ApiResponse apiResponse =
          await _paymentBffRemoteRepository.npsRating(userId,rating);
      if(apiResponse.status == "success")
        {
          changeUIStatus(UIStatus(event: Event.success,));
        }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('npsRating : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }
}
