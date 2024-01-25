import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/select_location_bottom_sheet/model/location_item.dart';
import 'package:awign/workforce/onboarding/data/repository/wos_remote_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'select_location_state.dart';

class SelectLocationCubit extends Cubit<SelectLocationState> {
  final WosRemoteRepository _wosRemoteRepository;

  final _locationType = BehaviorSubject<LocationType>();
  Stream<LocationType> get locationType => _locationType.stream;
  Function(LocationType) get changeLocationType => _locationType.sink.add;

  SelectLocationCubit(this._wosRemoteRepository) : super(SelectLocationInitial());

  Future<List<LocationItem>?> searchLocations(int pageIndex, String? searchTerm) async {
    try {
      LocationResponse locationResponse = await _wosRemoteRepository.searchLocations(searchTerm ?? '', _locationType.value, pageIndex);
      if(locationResponse.locations != null) {
        List<LocationItem> locationList = [];
        locationResponse.locations?.forEach((address) {
          String location = '';
          switch(_locationType.value) {
            case LocationType.allIndia:
            case LocationType.city:
            location = address.city ?? '';
              break;
            case LocationType.pincode:
              location = address.pincode ?? '';
              break;
            case LocationType.state:
              location = address.state ?? '';
              break;
          }
          LocationItem locationItem = LocationItem(name: location);
          locationList.add(locationItem);
        });
        return locationList;
      } else {
        return [];
      }
    } on ServerException catch (e) {
      AppLog.e('searchLocations : ${e.toString()}');
    } on FailureException catch (e) {
      AppLog.e('searchLocations : ${e.toString()}');
    } catch (e, st) {
      AppLog.e('searchLocations : ${e.toString()} \n${st.toString()}');
    }
    return null;
  }
}
