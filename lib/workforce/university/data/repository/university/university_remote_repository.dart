import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/model/advance_search/operator.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/university/data/model/university_entity.dart';
import 'package:awign/workforce/university/data/model/university_request.dart';
import 'package:awign/workforce/university/data/network/data_source/university/university_remote_data_source.dart';

import '../../../../core/utils/constants.dart';

abstract class UniversityRemoteRepository {
  Future<UniversityData?> getCourseList(
      UniversityRequest universityRequest, int pageIndex);

  Future<CourseResponse?> getCourse(int courseId);

  Future<CourseResponse?> updateViews(int courseId);
}

class UniversityRemoteRepositoryImpl
    implements UniversityRemoteRepository
{
  final UniversityRemoteDataSource _dataSource;
  UniversityRemoteRepositoryImpl(this._dataSource);

  Future<UniversityData?> getCourseList(UniversityRequest universityRequest, int pageIndex) async {
    try {
    var builder = AdvanceSearchRequestBuilder();
    builder.setSortOrder(Constants.desc).setPage(pageIndex).setLimit(10);
    builder.putPropertyToCondition(Constants.status, Operator.equal, Constants.published);
    if (universityRequest.courseCategoryFilter != null)
      {
        builder.putPropertyToCondition("category", Operator.equal,universityRequest.courseCategoryFilter.toString());
      }

      if (universityRequest.courseSkillFilter != null)
      {
      builder.putPropertyToCondition("skills", Operator.contains,universityRequest.courseSkillFilter.toString());
      }
    UniversityResponse? universityData =  await _dataSource.getCourseList(builder.build());
      return universityData?.universityData;
    } catch (e, st) {
      AppLog.e('getCourseList : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<CourseResponse?> getCourse(int courseId) async {
    try {
      CourseResponse? courseResponse =  await _dataSource.getCourse(courseId);
      return courseResponse;
    } catch (e, st) {
      AppLog.e('getCourse : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }

  @override
  Future<CourseResponse?> updateViews(int courseId) async {
    try {
      CourseResponse? courseResponse =  await _dataSource.updateViews(courseId);
      return courseResponse;
    } catch (e, st) {
      AppLog.e('updateViews : ${e.toString()} \n${st.toString()}');
      rethrow;
    }
  }
}