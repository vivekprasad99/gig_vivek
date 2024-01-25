import 'package:awign/workforce/aw_questions/cubit/aw_questions_cubit.dart';
import 'package:awign/workforce/aw_questions/data/model/answer/answer_unit.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/model/button_status.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/execution_in_house/feature/attendance/data/screen_question_arguments.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'attendance_upload_image_state.dart';

class AttendanceUploadImageCubit extends Cubit<AttendanceUploadImageState> {
  final _awQuestionsCubit = sl<AwQuestionsCubit>();

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _screenRowList = BehaviorSubject<List<ScreenRow>>();
  Stream<List<ScreenRow>> get screenRowList => _screenRowList.stream;
  Function(List<ScreenRow>) get changeExecution => _screenRowList.sink.add;
  List<ScreenRow> get screenRowListValue => _screenRowList.value;

  final buttonStatus = BehaviorSubject<ButtonStatus>.seeded(ButtonStatus());
  Function(ButtonStatus) get changeButtonStatus => buttonStatus.sink.add;

  AttendanceUploadImageCubit() : super(AttendanceUploadImageInitial());

  void getScreenRowList(ScreenQuestionArguments screenQuestionArguments) async {
    try {
      List<ScreenRow> screenrows = [];
      int count = 1;
      for (var i = 0; i < screenQuestionArguments.questionList.length; i++) {
        screenQuestionArguments.questionList[i].screenRowIndex = count - 1;
        screenQuestionArguments.questionList[i].configuration?.questionIndex =
            count;
        screenQuestionArguments.questionList[i].configuration?.isRequired = true;
        screenrows.add(
            ScreenRow(question: screenQuestionArguments.questionList[i],
                rowType: ScreenRowType.question));
        count++;
      }
      _awQuestionsCubit.changeScreenRowList(screenrows);
      if (!_screenRowList.isClosed) {
        _screenRowList.sink.add(screenrows);
      } else {
        _screenRowList.sink.addError('');
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_screenRowList.isClosed) {
        _screenRowList.sink.addError(e.message!);
      }
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(failedWithoutAlertMessage: e.message!));
      if (!_screenRowList.isClosed) {
        _screenRowList.sink.addError(e.message!);
      }
    } catch (e, st) {
      AppLog.e('getScreenRowList : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
      if (!_screenRowList.isClosed) {
        _screenRowList.sink.addError('we_regret_the_technical_error'.tr);
      }
    }
  }


}
