import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/logging_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_constant.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/file_utils.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/app_bar/default_app_bar.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/circle_avatar/custom_circle_avatar.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/execution_in_house/data/model/execution.dart';
import 'package:awign/workforce/execution_in_house/feature/offer_letter/cubit/offer_letter_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../core/data/local/repository/logging_event/helper/logging_events.dart';
import '../../../../core/data/local/repository/logging_event/helper/logging_section_names.dart';

class OfferLetterWidget extends StatefulWidget {
  final Execution _execution;

  const OfferLetterWidget(this._execution, {Key? key}) : super(key: key);

  @override
  State<OfferLetterWidget> createState() => _OfferLetterWidgetState();
}

class _OfferLetterWidgetState extends State<OfferLetterWidget> {
  final OfferLetterCubit _offerLetterCubit = sl<OfferLetterCubit>();
  UserData? _currentUser;
  late PdfController _pdfController;
  String? pdfURL = '';

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
    if (widget._execution.offerLetterFiles != null) {
      pdfURL = widget._execution
          .offerLetterFiles?[widget._execution.selectedProjectRole]?.pdf?[0];
    }
    if (pdfURL.isNullOrEmpty) {
      Helper.showErrorToast(
          'offer_letter_not_available_please_contact_customer_support'.tr);
    }
    _pdfController = PdfController(
      document: PdfDocument.openData(InternetFile.get(pdfURL ?? '')),
    );
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    Map<String, dynamic> properties = await getEventProperty(widget._execution);
    ClevertapHelper.instance()
        .addCleverTapEvent(ClevertapHelper.offerLetterOpened, properties);
  }

  void subscribeUIStatus() {
    _offerLetterCubit.uiStatus.listen(
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
  void dispose() {
    _pdfController.dispose();
    super.dispose();
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
        physics: const NeverScrollableScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            DefaultAppBar(
              isCollapsable: true,
              // title: widget._execution.projectName ?? '',
              headerWidget: buildHeaderWidget(),
              onDownloadTap: () {
                if (widget._execution.offerLetterFiles != null) {
                  pdfURL = widget
                      ._execution
                      .offerLetterFiles?[widget._execution.selectedProjectRole]
                      ?.pdf?[0];
                  if (pdfURL != null) {
                    FileUtils.downloadFile(context, pdfURL!);
                    LoggingData loggingData = LoggingData(
                        event: LoggingEvents.downloadCtaClickedApp,
                        sectionName: LoggingSectionNames.offerLetter,
                        otherProperty: getProjectProperty(widget._execution));
                    CaptureEventHelper.captureEvent(loggingData: loggingData);
                  }
                }
              },
            ),
          ];
        },
        body: buildBody(),
      ),
    );
  }

  Widget buildHeaderWidget() {
    return Row(
      children: [
        buildIcon(),
        buildTitle(),
      ],
    );
  }

  Widget buildTitle() {
    return Text(
      'Offer Letter',
      style: Get.context?.textTheme.headline6SemiBold
          ?.copyWith(color: AppColors.backgroundWhite),
    );
  }

  Widget buildIcon() {
    if (widget._execution.projectIcon != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding_8),
        child: CustomCircleAvatar(
            url: widget._execution.projectIcon, radius: Dimens.radius_16),
      );
    } else {
      return const SizedBox();
    }
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
            buildPDFWidget(),
            buildSignOfferLetterButton(),
          ],
        ),
      ),
    );
  }

  Widget buildPDFWidget() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.padding_16, 0, Dimens.padding_16, 0),
        child: PdfView(
          controller: _pdfController,
          scrollDirection: Axis.vertical,
          builders: PdfViewBuilders<DefaultBuilderOptions>(
            options: const DefaultBuilderOptions(
              loaderSwitchDuration: Duration(seconds: 1),
            ),
            documentLoaderBuilder: (_) =>
                Center(child: AppCircularProgressIndicator()),
            pageLoaderBuilder: (_) =>
                Center(child: AppCircularProgressIndicator()),
            errorBuilder: (_, error) => Center(
                child: Text(error.toString(), style: Get.textTheme.bodyText1)),
          ),
        ),
      ),
    );
  }

  Widget buildSignOfferLetterButton() {
    if (widget._execution.status == ExecutionStatus.approved) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
            Dimens.margin_16,
            Dimens.margin_16,
            Dimens.margin_16,
            defaultTargetPlatform == TargetPlatform.iOS
                ? Dimens.padding_32
                : Dimens.margin_16),
        child: RaisedRectButton(
          text: 'sign_offer_letter'.tr,
          onPressed: () {
            if (pdfURL.isNullOrEmpty) {
              Helper.showErrorToast(
                  'offer_letter_not_available_please_contact_customer_support'
                      .tr);
            } else {
              MRouter.pushNamed(MRouter.signOfferLetterWidget,
                  arguments: widget._execution);
            }
          },
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Map<String, String> getProjectProperty(Execution execution) {
    Map<String, String> eventProperty = {};
    eventProperty[CleverTapConstant.projectName] = execution.projectName ?? '';
    eventProperty[CleverTapConstant.projectId] = execution.projectId ?? '';
    eventProperty[CleverTapConstant.roleName] =
        execution.selectedProjectRole?.replaceAll('_', ' ') ?? '';
    return eventProperty;
  }

  Future<Map<String, dynamic>> getEventProperty(Execution execution) async {
    Map<String, dynamic> eventProperty = {};
    eventProperty[CleverTapConstant.projectName] = execution.projectName;
    eventProperty[CleverTapConstant.projectId] = execution.projectId;
    eventProperty[CleverTapConstant.roleName] =
        execution.selectedProjectRole?.replaceAll('_', ' ');
    Map<String, dynamic> properties =
        await UserProperty.getUserProperty(_currentUser);
    eventProperty.addAll(properties);
    return eventProperty;
  }
}
