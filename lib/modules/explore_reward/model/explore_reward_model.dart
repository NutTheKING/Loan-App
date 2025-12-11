class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final String imageUrl;
  final bool isClaimed;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.imageUrl,
    this.isClaimed = false,
  });

  Reward copyWith({bool? isClaimed}) {
    return Reward(
      id: id,
      title: title,
      description: description,
      pointsRequired: pointsRequired,
      imageUrl: imageUrl,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}
