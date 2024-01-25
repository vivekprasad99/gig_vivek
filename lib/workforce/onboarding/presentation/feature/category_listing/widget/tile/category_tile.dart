import 'package:awign/workforce/core/extension/string_extension.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/divider/h_divider.dart';
import 'package:awign/workforce/core/widget/image_loader/network_image_loader.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:awign/workforce/onboarding/data/model/category/category_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CategoryTile extends StatelessWidget {
  final int index;
  final Category category;
  final Function(int index, Category category) onViewCategoryTap;
  final Function(int index, Category category) onShareCategoryTap;
  final Function(int index, Category category) onProceedNextTap;
  final Function(int index, int categoryId) onNotifyMeClicked;

  const CategoryTile(
      {Key? key,
      required this.index,
      required this.category,
      required this.onViewCategoryTap,
      required this.onShareCategoryTap,
      required this.onProceedNextTap,
      required this.onNotifyMeClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Dimens.padding_16, 0, 0),
      child: Card(
          elevation: Dimens.elevation_2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radius_8),
          ),
          child: Stack(
            children: [
              if (category.highlightTag?.name != null) buildFeaturedTag(),
              Container(
                padding: EdgeInsets.fromLTRB(
                    0,
                    category.highlightTag?.name != null
                        ? Dimens.padding_24
                        : Dimens.padding_16,
                    0,
                    Dimens.padding_8),
                child: Column(
                  children: [
                    MyInkWell(
                      onTap: () {
                        onViewCategoryTap(index, category);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: Dimens.margin_16),
                              buildCategoryIcon(),
                              const SizedBox(width: Dimens.margin_16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(category.name ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.bodyText1Bold
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors
                                                    .backgroundGrey900)),
                                    const SizedBox(height: Dimens.margin_8),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimens.radius_4),
                                            border: Border.all(
                                              color: (category.listingsCount ??
                                                          0) >
                                                      0
                                                  ? AppColors.success200
                                                  : AppColors.error200,
                                              width: Dimens.border_1,
                                            ),
                                            color:
                                                (category.listingsCount ?? 0) >
                                                        0
                                                    ? AppColors.success100
                                                    : AppColors.error100,
                                          ),
                                          padding: const EdgeInsets.all(
                                              Dimens.margin_4),
                                          child: Text(
                                              '${category.listingsCount} ${'jobs'.tr}',
                                              style: context.textTheme.caption
                                                  ?.copyWith(
                                                      color:
                                                          (category.listingsCount ??
                                                                      0) >
                                                                  0
                                                              ? AppColors
                                                                  .success400
                                                              : AppColors
                                                                  .error400)),
                                        ),
                                        const SizedBox(width: Dimens.margin_8),
                                        Container(
                                          padding: const EdgeInsets.all(
                                              Dimens.margin_4),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimens.radius_4),
                                            border: Border.all(
                                              color: AppColors.primary300,
                                              width: Dimens.border_1,
                                            ),
                                            color: AppColors.primary50,
                                          ),
                                          child: Text(
                                              '${category.categoryType?.replaceAll('_', ' ').toCapitalized()}',
                                              style: context.textTheme.caption
                                                  ?.copyWith(
                                                      color: AppColors
                                                          .primaryMain)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: Dimens.margin_16),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                Dimens.padding_16,
                                Dimens.padding_16,
                                Dimens.padding_16,
                                0),
                            child: RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              // TextOverflow.clip // TextOverflow.fade
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      text: '${'basic_req'.tr}: ',
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                              color:
                                                  AppColors.backgroundGrey800,
                                              fontWeight: FontWeight.w600)),
                                  TextSpan(
                                      text: category.requirements ?? '',
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                              color:
                                                  AppColors.backgroundGrey800)),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                Dimens.padding_16,
                                Dimens.padding_16,
                                Dimens.padding_16,
                                Dimens.padding_8),
                            child: Text(
                                '${category.potentialEarning?.getEarningText()}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.backgroundGrey900)),
                          ),
                        ],
                      ),
                    ),
                    if (category.categoryApplication != null &&
                        category.categoryApplication?.status == "applied") ...[
                      Padding(
                        padding: const EdgeInsets.all(Dimens.padding_8),
                        child: Column(
                          children: [
                            HDivider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildAppliedStatusWidget(context),
                                buildProceedToNextStepWidget(context),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else if (category.categoryApplication != null &&
                        category.categoryApplication?.status == "notify") ...[
                      Padding(
                        padding: const EdgeInsets.all(Dimens.padding_8),
                        child: Column(
                          children: [
                            HDivider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildNotifiedText(context),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else if (category.categoryApplication == null &&
                        category.listingsCount == 0) ...[
                      Padding(
                        padding: const EdgeInsets.all(Dimens.padding_8),
                        child: Column(
                          children: [
                            HDivider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildNotifyText(context),
                                const SizedBox(
                                  width: Dimens.btnHeight_32,
                                ),
                                buildNotifyMeIcon(context),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget buildFeaturedTag() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        decoration: BoxDecoration(
          color: category.getTagColor(),
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(Dimens.radius_40),
              topRight: Radius.circular(Dimens.radius_8)),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 24, top: 8, right: 16, bottom: 8),
          child: Text(category.highlightTag?.name ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white,
              )),
        ),
      ),
    );
  }

  Widget buildNotifyMeIcon(BuildContext context) {
    return MyInkWell(
      onTap: () {
        onNotifyMeClicked(index, category.id ?? -1);
      },
      child: Row(
        children: [
          // const Icon(Icons.notifications_rounded),
          SvgPicture.asset(
            'assets/images/ic_notification.svg',
            color: AppColors.primaryMain,
            height: Dimens.iconSize_16,
          ),
          Text('notify_me'.tr,
              style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryMain, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget buildNotifyText(BuildContext context) {
    return Expanded(
      child: Text('notify_me_text'.tr,
          style: context.textTheme.bodyMedium
              ?.copyWith(color: AppColors.backgroundGrey800)),
    );
  }

  Widget buildCategoryIcon() {
    String url = category.icon ?? '';
    return NetworkImageLoader(
      url: url,
      width: Dimens.imageWidth_48,
      height: Dimens.imageHeight_48,
      filterQuality: FilterQuality.high,
      fit: BoxFit.cover,
    );
  }

  Widget buildAppliedStatusWidget(BuildContext context) {
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

  Widget buildProceedToNextStepWidget(BuildContext context) {
    return MyInkWell(
      onTap: () {
        onProceedNextTap(index, category);
      },
      child: Row(
        children: [
          Text('proceed_next_step'.tr,
              style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryMain, fontWeight: FontWeight.w500)),
          const SizedBox(
            width: Dimens.padding_4,
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primaryMain,
            size: Dimens.padding_12,
          ),
        ],
      ),
    );
  }

  Widget buildNotifiedText(BuildContext context) {
    return Expanded(
        child: Text('notified_text'.tr,
            style: context.textTheme.bodyMedium
                ?.copyWith(color: AppColors.success400)));
  }
}
