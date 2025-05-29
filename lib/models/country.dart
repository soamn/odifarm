class Country {
  final String id;
  final String name;
  final String code;

  Country({required this.id, required this.name, required this.code});

  factory Country.fromJson(Map<String, dynamic> json) =>
      Country(id: json['id'], name: json['name'], code: json['code']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'code': code};
}
