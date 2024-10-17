class UserModel {
  String username;
  String profilePicture;

  UserModel({required this.username, required this.profilePicture});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'profilePicture': profilePicture,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      profilePicture: json['profilePicture'],
    );
  }
}
