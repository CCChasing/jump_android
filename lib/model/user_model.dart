class User {
  final String userId;
  final String username;
  final String realname;
  final String gender;
  final String avatar;
  final String token;

  User({
    required this.userId,
    required this.username,
    required this.realname,
    required this.gender,
    required this.avatar,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      username: json['username'],
      realname: json['realname'],
      gender: json['gender'],
      avatar: json['avatar'],
      token: json['token'],
    );
  }
}