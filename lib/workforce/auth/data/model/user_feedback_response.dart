enum Status { submitted, discarded }

enum FeedbackEvents { feedback_submitted , feedback_discarded }

class UserFeedbackRequest {
  SupplyFeedback? supplyFeedback;

  UserFeedbackRequest({this.supplyFeedback});

  UserFeedbackRequest.fromJson(Map<String, dynamic> json) {
    supplyFeedback = json['supply_feedback'] != null
        ? SupplyFeedback.fromJson(json['supply_feedback'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (supplyFeedback != null) {
      data['supply_feedback'] = supplyFeedback!.toJson();
    }
    return data;
  }
}

class SupplyFeedback {
  String? message;
  int? overallRating;
  String? status;
  int? userId;

  SupplyFeedback({this.message, this.overallRating, this.status, this.userId});

  SupplyFeedback.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    overallRating = json['overall_rating'];
    status = json['status'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['overall_rating'] = overallRating;
    data['status'] = status;
    data['user_id'] = userId;
    return data;
  }
}

class FeedbackEventResponse
{
  String? status;
  String? message;
  Events? events;

  FeedbackEventResponse({this.message,this.status, this.events});

  FeedbackEventResponse.fromJson(Map<String, dynamic> json){
    message = json['message'];
    status = json['status'];
    events = json['data'] != null
        ? Events.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    if (data != null) {
      data['data'] = events!.toJson();
    }
    return data;
  }
}

class Events
{
  List<FeedbackEvent>? events;

  Events(
      {this.events});

  Events.fromJson(Map<String, dynamic> json){
    if (json['events'] != null) {
      events = <FeedbackEvent>[];
      json['events'].forEach((v) {
        events!.add(FeedbackEvent.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (events != null) {
      data['events'] = events!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FeedbackEvent
{
  String? eventName;
  int? id;
  String? createdAt;
  int? userId;

  FeedbackEvent({this.eventName, this.id, this.createdAt, this.userId});

  FeedbackEvent.fromJson(Map<String, dynamic> json) {
    eventName = json['event_name'];
    id = json['id'];
    createdAt = json['created_at'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['event_name'] = eventName;
    data['id'] = id;
    data['created_at'] = createdAt;
    data['user_id'] = userId;
    return data;
  }
}




