// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ApiModel {
  final String? name;
  final String? email;
  final String? address;
  ApiModel({
    this.name,
    this.email,
    this.address,
  });

  ApiModel copyWith({
    String? name,
    String? email,
    String? address,
  }) {
    return ApiModel(
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'address': address,
    };
  }

  factory ApiModel.fromMap(Map<String, dynamic> map) {
    return ApiModel(
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      address: map['address'] != null ? map['address'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiModel.fromJson(String source) => ApiModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ApiModel(name: $name, email: $email, address: $address)';

  @override
  bool operator ==(covariant ApiModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.name == name &&
      other.email == email &&
      other.address == address;
  }

  @override
  int get hashCode => name.hashCode ^ email.hashCode ^ address.hashCode;
}
