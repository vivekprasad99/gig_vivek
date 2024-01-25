class UniversityResponse
{
  String? status;
  UniversityData? universityData;
  int? total;

  UniversityResponse(
      {this.status, this.universityData, this.total});

  UniversityResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    universityData = json['data'] != null
        ? UniversityData.fromJson(json['data'])
        : null;
    total = json['total'];
  }
}

class UniversityData
{
  List<CoursesEntity>? courseList;

  UniversityData({this.courseList});

  UniversityData.fromJson(Map<String, dynamic> json) {
    if (json['course'] != null) {
      courseList = <CoursesEntity>[];
      json['course'].forEach((v) {
        courseList!.add(CoursesEntity.fromJson(v));
      });
    }
  }
}

class CoursesEntity {
  int? id;
  String? name;
  String? thumbnail;
  String? category;
  int? views;
  List<String>? skills;
  String? byWhom;
  VideoLink? videoLink;
  String? description;
  String? thingsToLearn;
  String? curriculum;
  String? status;
  String? updatedAt;

  CoursesEntity(
      {this.id,
        this.name,
        this.thumbnail,
        this.status,
        this.views,
        this.skills,
        this.byWhom,
        this.updatedAt,
        this.videoLink,
        this.description,
        this.thingsToLearn,
        this.curriculum,this.category});

  CoursesEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    thumbnail = json['thumbnail'];
    status = json['status'];
    category = json['category'];
    views = json['views'];
    if (json['skills'] != null) {
      skills = <String>[];
      json['skills'].forEach((v) {
        skills!.add(v);
      });
    }
    updatedAt = json['updated_at'];
    byWhom = json['by_whom'];
    videoLink = json['link'] != null
        ? VideoLink.fromJson(json['link'])
        : null;
    description = json['description'];
    thingsToLearn = json['things_to_learn'];
    curriculum = json['curriculum'];
  }
}

class VideoLink {
  String? type;
  String? url;

  VideoLink({this.type, this.url});

  VideoLink.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    url = json['url'];
  }
}

class CourseResponse
{
  String? status;
  CourseData? courseData;
  int? total;

  CourseResponse(
      {this.status, this.courseData, this.total});

  CourseResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    courseData = json['data'] != null
        ? CourseData.fromJson(json['data'])
        : null;
    total = json['total'];
  }
}

class CourseData
{
  CoursesEntity? coursesEntity;

  CourseData({this.coursesEntity});

  CourseData.fromJson(Map<String, dynamic> json) {
    coursesEntity = json['course'] != null
        ? CoursesEntity.fromJson(json['course'])
        : null;
  }
}