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

final universitySlideList = [
  Slide(
    imageUrl: 'https://awign-development.s3-ap-south-1.amazonaws.com/awign-ui%2FpPFiymVX7pdChGsf52JXau.png',
    title: 'Grow in your field',
    description: 'Learn new skills or enhance your existing skills with us to become more efficient at your work.',
  ),
  Slide(
    imageUrl: 'https://awign-development.s3-ap-south-1.amazonaws.com/awign-ui%2F4iVZogcg6WihQ6TsXTpRNs.png',
    title: 'Increase your earnings',
    description: 'The world is your oyster! Multiskill yourself to expand your skill set and potential to earn.',
  ),
  Slide(
    imageUrl: 'https://awign-development.s3-ap-south-1.amazonaws.com/awign-ui%2FvrFLoLMN7dUC3euM8WRbdi.png',
    title: 'Be curious, Always!',
    description: 'Check out our curation of content and courses to figure out a direction towards your goals.',
  )
];