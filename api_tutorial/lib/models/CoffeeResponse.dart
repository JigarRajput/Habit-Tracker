import 'package:json_annotation/json_annotation.dart';

part 'CoffeeResponse.g.dart';

@JsonSerializable()
class CoffeeResponse {
  int? id;
  String? name;
  String? description;
  double? price;
  String? region;
  int? weight;
  List<String>? flavorProfile;
  List<String>? grindOption;
  int? roastLevel;
  String? imageUrl;

  CoffeeResponse({
    this.id,
    this.name,
    this.description,
    this.price,
    this.region,
    this.weight,
    this.flavorProfile,
    this.grindOption,
    this.roastLevel,
    this.imageUrl,
  });

  factory CoffeeResponse.fromJson(Map<String, dynamic> json) =>
      _$CoffeeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CoffeeResponseToJson(this);
}
