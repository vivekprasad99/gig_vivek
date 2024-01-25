import 'package:awign/workforce/core/data/model/api_response.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/execution_in_house/data/model/available_entity.dart';
import 'package:awign/workforce/execution_in_house/data/network/api/in_house_oms_api.dart';
import 'package:dio/dio.dart';

abstract class AvailabilityRemoteDataSource {
  Future<ApiResponse> getUpcomingSlots(String memberId, String date);

  Future<ApiResponse> updateAvailabilitySlots(String memberId, String slotId,
      MemberTimeSlotResponse memberTimeSlotResponse);

  Future<ApiResponse> createAvailabilitySlots(
      String memberId, MemberTimeSlotResponse memberTimeSlotResponse);
}

class AvailabilityRemoteDataSourceImpl extends InHouseOMSAPI
    implements AvailabilityRemoteDataSource {
  @override
  Future<ApiResponse> getUpcomingSlots(String memberId, String date) async {
    try {
      Response response = await inHouseOMSRestClient.post(
          getUpcomingSlotsAPI.replaceAll('member_id', memberId),
          body: {"date": date});
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateAvailabilitySlots(String memberId, String slotId,
      MemberTimeSlotResponse memberTimeSlotResponse) async {
    try {
      Response response = await inHouseOMSRestClient.patch(
          updateAvailabilitySlotsAPI
              .replaceAll('member_id', memberId)
              .replaceAll('slot_id', slotId),
          body: memberTimeSlotResponse);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> createAvailabilitySlots(
      String memberId, MemberTimeSlotResponse memberTimeSlotResponse) async {
    try {
      Response response = await inHouseOMSRestClient.patch(
          createAvailabilitySlotsAPI.replaceAll('member_id', memberId),
          body: memberTimeSlotResponse);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
