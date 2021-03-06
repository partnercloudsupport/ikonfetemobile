import 'package:ikonfete/model/model.dart';

abstract class User extends Model<String> {
  String uid;
  String username;
  String name;
  String email;
  String facebookId;
  String twitterId;

  String country;
  String countryIsoCode;
  String profilePictureUrl;
  String profilePictureName;
  int feteScore = 0;

  DateTime dateCreated;
  DateTime dateUpdated;

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this
      ..uid = json["uid"]
      ..username = json["username"]
      ..name = json["name"]
      ..email = json["email"]
      ..country = json["country"] ?? ""
      ..countryIsoCode = json["countryIsoCode"] ?? ""
      ..facebookId = json["facebookId"]
      ..twitterId = json["twitterId"]
      ..feteScore = json["feteScore"] ?? 0
      ..profilePictureUrl = json["profilePictureUrl"] ?? ""
      ..profilePictureName = json["profilePictureName"] ?? "";
    if (json["dateCreated"] != null) {
      this.dateCreated =
          new DateTime.fromMillisecondsSinceEpoch(json["dateCreated"]).toUtc();
    }
    if (json["dateUpdated"] != null) {
      this.dateUpdated =
          new DateTime.fromMillisecondsSinceEpoch(json["dateUpdated"]).toUtc();
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      "uid": this.uid,
      "username": this.username,
      "email": this.email,
      "name": this.name,
      "country": this.country ?? "",
      "countryIsoCode": this.countryIsoCode ?? "",
      "facebookId": this.facebookId ?? "",
      "twitterId": this.twitterId ?? "",
      "feteScore": this.feteScore ?? 0,
      "profilePictureUrl": this.profilePictureUrl ?? "",
      "profilePictureName": this.profilePictureName ?? "",
      "dateCreated": this.dateCreated?.toUtc()?.millisecondsSinceEpoch ?? null,
      "dateUpdated": this.dateUpdated?.toUtc()?.millisecondsSinceEpoch ?? null,
    });
    return map;
  }
}
