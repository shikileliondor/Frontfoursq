class Event {
  const Event({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.scopeLabel,
    required this.imagePath,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String location;
  final String date;
  final String time;
  final String scopeLabel;
  final String imagePath;
  final String? imageUrl;
}
