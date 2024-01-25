import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/exception/exception.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/execution_in_house/data/model/available_entity.dart';
import 'package:awign/workforce/execution_in_house/data/network/data_source/availablity/availablity_remote_data_source.dart';

abstract class AvailabilityRemoteRepository {
  Future<MemberTimeSlotResponse> getUpcomingSlots(String memberId, String date);

  Future<MemberTimeSlotResponse> updateAvailabilitySlots(String memberId,
      String slotId, MemberTimeSlotResponse memberTimeSlotResponse);

  Future<MemberTimeSlotResponse> createAvailabilitySlots(
      String memberId, MemberTimeSlotResponse memberTimeSlotResponse);
}

class AvailabilityRemoteRepositoryImpl implements AvailabilityRemoteRepository {
  final AvailabilityRemoteDataSource _dataSource;

  AvailabilityRemoteRepositoryImpl(this._dataSource);

  @override
  Future<MemberTimeSlotResponse> getUpcomingSlots(
      String memberId, String date) async {
    try {
      ApiResponse apiResponse =
          await _dataSource.getUpcomingSlots(memberId, date);
      if (apiResponse.status == ApiResponse.success) {
        return MemberTimeSlotResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('getUpcomingSlots : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<MemberTimeSlotResponse> updateAvailabilitySlots(String memberId,
      String slotId, MemberTimeSlotResponse memberTimeSlotResponse) async {
    try {
      ApiResponse apiResponse = await _dataSource.updateAvailabilitySlots(
          memberId, slotId, memberTimeSlotResponse);
      if (apiResponse.status == ApiResponse.success) {
        return MemberTimeSlotResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('updateAvailabilitySlots : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<MemberTimeSlotResponse> createAvailabilitySlots(
      String memberId, MemberTimeSlotResponse memberTimeSlotResponse) async {
    try {
      ApiResponse apiResponse = await _dataSource.createAvailabilitySlots(
          memberId, memberTimeSlotResponse);
      if (apiResponse.status == ApiResponse.success) {
        return MemberTimeSlotResponse.fromJson(apiResponse.data);
      } else {
        throw FailureException(0, apiResponse.message);
      }
    } catch (e, st) {
      AppLog.e('createAvailabilitySlots : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}
