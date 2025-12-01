class Contact {
  final int? id;
  final String name;
  final String phone;
  final String address;
  final String workingHours;
  final bool isFavorite;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.workingHours,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'workingHours': workingHours,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      workingHours: map['workingHours'] as String,
      isFavorite: (map['isFavorite'] as int) == 1,
    );
  }

  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? workingHours,
    bool? isFavorite,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      workingHours: workingHours ?? this.workingHours,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

