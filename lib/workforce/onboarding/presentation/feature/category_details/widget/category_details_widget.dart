import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/constants.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/divider/v_divider.dart';
import 'package:awign/workforce/core/widget/image_loader/network_image_loader.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/shimmer/shimmer_widget.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_application_response.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_response.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_details/cubit/category_details_cubit.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_listing/widget/tile/category_shimmer_tile.dart';
import 'package:awign/workforce/onboarding/presentation/feature/category_questions/widget/category_questions_widget.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/config/cubit/flavor_cubit.dart';
import '../../../../../core/config/flavor_config.dart';
import '../../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../../core/widget/divider/h_divider.dart';

class CategoryDetailsWidget extends StatefulWidget {
  final int categoryID;
  final CategoryApplication? categoryApplication;
  const CategoryDetailsWidget(this.categoryID,this.categoryApplication,{Key? key}) : super(key: key);

  @override
  _CategoryDetailsWidgetState createState() => _CategoryDetailsWidgetState();
}

class _CategoryDetailsWidgetState extends State<CategoryDetailsWidget> {
  final _categoryDetailsCubit = sl<CategoryDetailsCubit>();
  UserData? _currentUser;
  late Map<String, dynamic> properties;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
    _categoryDetailsCubit.getCategory(widget.categoryID);
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    setState(() {
      _currentUser = spUtil?.getUserData();
    });

    if(_currentUser?.id != null){
      _categoryDetailsCubit.getCategoryApplicationDetails(
          _currentUser!.id.toString(), widget.categoryID);
    }

    properties = await UserProperty.getUserProperty(_currentUser!);
    properties[CleverTapConstant.categoryId] = widget.categoryID;
    ClevertapData clevertapData = ClevertapData(
        eventName: ClevertapHelper.categoryViewed, properties: properties);
    LoggingData loggingData = LoggingData(
        event: LoggingEvents.categoryDetailPageOpen,
        otherProperty: {Constants.categoryId: widget.categoryID.toString()});
    CaptureEventHelper.captureEvent(
        clevertapData: clevertapData, loggingData: loggingData);
  }

  void subscribeUIStatus() {
    _categoryDetailsCubit.uiStatus.listen(
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
      padding: const EdgeInsets.only(bottom: Dimens.padding_40),
      decoration: BoxDecoration(
        color: context.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: StreamBuilder<Category>(
        stream: _categoryDetailsCubit.category,
        builder: (context, category) {
          if (category.hasData) {
            return InternetSensitive(
              child: Column(
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
                                        style: context.textTheme.bodyText1Bold
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: Dimens.margin_8),
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(Dimens.radius_4),
                                              color: AppColors.success100,
                                            ),
                                            padding: const EdgeInsets.all(Dimens.margin_4),
                                            child: Text(
                                              '${category.data?.listingsCount} ${'jobs'.tr}',
                                              style: context.textTheme.labelSmall
                                                  ?.copyWith(
                                                      color: AppColors.success400),
                                            ),
                                          ),
                                          const SizedBox(width: Dimens.margin_8),
                                          Container(
                                            padding: const EdgeInsets.all(Dimens.margin_4),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(Dimens.radius_4),
                                              color: AppColors.primary50,
                                            ),
                                            child: Text(
                                              '${category.data?.categoryType?.replaceAll('_', ' ').toCapitalized()}',
                                              style: context.textTheme.caption
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0, Dimens.padding_16, 0, 0),
                                  child: Text(
                                    '${category.data?.potentialEarning?.getEarningText()}',
                                    style: context.textTheme.bodyText2Medium
                                        ?.copyWith(color: AppColors.backgroundGrey900),
                                  ),
                                ),
                                Visibility(
                                  visible: widget.categoryApplication != null,
                                    child: buildAppliedSatusWidget(context)),
                              ],
                            ),
                            const SizedBox(height: Dimens.margin_16),
                            HDivider(),
                            buildWhoCanApplyWidget(category.data!),
                            buildDescriptionWidget(category.data!),
                            buildRolesAndResponsibilitiesWidget(category.data!),
                            buildWhatYouGetWidget(category.data!),
                            // const HDivider(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  buildFillApplicationFormOrGoToOfficeBottomWidgets(),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimens.padding_24,
                  Dimens.padding_16,
                  Dimens.padding_24,
                  Dimens.padding_24,
                ),
                child: Column(
                  children: const [
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
        },
      ),
    );
  }

  Widget buildAppliedSatusWidget(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/tick-circle.svg',
          color: AppColors.success400,
        ),
        const SizedBox(width: Dimens.padding_4,),
        Text('applied'.tr,
            style: context.textTheme.bodyMedium
                ?.copyWith(color: AppColors.success400)),
      ],
    );
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

  Widget buildWhoCanApplyWidget(Category category) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: AppColors.transparent),
      child: ExpansionTile(
        childrenPadding: const EdgeInsets.symmetric(horizontal: 0),
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        textColor: context.theme.iconColorNormal,
        iconColor: context.theme.iconColorNormal,
        initiallyExpanded: true,
        title: Text(
          'who_can_apply'.tr,
          style: context.textTheme.bodyText2SemiBold,
        ),
        children: <Widget>[
          Html(
            data: category.whoCanApply ?? '',
          ),
        ],
      ),
    );
  }

  Widget buildDescriptionWidget(Category category) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: AppColors.transparent),
      child: ExpansionTile(
        childrenPadding: const EdgeInsets.symmetric(horizontal: 0),
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        textColor: context.theme.iconColorNormal,
        iconColor: context.theme.iconColorNormal,
        initiallyExpanded: true,
        title: Text(
          'description'.tr,
          style: context.textTheme.bodyText2SemiBold,
        ),
        children: <Widget>[
          Html(
            data: category.description ?? '',
          ),
        ],
      ),
    );
  }

  Widget buildRolesAndResponsibilitiesWidget(Category category) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: AppColors.transparent),
      child: ExpansionTile(
        childrenPadding: const EdgeInsets.symmetric(horizontal: 0),
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        textColor: context.theme.iconColorNormal,
        iconColor: context.theme.iconColorNormal,
        initiallyExpanded: true,
        title: Text(
          'roles_and_responsibilities'.tr,
          style: context.textTheme.bodyText2SemiBold,
        ),
        children: <Widget>[
          Html(
            data: category.rolesAndResponsibilities ?? '',
          ),
        ],
      ),
    );
  }

  Widget buildWhatYouGetWidget(Category category) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: AppColors.transparent),
      child: ExpansionTile(
        childrenPadding: const EdgeInsets.symmetric(horizontal: 0),
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        textColor: context.theme.iconColorNormal,
        iconColor: context.theme.iconColorNormal,
        initiallyExpanded: true,
        title: Text(
          'what_you_get'.tr,
          style: context.textTheme.bodyText2SemiBold,
        ),
        children: <Widget>[
          Html(
            data: category.whatYouGet ?? '',
          ),
        ],
      ),
    );
  }

  Widget buildFillApplicationFormOrGoToOfficeBottomWidgets() {
    return StreamBuilder<UIStatus>(
        stream: _categoryDetailsCubit.isAlreadyApplied,
        builder: (context, isAlreadyApplied) {
          if (_currentUser == null) {
            return buildLoginToApplyButton();
          }
          else if (isAlreadyApplied.hasData &&
              isAlreadyApplied.data?.event == Event.success) {
            return buildGoToOfficeButton();
          } else if (isAlreadyApplied.hasData &&
              isAlreadyApplied.data?.event == Event.failed) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                  Dimens.padding_24, Dimens.padding_24, Dimens.padding_24),
              child: Column(
                children: [
                  buildHintTextWidget(),
                  buildFillApplicationFormButton(),
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.padding_24,
                  Dimens.padding_24, Dimens.padding_24, Dimens.padding_24),
              child: Column(
                children: const [
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

  Widget buildHintTextWidget() {
    return Text('in_order_to_view_available_jobs'.tr,
        textAlign: TextAlign.center, style: context.textTheme.bodyText2);
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
          CaptureEventHelper.captureEvent(loggingData: loggingData);
          openCategoryQuestionsWidget();
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
    ClevertapData clevertapData = ClevertapData(
        eventName: ClevertapHelper.categoryShareCta, properties: properties);
    CaptureEventHelper.captureEvent(clevertapData: clevertapData);
  }

  void openCategoryQuestionsWidget() async {
    Map? map = await MRouter.pushNamedWithResult(
        context,
        CategoryQuestionsWidget(
            widget.categoryID,
            _categoryDetailsCubit
                .getCategoryQuestions(_currentUser?.userProfile?.userId),
            MRouter.categoryDetailsWidget),
        MRouter.categoryQuestionsWidget);
    bool? success = map?[Constants.success];
    if (success != null && success) {
      _categoryDetailsCubit
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
          ClevertapData clevertapData = ClevertapData(
              eventName: ClevertapHelper.categoryGoToOffice,
              properties: properties);
          LoggingData loggingData = LoggingData(
              event: LoggingEvents.goToOfficeButtonClicked,
              otherProperty: {
                Constants.categoryId: widget.categoryID.toString()
              });
          CaptureEventHelper.captureEvent(
              clevertapData: clevertapData, loggingData: loggingData);
          MRouter.pushNamedAndRemoveUntil(MRouter.officeWidget);
        },
      ),
    );
  }
}
