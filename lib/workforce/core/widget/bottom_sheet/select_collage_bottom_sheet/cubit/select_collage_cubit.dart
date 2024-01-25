import 'package:awign/workforce/auth/data/repository/auth_remote_repository.dart';
import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/model/education_detail_response.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:bloc/bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'select_collage_state.dart';

class SelectCollageCubit extends Cubit<SelectCollageState> {
  final AuthRemoteRepository _authRemoteRepository;

  final _uiStatus = BehaviorSubject<UIStatus>.seeded(UIStatus());
  Stream<UIStatus> get uiStatus => _uiStatus.stream;
  Function(UIStatus) get changeUIStatus => _uiStatus.sink.add;

  final _collageList = BehaviorSubject<List<Education>>();
  Stream<List<Education>> get collageListStream =>
      _collageList.stream;
  List<Education> get collageList => _collageList.value;
  Function(List<Education>) get changeCollageList =>
      _collageList.sink.add;

  SelectCollageCubit(this._authRemoteRepository) : super(SelectCollageInitial()) {
    loadCollageList();
  }

  @override
  Future<void> close() {
    _collageList.close();
    return super.close();
  }

  void loadCollageList() {
    // var domainArray = [
    //   'calling'.tr,
    //   'data_entry'.tr,
    //   'field_job'.tr,
    //   'delivery_job'.tr,
    //   'sales'.tr,
    //   'marketing'.tr,
    //   'business_development'.tr,
    //   'others'.tr,
    // ];
    // var list = <WorkingDomain>[];
    // for (var name in domainArray) {
    //   var item = WorkingDomain(name: name);
    //   list.add(item);
    // }
    // if (!_collageList.isClosed) {
    //   _collageList.sink.add(list);
    // }
    // searchCollage(0, null);
  }

  Future<List<Education>?> searchCollage(int pageIndex, String? searchTerm) async {
    try {
      // changeUIStatus(UIStatus(isOnScreenLoading: true));
      Tuple2<EducationDetailResponse, String?> tuple2 = await _authRemoteRepository.searchCollage(searchTerm, pageIndex);
      // if (!_userProfileResponse.isClosed) {
      //   _userProfileResponse.sink.add(userProfileResponse);
      // }
      // changeUIStatus(UIStatus(isOnScreenLoading: false));
      // AppLog.i('searchCollageResponse : ${tuple2.item1.data.toString()}');
      if(tuple2.item1.education != null && tuple2.item1.education!.isNotEmpty) {
        return tuple2.item1.education!;
      }
    } on ServerException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } on FailureException catch (e) {
      changeUIStatus(UIStatus(
          isOnScreenLoading: false, failedWithoutAlertMessage: e.message!));
    } catch (e, st) {
      AppLog.e('searchCollage : ${e.toString()} \n${st.toString()}');
      changeUIStatus(UIStatus(
          isOnScreenLoading: false,
          failedWithoutAlertMessage: 'we_regret_the_technical_error'.tr));
    }
  }

//   Future<List<User>> pageFetch(int offset) async {
//     print(offset);
//     page = (offset / 5).round();
//     final Faker faker = Faker();
//     final List<User> nextUsersList = List.generate(
//       5,
//           (int index) => User(
//         faker.person.name() + ' - $page$index',
//         faker.internet.email(),
//       ),
//     );
//     await Future<List<User>>.delayed(Duration(seconds: 1));
//     return page == 0 ? [] : nextUsersList;
//   }
// }
}
