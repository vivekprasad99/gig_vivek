class NudgeResponse {
  List<UserNudges>? userNudges;
  int? limit;
  int? page;
  int? offset;
  int? total;

  NudgeResponse({this.userNudges, this.limit, this.page, this.offset, this.total});

  NudgeResponse.fromJson(Map<String, dynamic> json) {
    if (json['user_nudges'] != null) {
      userNudges = <UserNudges>[];
      json['user_nudges'].forEach((v) {
        userNudges!.add(UserNudges.fromJson(v));
      });
    }
    limit = json['limit'];
    page = json['page'];
    offset = json['offset'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (userNudges != null) {
      data['user_nudges'] = userNudges!.map((v) => v.toJson()).toList();
    }
    data['limit'] = limit;
    data['page'] = page;
    data['offset'] = offset;
    data['total'] = total;
    return data;
  }
}

class UserNudges {
  int? id;
  int? userId;
  String? nudgeType;
  int? displayCount;
  String? lastDisplayed;
  String? timeToDisplay;
  NudgeData? nudgeData;
  String? createdAt;
  String? updatedAt;

  UserNudges(
      {this.id,
        this.userId,
        this.nudgeType,
        this.displayCount,
        this.lastDisplayed,
        this.timeToDisplay,
        this.nudgeData,
        this.createdAt,
        this.updatedAt});

  UserNudges.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    nudgeType = json['nudge_type'];
    displayCount = json['display_count'];
    lastDisplayed = json['last_displayed'];
    timeToDisplay = json['time_to_display'];
    nudgeData = json['nudge_data'] != null
        ? NudgeData.fromJson(json['nudge_data'])
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['user_id'] = userId;
    data['nudge_type'] = nudgeType;
    data['display_count'] = displayCount;
    data['last_displayed'] = lastDisplayed;
    data['time_to_display'] = timeToDisplay;
    if (nudgeData != null) {
      data['nudge_data'] = nudgeData!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class NudgeData {
  String? profileCompletionPercentage;
  String? displayMessage;
  String? cta;

  NudgeData({this.profileCompletionPercentage, this.displayMessage, this.cta});

  NudgeData.fromJson(Map<String, dynamic> json) {
    profileCompletionPercentage = json['profile_completion_percentage'];
    displayMessage = json['display_message'];
    cta = json['cta'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['profile_completion_percentage'] = profileCompletionPercentage;
    data['display_message'] = displayMessage;
    data['cta'] = cta;
    return data;
  }
}

class NudgeEventRequest {
  NudgeEventRequest({
    required this.event,
    required this.eventAt,
    required this.otherProperties,
    required this.userId,
  });

  late String? event;
  late String? eventAt;
  late Map<String, String>? otherProperties;
  late int? userId;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['event'] = event;
    _data['event_at'] = eventAt;
    _data['other_properties'] = otherProperties;
    _data['user_id'] = userId;
    return _data;
  }
}