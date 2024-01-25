import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/data/model/enum.dart';

class ScreenRowType<String> extends Enum1<String> {
  const ScreenRowType(String val) : super(val);

  static const ScreenRowType question = ScreenRowType('question');
  static const ScreenRowType category = ScreenRowType('category_listing');
  static const ScreenRowType screen = ScreenRowType('screen');
}

class ScreenRow {
  ScreenRow({
    this.rowType,
    this.screenData,
    this.groupData,
    this.question,
  });

  late ScreenRowType? rowType;
  late ScreenData? screenData;
  late GroupData? groupData;
  late Question? question;
}

class ScreenData {
  ScreenData({
    this.screen,
    this.isExpanded = false,
  });

  late Screen? screen;
  late bool isExpanded;
}

class GroupData {
  GroupData({
    this.groupName,
    this.answerQuestionCount,
    this.questions,
    this.isExpanded = false,
  });

  late String? groupName;
  late int? answerQuestionCount;
  late List<Question>? questions;
  late bool isExpanded;
}
