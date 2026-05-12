class TrustedContact {
  final String id;
  final String name;
  final String phone;

  TrustedContact({
    required this.id,
    required this.name,
    required this.phone,
  });

  // Convert to/from JSON for saving to shared_preferences
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
      };

  factory TrustedContact.fromJson(Map<String, dynamic> json) => TrustedContact(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
      );
}