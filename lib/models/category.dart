class Category {
  String id;
  String name;
  String image;

  Category({required this.id, required this.name,required this.image});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'] as String, name: json['name'] as String,image:json['image'] as String);
  }

  get products => null;
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
