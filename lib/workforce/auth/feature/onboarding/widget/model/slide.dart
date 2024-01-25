class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}
//https://awign-development.s3-ap-south-1.amazonaws.com/awign-ui%2F7ZvpKxxgFd79SZBwu6Mfkr.svg
final slideList = [
  Slide(
    imageUrl: 'assets/images/onboarding_2.svg',
    title: 'Flexible Work Schedule',
    description: 'Choose when and where you work.\nCreate your own schedule with flexible hours.',
  ),
  Slide(
    imageUrl: 'assets/images/onboarding_1.svg',
    title: 'Easy and secure Payments ',
    description: 'We ensure you are paid fairly and easily for\nyour work.',
  ),
  Slide(
    imageUrl: 'assets/images/onboarding_3.svg',
    title: 'Join 1 Million+ Users',
    description: 'Start working with us and get guidance and\nexperience along the way.',
  )
];