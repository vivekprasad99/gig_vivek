import 'package:awign/workforce/aw_questions/data/mapper/answer_unit_mapper.dart';
import 'package:awign/workforce/aw_questions/data/model/parent_reference/lead_reference.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/aw_questions/data/model/screen/screen.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_entity.dart';
import 'package:awign/workforce/execution_in_house/data/model/lead_screen_response.dart';
import 'package:tuple/tuple.dart';

import '../../../../aw_questions/data/model/answer/answer_unit.dart';
import '../../../../aw_questions/data/model/configuration/attachment/file_configuration.dart';
import '../../../data/model/execution.dart';

class LeadScreenRowsProvider {

  static const String metaData = "_metadata";

  static Tuple2<List<ScreenRow>, bool> getScreenRows(
      LeadScreenResponse leadScreenResponse, Lead lead, Execution execution) {
    List<ScreenRow> screenRowList = [];
    bool isLocationTrackableQuestionExist = false;
    if (leadScreenResponse.screen?.groups != null &&
        leadScreenResponse.screen?.groupedQuestions != null) {
      bool isExpanded = leadScreenResponse.screen!.groups!.length < 5;
      for (Group group in leadScreenResponse.screen!.groups!) {
        List<Question>? lQuestionList =
            leadScreenResponse.screen?.groupedQuestions![group.uid];
        if (lQuestionList.isNullOrEmpty) {
          continue;
        }
        if (group.uid == questionUngrouped) {
          Tuple2<List<ScreenRow>, bool> tuple2 = getQuestionRows(lQuestionList!, lead, execution,
              leadScreenResponse.screen?.id ?? '');
          screenRowList.addAll(tuple2.item1);
          isLocationTrackableQuestionExist = tuple2.item2;
        } else {
          Tuple2<ScreenRow, bool> tuple2 = getGroupRow(
              screenRowList.length,
              group.name ?? '',
              lQuestionList!,
              lead,
              isExpanded,
              execution,
              leadScreenResponse.screen?.id ?? '');
          screenRowList.add(tuple2.item1);
          isLocationTrackableQuestionExist = tuple2.item2;
        }
      }
    }
    return Tuple2(screenRowList, isLocationTrackableQuestionExist);
  }

  static Tuple2<List<ScreenRow>, bool> getQuestionRows(List<Question> questionList, Lead lead,
      Execution execution, String screenID) {
    List<ScreenRow> screenRowList = [];
    int count = 1;
    bool isLocationTrackableQuestionExist = false;
    for (Question question in questionList) {
      question.screenRowIndex = count - 1;
      question.leadID = lead.getLeadID();
      question.screenID = screenID;
      question.projectID = execution.projectId;
      question.executionID = execution.id;
      question.selectedProjectRole = execution.selectedProjectRole;
      question.configuration?.questionIndex = count;
      isLocationTrackableQuestionExist = question.configuration?.isLocationTrackable ?? false;
      dynamic value = lead.getLeadAnswerValue(question.configuration?.uid);
      question.answerUnit = AnswerUnitMapper.getAnswerUnit(question.inputType,
          question.dataType, value, question.nestedQuestionList);
      if (question.parentReference is LeadReference) {
        (question.parentReference as LeadReference).leadID = lead.getLeadID();
      }
      for (Question nestedQuestion in question.nestedQuestionList ?? []) {
        if (nestedQuestion.parentReference is LeadReference) {
          (nestedQuestion.parentReference as LeadReference).leadID =
              lead.getLeadID();
        }
      }
      ScreenRow screenRow = ScreenRow(
          rowType: ScreenRowType.question,
          screenData: null,
          groupData: null,
          question: question);
      screenRowList.add(screenRow);
      count++;
    }
    return Tuple2(screenRowList, isLocationTrackableQuestionExist);
  }

  static Tuple2<ScreenRow, bool> getGroupRow(
      int groupQuestionIndex,
      String groupName,
      List<Question> questionList,
      Lead lead,
      bool isExpanded,
      Execution execution,
      String screenID) {
    List<Question> lQuestionList = [];
    int count = 1;
    bool isLocationTrackableQuestionExist = false;
    for (Question question in questionList) {
      question.screenRowIndex = count - 1;
      question.groupQuestionIndex = groupQuestionIndex;
      question.leadID = lead.getLeadID();
      question.screenID = screenID;
      question.projectID = execution.projectId;
      question.executionID = execution.id;
      question.selectedProjectRole = execution.selectedProjectRole;
      question.configuration?.questionIndex = count;
      isLocationTrackableQuestionExist = question.configuration?.isLocationTrackable ?? false;
      dynamic value = lead.getLeadAnswerValue(question.configuration?.uid);
      question.answerUnit = AnswerUnitMapper.getAnswerUnit(question.inputType,
          question.dataType, value, question.nestedQuestionList);
      if (question.parentReference is LeadReference) {
        (question.parentReference as LeadReference).leadID = lead.getLeadID();
      }
      for (Question nestedQuestion in question.nestedQuestionList ?? []) {
        if (nestedQuestion.parentReference is LeadReference) {
          (nestedQuestion.parentReference as LeadReference).leadID =
              lead.getLeadID();
        }
      }
      AnswerUnit answerUnit = AnswerUnitMapper.getAnswerUnit(question.inputType, question.dataType, value, question.nestedQuestionList);
      if (question.configuration is FileConfiguration &&
          (question.configuration as FileConfiguration).imageMetaData != null) {
        String metaDataKey = '${question.configuration?.uid} + $metaData';
        AnswerUnitMapper.setMetaDataInAnswerUnit(lead.leadMap[metaDataKey], answerUnit);
      }
      lQuestionList.add(question);
      count++;
    }
    ScreenRow screenRow = ScreenRow(
        rowType: ScreenRowType.category,
        screenData: null,
        groupData: GroupData(
            groupName: groupName,
            answerQuestionCount: getAnsweredQuestionCount(lQuestionList),
            questions: lQuestionList,
            isExpanded: isExpanded),
        question: null);
    return Tuple2(screenRow, isLocationTrackableQuestionExist);
  }

  static int getAnsweredQuestionCount(List<Question> questions) {
    int count = 0;
    for (Question question in questions) {
      if (question.hasAnswered()) {
        count++;
      }
    }
    return count;
  }
}
