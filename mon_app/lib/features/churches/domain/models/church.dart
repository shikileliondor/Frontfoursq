class Church {
  const Church({
    required this.id,
    required this.name,
    required this.area,
    required this.district,
    required this.zone,
    required this.address,
    required this.pastor,
    required this.phone,
    required this.schedule,
    required this.imagePath,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String area;
  final String district;
  final String zone;
  final String address;
  final String pastor;
  final String phone;
  final String schedule;
  final String imagePath;
  final String? imageUrl;

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    return name.toLowerCase().contains(normalized) ||
        area.toLowerCase().contains(normalized) ||
        district.toLowerCase().contains(normalized) ||
        zone.toLowerCase().contains(normalized);
  }
}
