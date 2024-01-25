import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing/work_listing.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing_fetch_locations/address_entity.dart';
import 'package:awign/workforce/onboarding/data/network/api/wos_api.dart';
import 'package:dio/dio.dart';

import '../../../../../core/data/model/advance_search/advance_search_request.dart';

abstract class WorkListingRemoteDataSource {
  Future<WorkListing> fetchWorkListing(String applicationID);
  Future<AddressEntity> fetchLocationsList(String workListingID, AdvancedSearchRequest builder);

}

class WorkListingRemoteDataSourceImpl extends WosAPI
    implements WorkListingRemoteDataSource {
  @override
  Future<WorkListing> fetchWorkListing(String workListingID) async {
    try {
      Response response = await wosRestClient.get(fetchWorkListingAPI
          .replaceAll('workListingID', workListingID));
      return WorkListing.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AddressEntity> fetchLocationsList(String workListingID, AdvancedSearchRequest builder) async{
    try {
      Response response = await wosRestClient.post(fetchLocationsListAPI
          (workListingID), body: builder.toJson());

      return AddressEntity.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }




}


