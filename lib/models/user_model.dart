class UserModel {
  final String uid, email, name;
  final String? photoUrl;
  const UserModel({required this.uid, required this.email, required this.name, this.photoUrl});
  factory UserModel.fromMap(Map<String, dynamic> m) =>
      UserModel(uid: m['uid'] ?? '', email: m['email'] ?? '', name: m['name'] ?? '', photoUrl: m['photoUrl']);
  Map<String, dynamic> toMap() => {'uid': uid, 'email': email, 'name': name, 'photoUrl': photoUrl};
}
