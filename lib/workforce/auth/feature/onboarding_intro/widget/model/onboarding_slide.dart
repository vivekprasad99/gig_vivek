import 'dart:ui';
import '../../../../../core/widget/theme/theme_manager.dart';

class OnboardingSlide {
  final String imageUrl;
  final String title;
  final String description;
  final Color color;

  OnboardingSlide({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.color
  });
}

final onboardingSlideList = [
  OnboardingSlide(
    imageUrl: 'assets/images/ic_intro_1.svg',
    title: 'Explore job categories',
    description: 'Explore & apply to the job categories that interests you',
    color: AppColors.primaryMain,
  ),
  OnboardingSlide(
    imageUrl: 'assets/images/ic_intro_2.svg',
    title: 'Easy & secure \n Payments',
    description: 'We ensure you are paid fairly for your work directly to your bank account.',
    color: AppColors.link400,
  ),
  OnboardingSlide(
    imageUrl: 'assets/images/ic_intro_3.svg',
    title: 'Flexible Work \n Schedule',
    description: 'Choose when and where you work. Create your own schedule with flexible hours.',
    color: AppColors.success400,
  )
];