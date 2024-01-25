import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/ui_status.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/data/remote/capture_event/capture_event_helper.dart';
import 'package:awign/workforce/core/data/remote/capture_event/clavertap_data.dart';
import 'package:awign/workforce/core/data/remote/clevertap/clevertap_helper.dart';
import 'package:awign/workforce/core/data/remote/clevertap/user_property.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/helper.dart';
import 'package:awign/workforce/core/widget/buttons/raised_rect_button.dart';
import 'package:awign/workforce/core/widget/common/desktop_coming_soon_widget.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/network_sensitive/internet_sensitive.dart';
import 'package:awign/workforce/core/widget/scaffold/app_scaffold.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/more/feature/campus_ambassador/cubit/campus_ambassador_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class CampusAmbassadorWidget extends StatefulWidget {
  const CampusAmbassadorWidget({Key? key}) : super(key: key);

  @override
  State<CampusAmbassadorWidget> createState() => _CampusAmbassadorWidgetState();
}

class _CampusAmbassadorWidgetState extends State<CampusAmbassadorWidget> {
  final _campusAmbassadorCubit = sl<CampusAmbassadorCubit>();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  UserData? _currentUser;
  Color color = AppColors.primaryMain;

  @override
  void initState() {
    super.initState();
    subscribeUIStatus();
    getCurrentUser();
  }

  void subscribeUIStatus() {
    _campusAmbassadorCubit.uiStatus.listen(
      (uiStatus) async {
        switch (uiStatus.event) {
          case Event.success:
            Map<String, dynamic> properties =
                await UserProperty.getUserProperty(_currentUser);
            ClevertapData clevertapData = ClevertapData(
                eventName: ClevertapHelper.campusAmbassadorSubmit,
                properties: properties);
            CaptureEventHelper.captureEvent(clevertapData: clevertapData);
            alertDialog();
            break;
          case Event.none:
            break;
        }
      },
    );
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
    _collegeController.text =
        _currentUser!.userProfile!.education!.collegeName ?? '';
    _mobileController.text = _currentUser!.mobileNumber ?? '';
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
        topPadding: 0,
        body: Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(
              color: AppColors.backgroundGrey700,
            ),
            backgroundColor: AppColors.backgroundWhite,
          ),
          backgroundColor: AppColors.backgroundWhite,
          body: buildBody(),
        ));
  }

  Widget buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
      ),
      child: StreamBuilder<UIStatus>(
          stream: _campusAmbassadorCubit.uiStatus,
          builder: (context, uiStatus) {
            if (uiStatus.hasData && uiStatus.data!.isOnScreenLoading) {
              return AppCircularProgressIndicator();
            } else {
              return InternetSensitive(
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              Dimens.padding_16,
                              Dimens.padding_24,
                              Dimens.padding_16,
                              Dimens.padding_16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/images/ic_campus.svg',
                              ),
                              const SizedBox(height: Dimens.margin_12),
                              Text(
                                'Become',
                                style: Get.context?.textTheme.labelSmall
                                    ?.copyWith(
                                        color: AppColors.black,
                                        fontSize: Dimens.font_20,
                                        fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: Dimens.margin_12),
                              Text(
                                'Campus Ambassador',
                                style: Get.context?.textTheme.bodyText1Bold
                                    ?.copyWith(
                                        color: AppColors.black,
                                        fontSize: Dimens.font_28),
                              ),
                              const SizedBox(height: Dimens.margin_20),
                              Text(
                                'campus_description'.tr,
                                style: Get.context?.textTheme.bodyMedium
                                    ?.copyWith(
                                        color: AppColors.backgroundGrey800),
                              ),
                              const SizedBox(height: Dimens.margin_24),
                              Text(
                                'How it works',
                                style: Get.context?.textTheme.labelSmall
                                    ?.copyWith(
                                        color: AppColors.black,
                                        fontSize: Dimens.font_20,
                                        fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: Dimens.margin_24),
                              buildHowAmbassadorWorks(
                                  'assets/images/ic_icons_natural_user_interface.svg',
                                  'apply_campus_ambassador'.tr),
                              buildHowAmbassadorWorks(
                                  'assets/images/ic_icons_natural_user_interface.svg',
                                  'ambassador_task_description'.tr),
                              buildHowAmbassadorWorks(
                                  'assets/images/ic_icons_winner.svg',
                                  'ambassador_reward_desciption'.tr),
                              const SizedBox(height: Dimens.margin_24),
                              Center(
                                child: Text(
                                  'Why Campus',
                                  style: Get.context?.textTheme.labelSmall
                                      ?.copyWith(
                                          color: AppColors.black,
                                          fontSize: Dimens.font_16,
                                          fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(height: Dimens.margin_4),
                              Center(
                                child: Text(
                                  'Ambassador?',
                                  style: Get.context?.textTheme.bodyText1Bold
                                      ?.copyWith(
                                          color: AppColors.black,
                                          fontSize: Dimens.font_20),
                                ),
                              ),
                              const SizedBox(height: Dimens.margin_12),
                              Center(
                                child: Text(
                                  'why_ambassador_desciption'.tr,
                                  textAlign: TextAlign.center,
                                  style: Get.context?.textTheme.labelLarge
                                      ?.copyWith(
                                          color: AppColors.backgroundGrey800,
                                          fontSize: Dimens.font_14,
                                          fontWeight: FontWeight.w400),
                                ),
                              ),
                              const SizedBox(height: Dimens.margin_24),
                              SizedBox(
                                height: 350,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  children: [
                                    buildCampusAmbassador(
                                        'assets/images/ic_graph.svg',
                                        'Grow with us',
                                        'grow_with_us'.tr),
                                    const SizedBox(width: Dimens.margin_12),
                                    buildCampusAmbassador(
                                        'assets/images/ic_student_male.svg',
                                        'Be that guy',
                                        'be_that_guy'.tr),
                                    const SizedBox(width: Dimens.margin_12),
                                    buildCampusAmbassador(
                                        'assets/images/ic_intelligence.svg',
                                        'Earn as you learn',
                                        'earn_as_you_learn'.tr),
                                    const SizedBox(width: Dimens.margin_12),
                                    buildCampusAmbassador(
                                        'assets/images/ic_gift.svg',
                                        'Reward',
                                        'reward'.tr),
                                  ],
                                ),
                              ),
                              const SizedBox(height: Dimens.margin_32),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(
                              Dimens.padding_16,
                              Dimens.padding_24,
                              Dimens.padding_16,
                              Dimens.padding_16),
                          color: AppColors.backgroundLight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Responsibilities of a Campus Ambassador',
                                style: Get.context?.textTheme.labelSmall
                                    ?.copyWith(
                                        color: AppColors.black,
                                        fontSize: Dimens.font_16,
                                        fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: Dimens.margin_12),
                              Center(
                                child: Text(
                                  'Ambassador?',
                                  style: Get.context?.textTheme.bodyText1Bold
                                      ?.copyWith(
                                          color: AppColors.black,
                                          fontSize: Dimens.font_20),
                                ),
                              ),
                              const SizedBox(height: Dimens.margin_12),
                              buildResponsiblitiesofCampus(
                                  'assets/images/ic_megaphone.svg',
                                  'Branding',
                                  'branding'.tr),
                              buildResponsiblitiesofCampus(
                                  'assets/images/ic_group_man.svg',
                                  'Registration',
                                  'registration'.tr),
                              buildResponsiblitiesofCampus(
                                  'assets/images/ic_icons_8_tinder.svg',
                                  'Social Media',
                                  'social_media'.tr),
                              buildResponsiblitiesofCampus(
                                  'assets/images/ic_mailing.svg',
                                  'Email',
                                  'email_ambassador'.tr),
                              buildResponsiblitiesofCampus(
                                  'assets/images/ic_icons_resume.svg',
                                  'Poster',
                                  'poster'.tr),
                              buildResponsiblitiesofCampus(
                                  'assets/images/ic_icons_crowd.svg',
                                  'Networking',
                                  'networking'.tr),
                              buildResponsiblitiesofCampus(
                                  'assets/images/ic_idea.svg',
                                  'Innovate',
                                  'innovate'.tr),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimens.margin_24),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              Dimens.padding_16,
                              Dimens.padding_24,
                              Dimens.padding_16,
                              Dimens.padding_16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stipend',
                                style: Get.context?.textTheme.labelSmall
                                    ?.copyWith(
                                        color: AppColors.black,
                                        fontSize: Dimens.font_16,
                                        fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Structure',
                                style: Get.context?.textTheme.bodyText1Bold
                                    ?.copyWith(
                                        color: AppColors.black,
                                        fontSize: Dimens.font_20),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimens.margin_24),
                        Image.asset('assets/images/stipend_table.png'),
                        const SizedBox(height: Dimens.margin_36),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              Dimens.padding_16,
                              Dimens.padding_24,
                              Dimens.padding_16,
                              Dimens.padding_16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Perks',
                                style: Get.context?.textTheme.bodyText1Bold
                                    ?.copyWith(
                                        color: AppColors.black,
                                        fontSize: Dimens.font_20),
                              ),
                              Text(
                                'perk_description'.tr,
                                style: Get.context?.textTheme.labelLarge
                                    ?.copyWith(
                                        color: AppColors.backgroundGrey800,
                                        fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: Dimens.margin_24),
                              buildPerk(
                                  AppColors.success300,
                                  'Stipend & certificate',
                                  'stipend_and_cetificate_desc'.tr),
                              buildPerk(
                                  AppColors.primaryMain,
                                  'Full-time paid internship',
                                  'full_time_paid_internship_desc'.tr),
                              buildPerk(AppColors.warning300, 'Merchandise',
                                  'merchandise_desc'.tr),
                              buildPerk(AppColors.warning200, 'Credit Yourself',
                                  'credit_yourself_desc'.tr),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimens.margin_24),
                        Container(
                          padding: const EdgeInsets.fromLTRB(
                              Dimens.padding_16,
                              Dimens.padding_24,
                              Dimens.padding_16,
                              Dimens.padding_16),
                          color: AppColors.backgroundLight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'disqualification'.tr,
                                style: Get.context?.textTheme.labelSmall
                                    ?.copyWith(
                                        color: AppColors.error300,
                                        fontSize: Dimens.font_16,
                                        fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: Dimens.margin_24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '3_golden_roles'.tr,
                                    style: context.textTheme.bodyText1
                                        ?.copyWith(
                                            color: AppColors.primaryMain,
                                            fontSize: Dimens.font_14,
                                            fontStyle: FontStyle.italic),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '_3_golden_rules_don_t_lie_don_t_cheat_amp_don_t_give_up'
                                          .tr,
                                      style: context.textTheme.bodyText1
                                          ?.copyWith(
                                              color:
                                                  AppColors.backgroundGrey800,
                                              fontSize: Dimens.font_14),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: Dimens.margin_24),
                              Text(
                                'remember_you_will_be_disqualified_if'.tr,
                                style: context.textTheme.bodyText1?.copyWith(
                                    color: AppColors.black,
                                    fontSize: Dimens.font_14),
                              ),
                              const SizedBox(height: Dimens.margin_24),
                              buildDisqualificationCases(
                                  'invalid_or_forceful_application'.tr,
                                  'any_application_is_found_to_be_fake_or_invalid_or_if_any_applicant_has_been_forced_to_apply_for_the_internship_which_is_clearly_out_of_their_interest'
                                      .tr),
                              buildDisqualificationCases(
                                  'targets_not_met'.tr,
                                  'you_are_unable_to_reach_a_minimum_of_15_applications_in_first_3_days_of_commencement_of_your_duties'
                                      .tr),
                              buildDisqualificationCases(
                                  'forged_documents'.tr,
                                  'it_was_found_that_you_have_applied_on_someone_else_s_behalf'
                                      .tr),
                              buildDisqualificationCases(
                                  'irrelevant'.tr,
                                  'it_was_found_that_you_forced_or_convinced_someone_to_apply_for_internship_who_was_not_interested'
                                      .tr),
                              const SizedBox(height: Dimens.margin_12),
                              Text(
                                'disqualification_will_lead_to_cancellation_of_both_certificate_as_well_as_stipend'
                                    .tr,
                                style: context.textTheme.bodyText1?.copyWith(
                                    color: AppColors.error300,
                                    fontSize: Dimens.font_14,
                                    fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: Dimens.margin_24),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              Dimens.padding_16,
                              Dimens.padding_24,
                              Dimens.padding_16,
                              Dimens.padding_16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'apply_for_campus_ambassador'.tr,
                                  style: Get.context?.textTheme.bodyText1Bold
                                      ?.copyWith(
                                          color: AppColors.black,
                                          fontSize: Dimens.font_20),
                                ),
                                const SizedBox(height: Dimens.margin_24),
                                buildCampusAmbassadorTextField(
                                    'college'.tr, _collegeController),
                                const SizedBox(height: Dimens.margin_24),
                                buildCampusAmbassadorTextField(
                                    'mobile_number'.tr, _mobileController),
                                const SizedBox(height: Dimens.margin_24),
                                RaisedRectButton(
                                  backgroundColor: color,
                                  text: 'apply_now'.tr,
                                  fontSize: Dimens.font_16,
                                  onPressed: () async {
                                    await _campusAmbassadorCubit
                                        .createCampusAmbassador(
                                            _mobileController.text,
                                            _currentUser!.userProfile!
                                                    .education!.id ??
                                                -1,
                                            _currentUser!.referralCode ??
                                                _currentUser!
                                                    .userProfile!.referralCode!,
                                            _currentUser!.id!);
                                  },
                                )
                              ]),
                        )
                      ]),
                ),
              );
            }
          }),
    );
  }

  Widget buildCampusAmbassadorTextField(
      String name, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: context.textTheme.bodyText1Bold
              ?.copyWith(color: AppColors.black, fontSize: Dimens.font_14),
        ),
        const SizedBox(height: Dimens.margin_8),
        TextField(
          style: context.textTheme.bodyText1,
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(Dimens.padding_16,
                Dimens.padding_8, Dimens.padding_16, Dimens.padding_8),
            fillColor: context.theme.textFieldBackgroundColor,
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_8)),
              borderSide: BorderSide(color: AppColors.backgroundGrey400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  const BorderRadius.all(Radius.circular(Dimens.radius_8)),
              borderSide:
                  BorderSide(color: context.theme.textFieldBackgroundColor),
            ),
          ),
        )
      ],
    );
  }

  Widget buildDisqualificationCases(String name, String Description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: Get.context?.textTheme.bodyText1Bold
              ?.copyWith(color: AppColors.black, fontSize: Dimens.font_18),
        ),
        Text(
          Description,
          style: Get.context?.textTheme.labelLarge?.copyWith(
              color: AppColors.backgroundGrey800,
              height: 1.5,
              fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: Dimens.margin_24),
      ],
    );
  }

  Widget buildPerk(Color color, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 0),
      leading: CircleAvatar(
        radius: Dimens.radius_32,
        backgroundColor: color,
        child: Padding(
          padding: const EdgeInsets.all(Dimens.padding_16), // Border radius
          child: Image.asset('assets/images/ic_icons_8_briefcase.png'),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: Dimens.padding_16),
        child: Text(
          title,
          style: Get.context?.textTheme.labelSmall?.copyWith(
              color: AppColors.black,
              fontSize: Dimens.font_16,
              fontWeight: FontWeight.w500),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Get.context?.textTheme.labelLarge?.copyWith(
            color: AppColors.backgroundGrey800, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget buildHowAmbassadorWorks(String url, String description) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.all(
            Dimens.padding_4,
          ),
          leading: SvgPicture.asset(url),
          title: Padding(
            padding: const EdgeInsets.only(left: Dimens.padding_8),
            child: Text(
              description,
              style: Get.context?.textTheme.labelLarge?.copyWith(
                  color: AppColors.backgroundGrey800,
                  fontSize: Dimens.font_14,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: Dimens.margin_12),
      ],
    );
  }

  Widget buildCampusAmbassador(String url, String name, String description) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radius_8),
      ),
      child: Container(
          width: 250,
          padding: const EdgeInsets.fromLTRB(Dimens.padding_16,
              Dimens.padding_16, Dimens.padding_16, Dimens.padding_16),
          child: Column(
            children: [
              SvgPicture.asset(
                url,
              ),
              const SizedBox(height: Dimens.margin_12),
              Text(
                name,
                style: Get.context?.textTheme.labelSmall?.copyWith(
                    color: AppColors.black,
                    fontSize: Dimens.font_16,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: Dimens.margin_12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Get.context?.textTheme.labelLarge?.copyWith(
                    color: AppColors.backgroundGrey700,
                    fontWeight: FontWeight.w400),
              ),
            ],
          )),
    );
  }

  Widget buildResponsiblitiesofCampus(
      String url, String name, String description) {
    return Column(
      children: [
        SvgPicture.asset(
          url,
        ),
        const SizedBox(height: Dimens.margin_12),
        Text(
          name,
          style: Get.context?.textTheme.labelSmall?.copyWith(
              color: AppColors.black,
              fontSize: Dimens.font_16,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: Dimens.margin_12),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Get.context?.textTheme.bodyMedium
              ?.copyWith(color: AppColors.backgroundGrey900),
        ),
        const SizedBox(height: Dimens.margin_12),
      ],
    );
  }

  void alertDialog() {
    Helper.showAlertDialogWithOnTap(Get.context!, 'application_sent'.tr, () {
      _campusAmbassadorCubit.getCampusAmbassador(_currentUser!.id!);
      MRouter.pushReplacementNamed(MRouter.moreWidget);
    }, textOKBtn: 'okay'.tr);
  }
}
