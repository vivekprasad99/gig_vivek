// import 'package:awign/workforce/core/widget/take_a_tour/tour_keys.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:showcaseview/showcaseview.dart';
//
// import '../../router/router.dart';
// import '../buttons/raised_rect_button.dart';
// import '../theme/theme_manager.dart';
//
// class WelcomeBottomSheet extends StatelessWidget {
//   const WelcomeBottomSheet({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(Dimens.padding_16, Dimens.margin_48,
//           Dimens.padding_16, Dimens.margin_32),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text('welcome_text'.tr, style: Get.context?.textTheme.titleLarge),
//           const SizedBox(height: Dimens.margin_40),
//           buildContentAndIcon(
//               'explore_and_apply_job'.tr, 'assets/images/news.png'),
//           buildContentAndIcon(
//               'eligible_job_category'.tr, 'assets/images/rocket.svg'),
//           buildContentAndIcon('approved_work'.tr, 'assets/images/badge.svg'),
//           const SizedBox(height: Dimens.margin_12),
//           RaisedRectButton(
//             height: Dimens.margin_40,
//             text: 'let_get_started'.tr,
//             onPressed: () {
//               MRouter.pop(true);
//               WidgetsBinding.instance.addPostFrameCallback(
//                   (_) async => ShowCaseWidget.of(context).startShowCase([
//                         TourKeys.tourKeys1,
//                         TourKeys.tourKeys2,
//                         TourKeys.tourKeys3,
//                         TourKeys.tourKeys4,
//                         TourKeys.tourKeys5,
//                         TourKeys.tourKeys6,
//                       ]));
//             },
//             backgroundColor: AppColors.primaryMain,
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget buildContentAndIcon(String name, String url) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             url.contains('.svg')
//                 ? SvgPicture.asset(url)
//                 : Image.asset(
//                     url,
//                     height: 60,
//                   ),
//             const SizedBox(width: Dimens.margin_16),
//             Expanded(
//               child: Text(
//                 name,
//                 style: Get.context?.textTheme.bodyLarge,
//               ),
//             )
//           ],
//         ),
//         const SizedBox(height: Dimens.margin_20),
//       ],
//     );
//   }
// }
