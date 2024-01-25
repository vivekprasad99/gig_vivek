import 'package:awign/workforce/core/config/cubit/flavor_cubit.dart';
import 'package:awign/workforce/core/config/flavor_config.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/eligibility_bottom_sheet/widget/eligibility_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/bottom_sheet/show_salary_bottom_sheet/widget/show_salary_bottom_sheet.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/image_loader/network_image_loader.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/shimmer/shimmer_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/eligibility_entity_response.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/cubit/category_application_details_cubit.dart';
import 'package:awign/workforce/execution_in_house/feature/category_application_details/helper/category_application_action_helper.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_application/work_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/work_listing/work_listing_response.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_detail_and_job/cubit/category_detail_and_job_cubit.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_detail_and_job/widget/tile/worklist_tile.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_listing/widget/tile/category_shimmer_tile.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_questions/widget/category_questions_widget.dart';
import 'package:awign/workforce/onboarding/presentation/feature/worklisting_details/data/work_listing_details_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' as foundation;
import '../../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../../core/widget/buttons/my_ink_well.dart';
import '../../../../data/model/category/category_response.dart';
import '../../category_listing/bottom_sheet/notified_soon_bottomsheet_widget.dart';

class CategoryDetailAndJobWidget extends StatefulWidget {
  final int categoryID;
  final CategoryApplication? categoryApplication;
  final bool? openNotifyBottomSheet;

  const CategoryDetailAndJobWidget(this.categoryID, this.categoryApplication,
      this.openNotifyBottomSheet, {Key? key})
      : super(key: key);

  @override
  State<CategoryDetailAndJobWidget> createState() =>
      _CategoryDetailAndJobWidgetState();
}

class _CategoryDetailAndJobWidgetState
    extends State<CategoryDetailAndJobWidget> {
  final _categoryDetailAndJobCubit = sl<CategoryDetailAndJobCubit>();
  UserData? _currentUser;
  bool isSkipSaasOrgID = false;
  CategoryApplicationActionHelper categoryApplicationHelper =
      CategoryApplicationActionHelper();

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
    onRefresh();
  }

  void onRefresh() {
    _categoryDetailAndJobCubit.getCategory(widget.categoryID);
    _categoryDetailAndJobCubit.getWorkListing(widget.categoryID);
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    setState(() {
      _currentUser = spUtil?.getUserData();
    });
    if (spUtil!.getSaasOrgID().isNullOrEmpty) {
      isSkipSaasOrgID = true;
    }
    if(widget.openNotifyBottomSheet == true) {
      _categoryDetailAndJobCubit.createApplicationInNotifyStatus(widget.categoryID, _currentUser?.id ?? -1);
      spUtil.putNotifyCategoryId(-1);
    }
  }

  void subscribeUIStatus() {
    _categoryDetailAndJobCubit.uiStatus.listen(
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
          case Event.success:
            _onApplicationActionTapped(
                _categoryDetailAndJobCubit.workApplicationEntityValue,
                _categoryDetailAndJobCubit
                        .workApplicationEntityValue.pendingAction ??
                    ActionData());
            break;
          case Event.selected:
            sl<CategoryApplicationDetailsCubit>().getApplicationAndExecution(
                _currentUser!, widget.categoryApplication!, isSkipSaasOrgID);
            break;
          case Event.created:
            onRefresh();
            showNotifiedSooBottomSheet(context);
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
      topPadding: Dimens.padding_16,
      bottomPadding: 0,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
              isCollapsable: true,
              isShareVisible: true,
              title: '',
              onShareTap: () {
                onShareClicked(widget.categoryID);
              },
            ),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        0,
        0,
        0,
        Dimens.padding_36,
      ),
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: StreamBuilder<Category>(
          stream: _categoryDetailAndJobCubit.category,
          builder: (context, category) {
            if (category.hasData) {
              return InternetSensitive(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                Dimens.padding_24,
                                Dimens.padding_24,
                                Dimens.padding_24,
                                Dimens.padding_24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      buildCategoryIcon(category.data!),
                                      const SizedBox(width: Dimens.margin_16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              category.data?.name ?? '',
                                              style: context
                                                  .textTheme.bodyText1Bold
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            const SizedBox(
                                                height: Dimens.margin_8),
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimens.radius_4),
                                                    border: Border.all(
                                                      color: (category.data
                                                                      ?.listingsCount ??
                                                                  0) >
                                                              0
                                                          ? AppColors.success200
                                                          : AppColors.error200,
                                                      width: Dimens.border_1,
                                                    ),
                                                    color: (category.data
                                                                    ?.listingsCount ??
                                                                0) >
                                                            0
                                                        ? AppColors.success100
                                                        : AppColors.error100,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                      Dimens.margin_4),
                                                  child: Text(
                                                    '${category.data?.listingsCount} ${'jobs'.tr}',
                                                    style: context
                                                        .textTheme.labelSmall
                                                        ?.copyWith(
                                                            color: (category.data
                                                                            ?.listingsCount ??
                                                                        0) >
                                                                    0
                                                                ? AppColors
                                                                    .success400
                                                                : AppColors
                                                                    .error400),
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width: Dimens.margin_8),
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                      Dimens.margin_4),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimens.radius_4),
                                                    color: AppColors.primary50,
                                                  ),
                                                  child: Text(
                                                    '${category.data?.categoryType?.replaceAll('_', ' ').toCapitalized()}',
                                                    style: context
                                                        .textTheme.caption
                                                        ?.copyWith(
                                                            color: AppColors
                                                                .primaryMain),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        Dimens.padding_16,
                                        Dimens.padding_16,
                                        Dimens.padding_16,
                                        0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: '${'basic_req'.tr}: ',
                                              style: context.textTheme.bodyText2
                                                  ?.copyWith(
                                                      color: AppColors
                                                          .backgroundGrey800,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                          TextSpan(
                                              text:
                                                  category.data?.requirements ??
                                                      '',
                                              style: context.textTheme.bodyText2
                                                  ?.copyWith(
                                                      color: AppColors
                                                          .backgroundGrey800)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, Dimens.padding_16, 0, 0),
                                          child: Text(
                                            '${category.data?.potentialEarning?.getEarningText()}',
                                            style: context
                                                .textTheme.bodyText1Bold
                                                ?.copyWith(
                                                    color: AppColors
                                                        .backgroundGrey900),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                          visible: widget.categoryApplication !=
                                              null,
                                          child:
                                              buildAppliedSatusWidget(context)),
                                    ],
                                  ),
                                  const SizedBox(height: Dimens.margin_16),
                                  HDivider(),
                                  const SizedBox(height: Dimens.margin_16),
                                  buildDescriptionWidget(category.data!),
                                  const SizedBox(height: Dimens.margin_12),
                                  buildViewMoreText(),
                                ],
                              ),
                            ),
                            Container(
                                padding: const EdgeInsets.fromLTRB(
                                  Dimens.padding_16,
                                  Dimens.padding_24,
                                  Dimens.padding_16,
                                  Dimens.padding_24,
                                ),
                                color: AppColors.backgroundGrey300,
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildAvailableJobText(category.data),
                                    const SizedBox(height: Dimens.margin_16),
                                    if ((category.data?.listingsCount ?? 0) >
                                        0) ...[
                                      buildWorkListWidget(),
                                    ] else ...[
                                      if (widget.categoryApplication !=
                                          null) ...[
                                        buildSitBackAndRelaxWidget(),
                                      ] else ...[
                                        buildNotifyMeWidget()
                                      ]
                                    ]
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ),
                    buildFillApplicationFormOrGoToOfficeBottomWidgets(
                        category.data),
                  ],
                ),
              );
            } else {
              return const SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Dimens.padding_24,
                    Dimens.padding_16,
                    Dimens.padding_24,
                    Dimens.padding_24,
                  ),
                  child: Column(
                    children: [
                      CategoryShimmerTile(),
                      SizedBox(height: Dimens.margin_16),
                      ShimmerWidget.rectangular(height: Dimens.margin_228),
                      SizedBox(height: Dimens.margin_16),
                      ShimmerWidget.rectangular(height: Dimens.margin_228),
                    ],
                  ),
                ),
              );
            }
          }),
    );
  }

  Widget buildWorkListWidget() {
    return StreamBuilder<List<Worklistings>?>(
      stream: _categoryDetailAndJobCubit.workListingStream,
      builder: (context, workList) {
        if (workList.hasData &&
            workList.data != null &&
            workList.data!.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 0),
            itemCount: workList.data?.length,
            itemBuilder: (_, i) {
              return WorkListTile(workList.data![i], i, _openWorkListingWidget,
                  _onSalaryDetailTap, _onApplicationActionTapped,_onCheckEligibilityTap);
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }



  _onApplicationActionTapped(
      WorkApplicationEntity workApplicationEntity, ActionData pendingAction) {
    workApplicationEntity.fromRoute = MRouter.categoryDetailAndJobWidget;
    categoryApplicationHelper.onApplicationActionTapped(
        context,
        workApplicationEntity,
        pendingAction,
        _currentUser,
        (UserData? currentUser, WorkApplicationEntity workApplicationEntity) {
      executionApplicationEvent(currentUser, workApplicationEntity);
    }, onRefresh);
  }

  void executionApplicationEvent(
      UserData? currentUser, WorkApplicationEntity workApplicationEntity) {
    _categoryDetailAndJobCubit.executeApplicationEvent(
        currentUser!.id!,
        workApplicationEntity.workListingId!,
        workApplicationEntity.id!,
        workApplicationEntity.pendingAction!.actionKey!);
  }

  void _openWorkListingWidget(int index, Worklistings workListings) async {
    MRouter.pushNamed(MRouter.workListingDetailsWidget,
        arguments:
            WorkListingDetailsArguments(workListings.id?.toString() ?? '-1'));
  }

  void _onSalaryDetailTap(int index, Worklistings workListings) async {
    showSalaryBottomSheet(context, workListings, () {
      MRouter.pushNamed(MRouter.workListingDetailsWidget,
          arguments:
              WorkListingDetailsArguments(workListings.id?.toString() ?? '-1'));
    });
  }

  _onCheckEligibilityTap(
      int? categoryApplicationId, int? workListingId, int? categoryId) async {
    await eligibilityBottomSheet(
        Get.context!, categoryApplicationId, workListingId, categoryId, (List<ApplicationAnswers>? applicationAnswers,int? categoryId) async {
      EligiblityData eligiblityData = EligiblityData(
          applicationAnswers: applicationAnswers,
          categoryId: categoryId);
      MRouter.pop(null);
      bool? value = await MRouter.pushNamed(MRouter.applicationResultWidget,
          arguments: eligiblityData);
      if(value ?? false)
      {
        onRefresh();
      }
    });
  }

  Widget buildCategoryIcon(Category category) {
    String url = category.icon ?? '';
    return NetworkImageLoader(
      url: url,
      width: Dimens.imageWidth_48,
      height: Dimens.imageHeight_48,
      filterQuality: FilterQuality.high,
      fit: BoxFit.cover,
    );
  }

  Widget buildAppliedSatusWidget(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/tick-circle.svg',
          color: AppColors.success400,
        ),
        const SizedBox(
          width: Dimens.padding_4,
        ),
        Text('applied'.tr,
            style: context.textTheme.bodyMedium
                ?.copyWith(color: AppColors.success400)),
      ],
    );
  }

  Widget buildDescriptionWidget(Category category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'description'.tr,
          style: context.textTheme.bodyText2SemiBold,
        ),
        const SizedBox(height: Dimens.margin_16),
        Html(
          data: category.description ?? '',
          style: {
            "body": Style(
              maxLines: 3,
              textOverflow: TextOverflow.ellipsis,
            ),
          },
        ),
      ],
    );
  }

  Widget buildViewMoreText() {
    return MyInkWell(
      onTap: () {
        MRouter.pushNamed(MRouter.categoryDetailsWidget, arguments: {
          'category_id': widget.categoryID,
          'category_application': widget.categoryApplication
        });
      },
      child: Text('view_more'.tr,
          style: context.textTheme.bodyText2
              ?.copyWith(color: AppColors.primaryMain)),
    );
  }

  Widget buildAvailableJobText(Category? category) {
    return Text('${'available_job'.tr} (${category?.listingsCount})',
        style: context.textTheme.bodyText1SemiBold
            ?.copyWith(color: AppColors.backgroundBlack));
  }

  Widget buildFillApplicationFormOrGoToOfficeBottomWidgets(Category? category) {
    return StreamBuilder<UIStatus>(
        stream: _categoryDetailAndJobCubit.isAlreadyApplied,
        builder: (context, isAlreadyApplied) {
          if (_currentUser == null) {
            if ((category?.listingsCount ?? 0) > 0) {
              return buildLoginToApplyButton();
            } else {
              return buildNotifyMeButton();
            }
          } else if (isAlreadyApplied.hasData &&
              isAlreadyApplied.data?.event == Event.success) {
            return buildGoToOfficeButton();
          } else if (isAlreadyApplied.hasData &&
              isAlreadyApplied.data?.event == Event.failed) {
            return Column(
              children: [
                if ((category?.listingsCount ?? 0) == 0) ...[
                  buildNotifyMeButton(),
                ] else ...[
                  buildHintTextWidget(),
                  buildFillApplicationFormButton(),
                ]
              ],
            );
          } else {
            return const Padding(
              padding: EdgeInsets.fromLTRB(Dimens.padding_24, Dimens.padding_24,
                  Dimens.padding_24, Dimens.padding_24),
              child: Column(
                children: [
                  ShimmerWidget.rectangular(height: Dimens.margin_8),
                  SizedBox(height: Dimens.margin_8),
                  ShimmerWidget.rectangular(height: Dimens.margin_8),
                  SizedBox(height: Dimens.margin_8),
                  ShimmerWidget.rectangular(height: Dimens.imageHeight_48),
                ],
              ),
            );
          }
        });
  }

  Widget buildHintTextWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.padding_16, Dimens.padding_16, 0),
      child: Text('in_order_to_view_available_jobs'.tr,
          textAlign: TextAlign.center, style: context.textTheme.bodyText2),
    );
  }

  Widget buildNotifyMeButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          Dimens.padding_24,
          Dimens.padding_16,
          Dimens.padding_24,
          foundation.defaultTargetPlatform == TargetPlatform.iOS
              ? Dimens.padding_16
              : 0),
      child: RaisedRectButton(
        svgIcon: 'assets/images/ic_notification.svg',
        text: 'notify_me'.tr,
        onPressed: () async {
          if(_currentUser != null) {
            //notify api call
            _categoryDetailAndJobCubit.createApplicationInNotifyStatus(widget.categoryID, _currentUser?.id ?? -1);
          } else {
            //manage login flow
            SPUtil? spUtil = await SPUtil.getInstance();
            spUtil?.putNotifyCategoryId(widget.categoryID);
            MRouter.pushNamedAndRemoveUntil(MRouter.phoneVerificationWidget);
          }
        },
      ),
    );
  }

  Widget buildFillApplicationFormButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          Dimens.padding_16,
          Dimens.padding_16,
          Dimens.padding_16,
          foundation.defaultTargetPlatform == TargetPlatform.iOS
              ? Dimens.padding_16
              : 0),
      child: RaisedRectButton(
        text: 'fill_application_form'.tr,
        onPressed: () {
          LoggingData loggingData = LoggingData(
              event: LoggingEvents.categoryApplyButtonClicked,
              otherProperty: {
                Constants.categoryId: widget.categoryID.toString()
              });
          openCategoryQuestionsWidget();
        },
      ),
    );
  }

  void openCategoryQuestionsWidget() async {
    Map? map = await MRouter.pushNamedWithResult(
        context,
        CategoryQuestionsWidget(
            widget.categoryID,
            _categoryDetailAndJobCubit
                .getCategoryQuestions(_currentUser?.userProfile?.userId),
            MRouter.categoryDetailAndJobWidget),
        MRouter.categoryQuestionsWidget);
    bool? success = map?[Constants.success];
    if (success != null && success) {
      _categoryDetailAndJobCubit
          .changeIsAlreadyApplied(UIStatus(event: Event.success));
    }
  }

  Widget buildGoToOfficeButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          Dimens.padding_24,
          Dimens.padding_16,
          Dimens.padding_24,
          foundation.defaultTargetPlatform == TargetPlatform.iOS
              ? Dimens.padding_16
              : 0),
      child: RaisedRectButton(
        text: 'go_to_office'.tr,
        onPressed: () {
          LoggingData loggingData = LoggingData(
              event: LoggingEvents.goToOfficeButtonClicked,
              otherProperty: {
                Constants.categoryId: widget.categoryID.toString()
              });
          MRouter.pushNamedAndRemoveUntil(MRouter.officeWidget);
        },
      ),
    );
  }

  Widget buildLoginToApplyButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          Dimens.padding_24,
          Dimens.padding_16,
          Dimens.padding_24,
          foundation.defaultTargetPlatform == TargetPlatform.iOS
              ? Dimens.padding_16
              : 0),
      child: RaisedRectButton(
        text: 'login_to_apply'.tr,
        onPressed: () {
          MRouter.pushNamed(MRouter.phoneVerificationWidget);
        },
      ),
    );
  }

  void onShareClicked(int categoryID) async {
    String url = "";
    String? referalCode = _currentUser?.referralCode;
    FlavorCubit flavorCubit = context.read<FlavorCubit>();
    if (flavorCubit.flavorConfig.appFlavor != AppFlavor.production) {
      url = "https://www.awigntest.com/categories/${categoryID}";
    } else {
      url = "https://www.awign.com/categories/$categoryID";
    }
    if (referalCode != null) {
      url += "?ref=$referalCode";
    } else {
      url += "";
    }
    await Share.share(url);
  }

  Widget buildSitBackAndRelaxWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimens.padding_24),
        child: Column(
          children: [
            SvgPicture.asset('assets/images/notified_relax.svg'),
            Padding(
              padding: const EdgeInsets.all(Dimens.margin_24),
              child: Text(
                'sit_back_and_relax'.tr,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildNotifyMeWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimens.padding_24),
        child: Column(
          children: [
            SvgPicture.asset('assets/images/stay_updated.svg'),
            const SizedBox(
              height: Dimens.margin_36,
            ),
            Text(
              'stay_updated'.tr,
              style: const TextStyle(
                  color: AppColors.primaryMain,
                  fontSize: Dimens.font_18,
                  fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimens.margin_24),
              child: Text(
                'click_on_notify_me_and_stay_updated_for_new_opportunities'.tr,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
