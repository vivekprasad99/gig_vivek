import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing/work_listing.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing_fetch_locations/address_entity.dart';
import 'package:awign/workforce/onboarding/data/network/data_source/work_listing/work_listing_remote_data_source.dart';

import '../../../../core/data/model/advance_search/advance_search_request.dart';


abstract class WorkListingRemoteRepository {
  Future<AddressEntity> fetchLocationsList(String workListingID, AdvancedSearchRequest builder);
  Future<WorkListing> fetchWorkListing(String workListingID);

}

class WorkListingRemoteRepositoryImpl implements WorkListingRemoteRepository {
  final WorkListingRemoteDataSource _dataSource;

  WorkListingRemoteRepositoryImpl(this._dataSource);

  @override
  Future<WorkListing> fetchWorkListing(String workListingID) async {
    try {
      final workListing = await _dataSource.fetchWorkListing(workListingID);
      return workListing;
    } catch (e, st) {
      rethrow;
    }
  }

  @override
  Future<AddressEntity> fetchLocationsList(String workListingID, AdvancedSearchRequest builder) async{
      try {
        final workListing = await _dataSource.fetchLocationsList(workListingID,builder);
        return workListing;
      } catch (e, st) {
        rethrow;
      }
  }


}
