import 'package:awign/workforce/aw_questions/data/model/configuration/select/select_configuration.dart';
import 'package:awign/workforce/aw_questions/data/model/dynamic_module_category.dart';
import 'package:awign/workforce/aw_questions/data/model/option.dart';
import 'package:awign/workforce/aw_questions/data/model/question.dart';
import 'package:awign/workforce/aw_questions/widget/question_hint_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_index_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_required_icon_widget.dart';
import 'package:awign/workforce/aw_questions/widget/question_text_widget.dart';
import 'package:awign/workforce/aw_questions/widget/select/bottom_sheet/multi_select_bottom_sheet/cubit/multi_select_bottom_sheet_cubit.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/debouncer.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showMultiSelectBottomSheet(BuildContext context, Question? question,
    Function(List<String>, List<Option>?) onSubmitTap) {
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
      return MultiSelectWidget(question, onSubmitTap);
    },
  );
}

class MultiSelectWidget extends StatefulWidget {
  final Question? question;
  final Function(List<String>, List<Option>?) onSubmitTap;

  const MultiSelectWidget(this.question, this.onSubmitTap, {Key? key})
      : super(key: key);

  @override
  State<MultiSelectWidget> createState() => _MultiSelectWidgetState();
}

class _MultiSelectWidgetState extends State<MultiSelectWidget> {
  late MultiSelectBottomSheetCubit _multiSelectCubit;
  final _searchQuery = TextEditingController();
  final _debouncer = Debouncer();

  @override
  void initState() {
    _multiSelectCubit = sl<MultiSelectBottomSheetCubit>();
    _searchQuery.addListener(_onSearchChanged);

    SelectConfiguration configuration =
        widget.question?.configuration as SelectConfiguration;
    if (configuration.options != null) {
      _multiSelectCubit.addAllOptions(configuration.options!);
    } else if (configuration.optionEntities != null) {
      _multiSelectCubit.addAllOptionEntities(configuration.optionEntities!);
    }
    if (widget.question?.answerUnit?.listValue != null) {
      _multiSelectCubit
          .setSelectedOptions(widget.question!.answerUnit!.listValue!);
    } else if (widget.question?.answerUnit?.optionListValue != null) {
      _multiSelectCubit.setSelectedOptionEntities(
          widget.question!.answerUnit!.optionListValue!);
    }
    super.initState();
  }

  _onSearchChanged() {
    _debouncer(() {
      _multiSelectCubit.searchOptions(_searchQuery.text);
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
            buildWidgetsAccordingToModuleCategory(),
            // const SizedBox(height: Dimens.margin_8),
            buildOptionsList(controller),
            const SizedBox(height: Dimens.margin_16),
            buildSubmitButton(),
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
          children: [
            const SizedBox(width: Dimens.padding_24),
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
                  const EdgeInsets.symmetric(horizontal: Dimens.padding_24),
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
    return Expanded(
        child: Text(widget.question?.getBottomSheetTitle() ?? '',
            style: Get.textTheme.headline6));
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
          padding: EdgeInsets.all(Dimens.padding_24),
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
              _multiSelectCubit.searchOptions(_searchQuery.text);
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
    return StreamBuilder<List<Option>>(
      stream: _multiSelectCubit.optionsListStream,
      builder: (context, optionsList) {
        if (optionsList.hasData) {
          return StreamBuilder<Option?>(
              stream: _multiSelectCubit.selectedOptionStream,
              builder: (context, selectedOption) {
                return Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: optionsList.data?.length,
                    itemBuilder: (_, i) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(Dimens.padding_12,
                            Dimens.padding_8, Dimens.padding_12, 0),
                        child: MyInkWell(
                          onTap: () {
                            _multiSelectCubit
                                .updateSelectedOption(optionsList.data![i]);
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: optionsList.data?[i].isSelected,
                                onChanged: (v) {},
                              ),
                              Flexible(
                                child: Text(optionsList.data?[i].name ?? '',
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

  Widget buildSubmitButton() {
    bool a = true;
    return Padding(
      padding: const EdgeInsets.all(Dimens.padding_24),
      child: RaisedRectButton(
        text: 'submit'.tr,
        onPressed: () {
          widget.onSubmitTap(_multiSelectCubit.getSelectedOptions(),
              _multiSelectCubit.getSelectedOptionsEntities());
          MRouter.pop(null,
              isLocal: (widget.question?.dynamicModuleCategory ==
                          DynamicModuleCategory.dreamApplication ||
                      widget.question?.dynamicModuleCategory ==
                          DynamicModuleCategory.profileCompletion)
                  ? true
                  : false);
        },
      ),
    );
  }
}
