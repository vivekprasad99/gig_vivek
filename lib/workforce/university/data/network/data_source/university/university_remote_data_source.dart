import 'package:awign/workforce/core/data/model/advance_search/advance_search_request.dart';
import 'package:awign/workforce/core/data/remote/rest_client.dart';
import 'package:awign/workforce/university/data/model/university_entity.dart';
import 'package:awign/workforce/university/data/network/api/learning_api.dart';
import 'package:dio/dio.dart';

abstract class UniversityRemoteDataSource {
  Future<UniversityResponse?> getCourseList(AdvancedSearchRequest builder);

  Future<CourseResponse?> getCourse(int courseId);

  Future<CourseResponse?> updateViews(int courseId);
}

class UniversityRemoteDataSourceImpl extends LearningAPI
    implements UniversityRemoteDataSource {
  @override
  Future<UniversityResponse?> getCourseList(
      AdvancedSearchRequest builder) async {
    try {
      Response response = await learningRestClient.post(getCourseListAPI,
          body: builder.toJson());
      return UniversityResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CourseResponse?> getCourse(int courseId) async {
    try {
      Response response = await learningRestClient.get(getCourseAPI.replaceAll('id', courseId.toString()));
      return CourseResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CourseResponse?> updateViews(int courseId) async {
    try {
      Map<String, int> hashMap = {};
      hashMap["count"] = 1;
      Response response = await learningRestClient.patch(updateViewsAPI.replaceAll('id', courseId.toString()),
          body: hashMap);
      return CourseResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

}
