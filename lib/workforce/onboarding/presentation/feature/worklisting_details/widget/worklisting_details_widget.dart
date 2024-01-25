import 'package:awign/workforce/aw_questions/data/model/row/screen_row.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/common_extension.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/app_log.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/eligibility_bottom_sheet/widget/eligibility_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/label/app_label.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/eligibility_entity_response.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/cubit/category_application_details_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/helper/category_application_action_helper.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/location_type.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing/work_listing.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_questions/widget/category_questions_widget.dart';
import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/cubit/worklisting_details_cubit.dart';
import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/data/work_listing_details_arguments.dart';
import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/widget/bottom_sheet/worklisting_details_bottomsheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:awign/workforce/core/widget/bottom_sheet/select_location_bottom_sheet/model/location_item.dart' as lt;


import '../../../../../core/widget/bottom_sheet/select_location_bottom_sheet/widget/select_location_bottom_sheet.dart';

class WorkListingDetailsWidget extends StatefulWidget {
  final WorkListingDetailsArguments workListingDetailsArguments;

  const WorkListingDetailsWidget(this.workListingDetailsArguments, {Key? key})
      : super(key: key);

  @override
  WorkListingDetailsWidgetState createState() =>
      WorkListingDetailsWidgetState();
}

class WorkListingDetailsWidgetState extends State<WorkListingDetailsWidget> {
  final _workListingDetailsCubit = sl<WorkListingDetailsCubit>();
  CategoryApplicationActionHelper categoryApplicationHelper =
      CategoryApplicationActionHelper();
  UserData? _currentUser;
  bool isSkipSaasOrgID = false;
  int? categoryID;
  String? saasOrgID;
  String stipend = '';
  bool isClickable = false;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    saasOrgID = spUtil?.getSaasOrgID();
    if (saasOrgID.isNullOrEmpty) {
      isSkipSaasOrgID = true;
    }
    _onRefresh();
  }

  _onRefresh() {
    _workListingDetailsCubit.fetchWorkListing(
        _currentUser?.id ?? -1,
        widget.workListingDetailsArguments.workListingID,
        saasOrgID,
        isSkipSaasOrgID);
  }

  void subscribeUIStatus() {
    _workListingDetailsCubit.uiStatus.listen(
      (uiStatus) {
        if (uiStatus.isDialogLoading) {
          Helper.showLoadingDialog(context, uiStatus.loadingMessage);
        } else if (!uiStatus.isDialogLoading) {
          Helper.hideLoadingDialog();
        }
        if (uiStatus.successWithoutAlertMessage.isNotEmpty) {
          Helper.showInfoToast(uiStatus.successWithoutAlertMessage);
        }
        if (uiStatus.failedWithoutAlertMessage.isNotEmpty) {
          Helper.showErrorToast(uiStatus.failedWithoutAlertMessage);
        }
        switch (uiStatus.event) {
          case Event.created:
            MRouter.pop(null);
            break;
          case Event.success:
            _onApplicationActionTapped(
                _workListingDetailsCubit.workApplicationEntityValue,
                _workListingDetailsCubit.categoryApplicationValue!);
            break;
          case Event.selected:
            sl<CategoryApplicationDetailsCubit>().getApplicationAndExecution(
                _currentUser!,
                _workListingDetailsCubit.categoryApplicationValue!,
                isSkipSaasOrgID);
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: buildMobileUI(),
      desktop: const DesktopComingSoonWidget(),
    );
  }

  Widget buildMobileUI() {
    return AppScaffold(
      backgroundColor: AppColors.primaryMain,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            const DefaultAppBar(isCollapsable: true, title: ''),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: InternetSensitive(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimens.padding_24,
                    Dimens.padding_24,
                    Dimens.padding_24,
                    Dimens.padding_24,
                  ),
                  child: StreamBuilder<WorkListing?>(
                      stream: _workListingDetailsCubit.workListingStream,
                      builder: (context, workListing) {
                        if (workListing.hasData && workListing.data != null) {
                          categoryID = workListing.data!.categoryId;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildCategoryDetailsWidget(
                                  workListing.data!.icon ?? ''),
                              const SizedBox(height: Dimens.margin_16),
                              Text(
                                workListing.data?.name ?? '',
                                style: context.textTheme.headline7Bold,
                              ),
                              const SizedBox(height: Dimens.margin_16),
                              buildDetailsWhiteContainer(workListing.data!),
                              const SizedBox(height: Dimens.margin_16),
                              buildWorkFromHomeWidget(workListing.data!),
                              buildWhoCanApplyWidget(workListing.data!),
                              buildDescriptionWidget(workListing.data!),
                              buildRolesAndResponsibilitiesWidget(
                                  workListing.data!),
                              buildWhatYouGetWidget(workListing.data!),
                              const SizedBox(height: Dimens.margin_16),
                            ],
                          );
                        } else if (workListing.hasError) {
                          return Column(
                            children: [
                              buildCategoryDetailsWidget(''),
                              buildEmptyView(),
                            ],
                          );
                        } else {
                          return AppCircularProgressIndicator();
                        }
                      }),
                ),
              ),
            ),
            StreamBuilder<
                    Tuple2<List<CategoryApplication>,
                        List<WorkApplicationEntity>>?>(
                stream:
                    _workListingDetailsCubit.workApplicationForCategoryStream,
                builder: (context, workApplicationForCategory) {
                  if (workApplicationForCategory.hasData &&
                      workApplicationForCategory.data?.item2 != null &&
                      workApplicationForCategory.data!.item2.isNotEmpty &&
                      (!workApplicationForCategory
                          .data!.item2[0].isEligible!)) {
                    return buildCheckEligiblityWidget(
                        workApplicationForCategory.data!.item2[0]);
                  } else {
                    return buildBottomButton();
                  }
                }),
          ],
        ),
      ),
    );
  }

  Widget buildCheckEligiblityWidget(
      WorkApplicationEntity workApplicationEntity) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_8,
          Dimens.padding_16, Dimens.padding_16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16,
            Dimens.padding_16, Dimens.padding_16),
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey400,
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_8)),
          border: Border.all(
            color: AppColors.backgroundGrey400,
            width: Dimens.border_1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'dont_full_eligibility_text'.tr,
              style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.backgroundGrey800),
            ),
            const SizedBox(
              height: Dimens.margin_8,
            ),
            MyInkWell(
              onTap: () {
                onCheckEligibilityTap(
                    workApplicationEntity.categoryApplicationId,
                    workApplicationEntity.workListingId,
                    workApplicationEntity.categoryId);
              },
              child: Text(
                'check_eligibility'.tr,
                style: Get.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500, color: AppColors.primaryMain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onCheckEligibilityTap(
      int? categoryApplicationId, int? workListingId, int? categoryId) async {
    await eligibilityBottomSheet(
        Get.context!, categoryApplicationId, workListingId, categoryId,
        (List<ApplicationAnswers>? applicationAnswers, int? categoryId) async {
      EligiblityData eligiblityData = EligiblityData(
          applicationAnswers: applicationAnswers, categoryId: categoryId);
      MRouter.pop(null);
      bool? value = await MRouter.pushNamed(MRouter.applicationResultWidget,
          arguments: eligiblityData);
      if (value ?? false) {
        _onRefresh();
      }
    });
  }

  Widget buildEmptyView() {
    return Column(
      children: [
        const SizedBox(height: Dimens.padding_64),
        Image.asset('assets/images/empty_icon.png',
            width: Dimens.imageWidth_150, height: Dimens.imageHeight_150),
        const SizedBox(height: Dimens.padding_16),
        Text('you_have_not_applied_for_any_jobs'.tr,
            style: Get.textTheme.bodyText1SemiBold),
        const SizedBox(height: Dimens.padding_16),
        buildExploreJobsButton(),
      ],
    );
  }

  Widget buildLoginToApplyButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          Dimens.padding_24,
          Dimens.padding_16,
          Dimens.padding_24,
          foundation.defaultTargetPlatform == TargetPlatform.iOS
              ? Dimens.padding_48
              : 0),
      child: RaisedRectButton(
        text: 'login_to_apply'.tr,
        onPressed: () {
          MRouter.pushNamed(MRouter.phoneVerificationWidget);
        },
      ),
    );
  }

  Widget buildExploreJobsButton() {
    return RaisedRectButton(
      width: Dimens.btnWidth_150,
      text: 'explore_jobs'.tr,
      radius: Dimens.radius_24,
      onPressed: () {
        MRouter.pushNamedAndRemoveUntil(MRouter.categoryListingWidget);
      },
    );
  }

  Widget buildCategoryDetailsWidget(String workListingIconURL) {
    return StreamBuilder<bool>(
        stream: _workListingDetailsCubit.isCategoryDetailVisible,
        builder: (context, isCategoryDetailShow) {
          return StreamBuilder<
                  Tuple2<List<CategoryApplication>,
                      List<WorkApplicationEntity>>?>(
              stream: _workListingDetailsCubit.workApplicationForCategoryStream,
              builder: (context, snapshot) {
                bool isCategoryDetailVisible = false;
                String iconURL = workListingIconURL;
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.item1.isNotEmpty) {
                  String? status = snapshot.data!.item1[0].status;
                  if (isCategoryDetailShow.hasData) {
                    isCategoryDetailVisible = false;
                  } else if (status == "created" || status == "failed") {
                    isCategoryDetailVisible = true;
                  } else {
                    isCategoryDetailVisible = false;
                  }
                }
                return StreamBuilder<Category>(
                    stream: _workListingDetailsCubit.category,
                    builder: (context, category) {
                      if (isCategoryDetailShow.hasData) {
                        isCategoryDetailVisible = false;
                      } else {
                        if (category.hasData) {
                          isCategoryDetailVisible = true;
                          iconURL = category.data!.icon!.isNotEmpty
                              ? category.data!.icon!
                              : iconURL!;
                        }
                      }
                      if (isCategoryDetailVisible) {
                        WorkApplicationEntity? workApplicationEntity;
                        if (snapshot.data != null &&
                            snapshot.data!.item2.isNotEmpty) {
                          workApplicationEntity = snapshot.data?.item2[0];
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'job_category'.tr,
                              style: context.textTheme.bodyText1SemiBold,
                            ),
                            const SizedBox(height: Dimens.padding_16),
                            Container(
                              padding: const EdgeInsets.all(Dimens.padding_16),
                              decoration: const BoxDecoration(
                                  color: AppColors.backgroundGrey300,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(Dimens.radius_8))),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      buildCategoryIcon(iconURL),
                                      const SizedBox(width: Dimens.padding_16),
                                      Expanded(
                                        child: Text(
                                          category.data?.name ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context
                                              .textTheme.bodyText1SemiBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: Dimens.padding_16),
                                  Text(
                                    'by_applying_you_will_be_eligible_for'.tr,
                                    style: context.textTheme.caption,
                                  ),
                                  buildCategoryApplyButton(
                                      workApplicationEntity),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        if (workListingIconURL.isNotEmpty) {
                          return buildCategoryIcon(workListingIconURL);
                        } else {
                          return const SizedBox();
                        }
                      }
                    });
              });
        });
  }

  Widget buildCategoryApplyButton(
      WorkApplicationEntity? workApplicationEntity) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.margin_16, 0, 0),
      child: RaisedRectButton(
        height: Dimens.btnHeight_40,
        text: 'apply'.tr.toTitleCase(),
        onPressed: () {
          openCategoryQuestionsWidget(workApplicationEntity);
        },
      ),
    );
  }

  void openCategoryQuestionsWidget(
      WorkApplicationEntity? workApplicationEntity) async {
    List<ScreenRow> screenRowList = _workListingDetailsCubit
        .getCategoryQuestions(_currentUser?.userProfile?.userId);
    if (screenRowList.isNotEmpty) {
      Map? map = await MRouter.pushNamedWithResult(
          context,
          CategoryQuestionsWidget(categoryID ?? -1, screenRowList,
              MRouter.workListingDetailsWidget),
          MRouter.categoryQuestionsWidget);
      bool? success = map?[Constants.success];
      if (success != null && success) {
        _workListingDetailsCubit.changeIsCategoryDetailVisible(true);
        _workListingDetailsCubit.fetchWorkListing(
            _currentUser?.id ?? -1,
            widget.workListingDetailsArguments.workListingID,
            saasOrgID,
            isSkipSaasOrgID);
      }
    } else {
      _workListingDetailsCubit.reApply(
          (categoryID ?? -1).toString(),
          _currentUser?.id ?? -1,
          _workListingDetailsCubit.getWorkListing()?.id?.toString() ?? '');
    }
  }

  Widget buildCategoryIcon(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      filterQuality: FilterQuality.high,
      width: Dimens.imageWidth_48,
      height: Dimens.imageHeight_48,
      fit: BoxFit.contain,
      errorWidget: (context, url, error) =>
          Container(color: AppColors.backgroundGrey600),
    );
  }

  Widget buildDetailsWhiteContainer(WorkListing workListing) {
    return Container(
      padding: const EdgeInsets.all(Dimens.padding_16),
      decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border.all(
            color: AppColors.backgroundGrey600,
          ),
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimens.radius_8))),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_pin, size: Dimens.iconSize_16),
              const SizedBox(width: Dimens.padding_8),
              TextFieldLabel(label: 'location'.tr),
            ],
          ),
          buildLocationWidget(workListing),
          const SizedBox(height: Dimens.padding_16),
          buildDurationWidget(workListing),
          const SizedBox(height: Dimens.padding_16),
          Row(
            children: [
              const Icon(Icons.wallet, size: Dimens.iconSize_16),
              const SizedBox(width: Dimens.padding_8),
              TextFieldLabel(label: 'stipend'.tr),
            ],
          ),
          buildStipendWidget(workListing),
          const SizedBox(height: Dimens.padding_16),
          Row(
            children: [
              const Icon(Icons.article, size: Dimens.iconSize_16),
              const SizedBox(width: Dimens.padding_8),
              TextFieldLabel(label: 'requirement'.tr),
            ],
          ),
          buildRequirementWidget(workListing),
        ],
      ),
    );
  }

  Widget buildLocationWidget(WorkListing workListing) {
    String locationHTMLText = '';
    String columnName = "";
    switch (workListing.locationType) {
      case LocationType.allIndia:
        locationHTMLText = LocationType.allIndia.getValue2();
        break;
      case LocationType.states:
      case LocationType.cities:

      case LocationType.pincodes:
        if (workListing.location?.length == 1) {
          locationHTMLText = "<font color=#1FB6FF>  <u>" +
              workListing.location![0] +
              "</u> </font>";
        } else {
          locationHTMLText = "<font color=#1FB6FF>  <u>" +
              (workListing.locationType?.getValue2() ?? '') +
              "</u> </font>";
        }
        break;
      default:
        break;
    }

       return GestureDetector(
        onTap: (workListing.location?.isNotEmpty ?? false) ? () {
          showWorkListingBottomSheet(
              context, workListing.locationType?.value1 ?? "",
              workListing.id.toString(), (p0) => {});

        } : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
          child: Html(
            data: locationHTMLText,
          ),
        ),
      );
  }

  Widget buildDurationWidget(WorkListing workListing) {
    String durationLabel = '';
    String duration = '';
    switch (workListing.listingType) {
      case 'part_time_job':
        durationLabel = 'work_hours'.tr;
        duration = 'four_to_five_hours_per_day'.tr;
        break;
      case 'full_time_job':
        durationLabel = 'work_hours'.tr;
        duration = 'seven_to_eight_hours_per_day'.tr;
        break;
      default:
        durationLabel = 'duration'.tr;
        if (workListing.duration != null) {
          if (!workListing.duration!.from.isNullOrEmpty &&
              !workListing.duration!.to.isNullOrEmpty) {
            duration =
                '${workListing.duration!.from}-${workListing.duration!.to} ${workListing.duration!.type}';
          } else if (!workListing.duration!.from.isNullOrEmpty) {
            duration =
                '${workListing.duration!.from} ${workListing.duration!.type}';
          } else if (!workListing.duration!.to.isNullOrEmpty) {
            duration =
                '${workListing.duration!.to} ${workListing.duration!.type}';
          } else {
            duration = '';
          }
        }
        break;
    }
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.timer, size: Dimens.iconSize_16),
            const SizedBox(width: Dimens.padding_8),
            TextFieldLabel(label: durationLabel),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
          child: Html(
            data: duration,
          ),
        ),
      ],
    );
  }

  Widget buildStipendWidget(WorkListing workListing) {
    if (workListing.potentialEarning != null) {
      if (!workListing.potentialEarning!.from.isNullOrEmpty &&
          !workListing.potentialEarning!.to.isNullOrEmpty) {
        stipend =
            '${workListing.potentialEarning!.earningType?.replaceAll('_', '').toCapitalized()} '
            '${Constants.rs}${workListing.potentialEarning!.from}-${Constants.rs}${workListing.potentialEarning!.to} '
            '${workListing.potentialEarning!.earningDuration}';
      } else if (!workListing.potentialEarning!.from.isNullOrEmpty) {
        stipend =
            '${workListing.potentialEarning!.earningType?.replaceAll('_', '').toCapitalized()} '
            '${Constants.rs}${workListing.potentialEarning!.from} ${workListing.potentialEarning!.earningDuration}';
      } else if (!workListing.potentialEarning!.to.isNullOrEmpty) {
        stipend =
            '${workListing.potentialEarning!.earningType?.replaceAll('_', '').toCapitalized()} '
            '${Constants.rs}${workListing.potentialEarning!.to} ${workListing.potentialEarning!.earningDuration}';
      } else {
        stipend = '';
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Html(
        data: stipend,
      ),
    );
  }

  Widget buildRequirementWidget(WorkListing workListing) {
    String requirement = 'please_check_who_can_apply'.tr;
    if (workListing.requirements != null) {
      requirement = workListing.requirements!;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_16),
      child: Html(
        data: requirement,
      ),
    );
  }

  Widget buildWorkFromHomeWidget(WorkListing workListing) {
    if (workListing.executionType == ExecutionType.workFromHome) {
      return Padding(
        padding: const EdgeInsets.only(bottom: Dimens.padding_16),
        child: Row(
          children: [
            const Icon(Icons.done_rounded, size: Dimens.iconSize_16),
            const SizedBox(width: Dimens.padding_8),
            TextFieldLabel(label: 'work_from_home'.tr),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildWhoCanApplyWidget(WorkListing workListing) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 0),
      textColor: context.theme.iconColorNormal,
      iconColor: context.theme.iconColorNormal,
      initiallyExpanded: true,
      title: Text(
        'who_can_apply'.tr,
        style: context.textTheme.headline7SemiBold,
      ),
      children: <Widget>[
        Html(
          data: workListing.whoCanApply ?? '',
        ),
      ],
    );
  }

  Widget buildDescriptionWidget(WorkListing workListing) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 0),
      textColor: context.theme.iconColorNormal,
      iconColor: context.theme.iconColorNormal,
      initiallyExpanded: true,
      title: Text(
        'description'.tr,
        style: context.textTheme.headline7SemiBold,
      ),
      children: <Widget>[
        Html(
          data: workListing.description ?? '',
        ),
      ],
    );
  }

  Widget buildRolesAndResponsibilitiesWidget(WorkListing workListing) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 0),
      textColor: context.theme.iconColorNormal,
      iconColor: context.theme.iconColorNormal,
      title: Text(
        'roles_and_responsibilities'.tr,
        style: context.textTheme.headline7SemiBold,
      ),
      children: <Widget>[
        Html(
          data: workListing.rolesAndResponsibilities ?? '',
        ),
      ],
    );
  }

  Widget buildWhatYouGetWidget(WorkListing workListing) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 0),
      textColor: context.theme.iconColorNormal,
      iconColor: context.theme.iconColorNormal,
      title: Text(
        'what_you_get'.tr,
        style: context.textTheme.headline7SemiBold,
      ),
      children: <Widget>[
        Html(
          data: workListing.whatYouGet ?? '',
        ),
      ],
    );
  }

  Widget buildBottomButton() {
    return StreamBuilder<bool>(
        stream: _workListingDetailsCubit.isCategoryDetailVisible,
        builder: (context, isCategoryDetailShow) {
          return StreamBuilder<
                  Tuple2<List<CategoryApplication>,
                      List<WorkApplicationEntity>>?>(
              stream: _workListingDetailsCubit.workApplicationForCategoryStream,
              builder: (context, snapshot) {
                bool isButtonVisible = false;
                String btnText = '';
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.item1.isNotEmpty) {
                  String? status = snapshot.data!.item1[0].status;
                  if (isCategoryDetailShow.hasData) {
                    btnText = 'go_to_office'.tr;
                    isButtonVisible = true;
                  } else if (status == "created" || status == "failed") {
                    if (categoryID != null) {
                      _workListingDetailsCubit.getCategory(categoryID!);
                    }
                    isButtonVisible = false;
                  } else {
                    if (snapshot.data!.item2.isEmpty) {
                      btnText = 'apply'.tr;
                    } else {
                      btnText = 'go_to_office'.tr;
                    }
                    isButtonVisible = true;
                  }
                } else {
                  if (categoryID != null) {
                    _workListingDetailsCubit.getCategory(categoryID!);
                  }
                }
                if (isCategoryDetailShow.hasData) {
                  btnText = 'go_to_office'.tr;
                  isButtonVisible = true;
                } else if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.item2.isNotEmpty &&
                    snapshot.data!.item2[0].pendingAction != null) {
                  btnText = snapshot
                          .data!.item2[0].pendingAction?.actionKey?.value1 ??
                      'go_to_office'.tr;
                }
                return StreamBuilder<Category>(
                    stream: _workListingDetailsCubit.category,
                    builder: (context, category) {
                      if (isCategoryDetailShow.hasData) {
                        btnText = 'go_to_office'.tr;
                        isButtonVisible = true;
                      } else {
                        if (category.hasData) {
                          isButtonVisible = false;
                        }
                      }
                      if (isButtonVisible) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                              Dimens.margin_16,
                              Dimens.margin_24,
                              Dimens.margin_16,
                              Dimens.margin_32),
                          child: RaisedRectButton(
                            height: Dimens.btnHeight_40,
                            text: btnText,
                            onPressed: () {
                              if (_workListingDetailsCubit
                                          .getWorkApplicationEntity() ==
                                      null ||
                                  (_workListingDetailsCubit
                                          .getWorkApplicationEntity()
                                          ?.pendingAction
                                          ?.actionKey
                                          ?.isReApply() ??
                                      false)) {
                                _workListingDetailsCubit.reApply(
                                    (categoryID ?? -1).toString(),
                                    _currentUser?.id ?? -1,
                                    _workListingDetailsCubit
                                            .getWorkListing()
                                            ?.id
                                            ?.toString() ??
                                        '');
                              } else if (snapshot.data != null &&
                                  !snapshot.data!.item2.isNullOrEmpty) {
                                _onApplicationActionTapped(
                                    snapshot.data!.item2[0],
                                    snapshot.data!.item1[0]);
                              }
                            },
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    });
              });
        });
  }

  _onApplicationActionTapped(WorkApplicationEntity workApplicationEntity,
      CategoryApplication categoryApplication) {
    ActionData? actionData = workApplicationEntity.pendingAction;
    workApplicationEntity.fromRoute = MRouter.workListingDetailsWidget;
    categoryApplicationHelper.onApplicationActionTapped(
        context, workApplicationEntity, actionData!, _currentUser,
        (UserData? currentUser, WorkApplicationEntity workApplicationEntity) {
      executionApplicationEvent(currentUser, workApplicationEntity);
    }, _onRefresh);
    _workListingDetailsCubit.changeCategoryApplication(categoryApplication);
  }

  void executionApplicationEvent(
      UserData? currentUser, WorkApplicationEntity workApplicationEntity) {
    _workListingDetailsCubit.executeApplicationEvent(
        currentUser!.id!,
        workApplicationEntity.workListingId!,
        workApplicationEntity.id!,
        workApplicationEntity.pendingAction!.actionKey!);
  }
}
