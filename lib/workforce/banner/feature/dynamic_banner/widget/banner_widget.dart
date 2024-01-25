import 'dart:math';
import 'package:awign/workforce/auth/feature/onboarding/widget/slide_dots.dart';
import 'package:awign/workforce/banner/data/model/banner_entity.dart';
import 'package:awign/workforce/banner/feature/dynamic_banner/cubit/banner_cubit.dart';
import 'package:awign/workforce/core/data/local/shared_preference_utils.dart';
import 'package:awign/workforce/core/data/model/user_data.dart';
import 'package:awign/workforce/core/deep_link/cubit/deep_link_cubit.dart';
import 'package:awign/workforce/core/di/app_injection_container.dart';
import 'package:awign/workforce/core/router/router.dart';
import 'package:awign/workforce/core/utils/browser_helper.dart';
import 'package:awign/workforce/core/utils/zoho/zoho_helper.dart';
import 'package:awign/workforce/core/widget/buttons/my_ink_well.dart';
import 'package:awign/workforce/core/widget/dialog/loading/app_circular_progress_indicator.dart';
import 'package:awign/workforce/core/widget/theme/theme_manager.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/constants.dart';

class BannerWidget extends StatefulWidget {
  final String name;

  const BannerWidget(this.name, {Key? key}) : super(key: key);

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final _bannerCubit = sl<BannerCubit>();
  int _currentPage = 0;
  UserData? _currentUser;

  @override
  void initState() {
    super.initState();
    _bannerCubit.getBannerList();
    getCurrentUser();
  }

  void getCurrentUser() async {
    SPUtil? spUtil = await SPUtil.getInstance();
    _currentUser = spUtil?.getUserData();
  }

  List<BannerData> getBannerList(List<BannerData>? bannerData) {
    return bannerData!
        .where((element) => element.placements!.contains(widget.name))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BannerData>>(
        stream: _bannerCubit.bannerResponseStream,
        builder: (context, bannerResponse) {
          if (bannerResponse.hasData && bannerResponse.data!.isNotEmpty) {
            getBannerList(bannerResponse.data);
            if (getBannerList(bannerResponse.data).length == 1) {
              return buildBannerCards(bannerResponse.data,0);
            } else {
              return Visibility(
                visible: getBannerList(bannerResponse.data).isNotEmpty,
                child: Stack(
                  children: [
                    CarouselSlider(
                        items: List.generate(
                            min(
                                widget.name == Constants.explorejobbottom
                                    ? 1
                                    : 3,
                                getBannerList(bannerResponse.data).length),
                                (index) {
                              return buildBannerCards(bannerResponse.data,index);
                            }),
                        options: CarouselOptions(
                            height: Dimens.imageHeight_172,
                            viewportFraction: 1,
                            enableInfiniteScroll: false,
                            autoPlay: widget.name != Constants.explorejobbottom
                                ? true
                                : false,
                            onPageChanged: (index, reason) {
                                setState(() {
                                  _currentPage = index;
                                });
                            },
                            autoPlayInterval: const Duration(seconds: 5))),
                    Visibility(
                      visible: widget.name != Constants.explorejobbottom,
                      child: Positioned(
                        bottom: Dimens.padding_24,
                        right: 0,
                        left: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0;
                            i <
                                min(
                                    3,
                                    getBannerList(bannerResponse.data)
                                        .length);
                            i++)
                              if (i == _currentPage)
                                const SlideDots(true)
                              else
                                const SlideDots(false)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildBannerCards(List<BannerData>? bannerList,int index)
  {
    return MyInkWell(
      onTap: () {
          if (getBannerList(bannerList)[index].target?.data?.contains("awign.com") == true) {
          sl<DeepLinkCubit>().launchWidgetFromDeepLink(
              getBannerList(bannerList)[index].target!.data!);
        } else {
          BrowserHelper.customTab(
              context,
              getBannerList(bannerList)[index].target!.data ??
                  "");
        }
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_16),
          topRight: Radius.circular(Dimens.radius_16),
        ),
        child: Image.network(
            getBannerList(bannerList)[index].source!.data ?? '',
            fit: BoxFit.fill,
            width: double.infinity, loadingBuilder:
            (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return AppCircularProgressIndicator();
        }),
      ),
    );
  }
}

