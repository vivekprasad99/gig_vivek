import 'package:awign/workforce/aw_questions/data/model/configuration/select/select_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/option.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/widget/question_hint_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_index_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_required_icon_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_text_widget.dart';
import 'package:awign/workforce/aw_questions/widget/select/bottom_sheet/single_select_bottom_sheet/cubit/single_select_cubit.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/debouncer.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSingleSelectBottomSheet(BuildContext context, Question? question,
    Function(String?, Option?) onSubmitTap) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimens.radius_16),
        topRight: Radius.circular(Dimens.radius_16),
      ),
    ),
    builder: (_) {
      return SingleSelectWidget(question, onSubmitTap);
    },
  );
}

class SingleSelectWidget extends StatefulWidget {
  Question? question;
  Function(String?, Option?) onSubmitTap;

  SingleSelectWidget(this.question, this.onSubmitTap, {Key? key})
      : super(key: key);

  @override
  State<SingleSelectWidget> createState() => _SingleSelectWidgetState();
}

class _SingleSelectWidgetState extends State<SingleSelectWidget> {
  late SingleSelectCubit _singleSelectCubit;
  final _searchQuery = TextEditingController();
  final _debouncer = Debouncer();

  @override
  void initState() {
    _singleSelectCubit = sl<SingleSelectCubit>();
    _searchQuery.addListener(_onSearchChanged);

    SelectConfiguration configuration =
        widget.question?.configuration as SelectConfiguration;
    if (configuration.options != null) {
      _singleSelectCubit.addAllOptions(configuration.options!);
    } else if (configuration.optionEntities != null) {
      _singleSelectCubit.addAllOptionEntities(configuration.optionEntities!);
    }
    if (configuration.options != null &&
        widget.question?.answerUnit?.stringValue != null) {
      _singleSelectCubit
          .setSelectedOption(widget.question!.answerUnit!.stringValue!);
    } else if (configuration.optionEntities != null &&
        widget.question?.answerUnit?.optionValue != null) {
      _singleSelectCubit
          .setSelectedOptionEntity(widget.question!.answerUnit!.optionValue!);
    } else if (configuration.optionEntities != null &&
        widget.question?.answerUnit?.stringValue != null) {
      _singleSelectCubit.setSelectedOptionEntityByStringValue(
          widget.question!.answerUnit!.stringValue!);
    } else {
      _singleSelectCubit.changeSelectedOption(null);
    }
    super.initState();
  }

  _onSearchChanged() {
    _debouncer(() {
      _singleSelectCubit.searchOptions(_searchQuery.text);
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Column(
          children: [
            const SizedBox(height: Dimens.padding_16),
            buildWidgetsAccordingToModuleCategory(),
            buildOptionsList(controller),
          ],
        );
      },
    );
  }

  Widget buildWidgetsAccordingToModuleCategory() {
    switch (widget.question?.dynamicModuleCategory) {
      case DynamicModuleCategory.onboarding:
      case DynamicModuleCategory.dreamApplication:
      case DynamicModuleCategory.profileCompletion:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: Dimens.padding_16),
            buildBottomSheetTitle(),
            buildCloseIcon(),
          ],
        );
      default:
        return Column(
          children: [
            buildCloseIcon(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuestionIndexWidget(widget.question),
                  const SizedBox(width: Dimens.margin_16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QuestionTextWidget(widget.question),
                        QuestionHintWidget(widget.question),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimens.margin_16),
                  QuestionRequiredIconWidget(widget.question),
                ],
              ),
            ),
            const SizedBox(height: Dimens.margin_20),
            buildSearchTextField(),
          ],
        );
    }
  }

  Widget buildBottomSheetTitle() {
    if (widget.question?.getBottomSheetTitle() == null) {
      return Expanded(child: QuestionTextWidget(widget.question));
    } else {
      return Expanded(
          child: Text(widget.question?.getBottomSheetTitle() ?? '',
              style: Get.textTheme.headline6));
    }
  }

  Widget buildCloseIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: MyInkWell(
        onTap: () {
          MRouter.pop(null,
              isLocal: (widget.question?.dynamicModuleCategory ==
                          DynamicModuleCategory.dreamApplication ||
                      widget.question?.dynamicModuleCategory ==
                          DynamicModuleCategory.profileCompletion)
                  ? true
                  : false);
        },
        child: const Padding(
          padding:
              EdgeInsets.fromLTRB(Dimens.padding_16, 0, Dimens.padding_16, 0),
          child: Icon(Icons.close),
        ),
      ),
    );
  }

  Widget buildSearchTextField() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Dimens.padding_24, 0, Dimens.padding_24, 0),
      child: Stack(
        children: [
          TextField(
            style: Get.textTheme.bodyText1,
            maxLines: 1,
            controller: _searchQuery,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            onSubmitted: (v) {
              _singleSelectCubit.searchOptions(_searchQuery.text);
            },
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_48,
                  Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
              fillColor: Get.theme.textFieldBackgroundColor,
              hintText: 'search'.tr,
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Get.theme.textFieldBackgroundColor),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Get.theme.textFieldBackgroundColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Get.theme.textFieldBackgroundColor),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: Dimens.padding_16),
                child: Icon(
                  Icons.search,
                  color: Get.theme.iconColorNormal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOptionsList(ScrollController scrollController) {
    return StreamBuilder<List<String>>(
      stream: _singleSelectCubit.optionsListStream,
      builder: (context, optionsList) {
        if (optionsList.hasData) {
          return StreamBuilder<int?>(
              stream: _singleSelectCubit.selectedOptionStream,
              builder: (context, selectedOption) {
                return Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: optionsList.data?.length,
                    itemBuilder: (_, i) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                            Dimens.padding_16, Dimens.padding_16, 0),
                        child: MyInkWell(
                          onTap: () {
                            SelectConfiguration configuration = widget
                                .question?.configuration as SelectConfiguration;
                            _singleSelectCubit.changeSelectedOption(i);
                            widget.onSubmitTap(
                                optionsList.data?[i],
                                _singleSelectCubit.getSelectedOption(
                                    configuration.optionEntities));
                            MRouter.pop(null,
                                isLocal:
                                    (widget.question?.dynamicModuleCategory ==
                                                DynamicModuleCategory
                                                    .dreamApplication ||
                                            widget.question
                                                    ?.dynamicModuleCategory ==
                                                DynamicModuleCategory
                                                    .profileCompletion)
                                        ? true
                                        : false);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Radio<int?>(
                                    value: i,
                                    groupValue: selectedOption.data,
                                    onChanged: (v) {}),
                              ),
                              const SizedBox(width: Dimens.padding_16),
                              Flexible(
                                child: Text(optionsList.data?[i] ?? '',
                                    style: Get.context?.textTheme.bodyText1),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              });
        } else {
          return AppCircularProgressIndicator();
        }
      },
    );
  }
}
