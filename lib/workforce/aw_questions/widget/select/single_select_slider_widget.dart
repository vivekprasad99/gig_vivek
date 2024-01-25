import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class SingleSelectSliderWidget extends StatefulWidget {
  final Question question;
  final Function(Question question) onAnswerUpdate;

  SingleSelectSliderWidget(this.question, this.onAnswerUpdate, {Key? key})
      : super(key: key);

  @override
  State<SingleSelectSliderWidget> createState() =>
      _SingleSelectSliderWidgetState();
}

class _SingleSelectSliderWidgetState extends State<SingleSelectSliderWidget> {
  final _sliderValue = BehaviorSubject<int>.seeded(1);
  Function(int) get changeSliderValue => _sliderValue.sink.add;

  @override
  void dispose() {
    _sliderValue.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildSliderWidget();
  }

  Widget buildSliderWidget() {
    double value = 1;
    if (widget.question.answerUnit?.hasAnswered() ?? false) {
      value = double.parse(widget.question.answerUnit!.stringValue!);
    } else {
      widget.question.answerUnit?.stringValue = value.toString();
      widget.onAnswerUpdate(widget.question);
    }
    return Column(
      children: [
        Slider(
          min: 1,
          max: 12,
          activeColor: AppColors.primaryMain,
          inactiveColor: AppColors.backgroundGrey400,
          value: value,
          onChanged: (value) {
            if (!(widget.question.configuration?.isEditable ?? true)) {
              return;
            }
            changeSliderValue(value.round());
            widget.question.answerUnit?.stringValue = value.toString();
            widget.onAnswerUpdate(widget.question);
          },
        ),
        // FlutterSlider(
        //   max: 12,
        //   values: const [12],
        //   min: 1,
        //   onDragging: (handlerIndex, lowerValue, upperValue) {
        //     if (!(question.configuration?.isEditable ?? true)) {
        //       return;
        //     }
        //     question.answerUnit?.stringValue = lowerValue.toString();
        //     onAnswerUpdate(question);
        //   },
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder<int>(
                stream: _sliderValue.stream,
                builder: (context, snapshot) {
                  return Text(snapshot.hasData ? snapshot.data.toString() : '1',
                      style: Get.textTheme.caption
                          ?.copyWith(color: AppColors.backgroundGrey700));
                }),
            Text('12',
                style: Get.textTheme.caption
                    ?.copyWith(color: AppColors.backgroundGrey700)),
          ],
        ),
      ],
    );
  }
}
