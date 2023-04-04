class HostlrUser {
  String firstName;
  String lastName;
  String userName;
  String email;
  String collageCode;
  String yearOfAdmission;
  String branchCode;
  String rollNo;
  String stayId;
  String imageUrl;
  String phoneNumber;

  HostlrUser({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.collageCode,
    required this.yearOfAdmission,
    required this.branchCode,
    required this.rollNo,
    required this.stayId,
    this.imageUrl = 'https://firebasestorage.googleapis.com/v0/b/hostlr-72ba9.appspot.com/o'
        '/Profile_avatar_placeholder_large.png?alt=media&token=4b93d555-529d-42b'
        'b-9191-461daaabbf8ahttps://firebasestorage.googleapis.com/v0/b/hostlr-72'
        'ba9.appspot.com/o/Profile_avatar_placeholder_large.png?alt=media&token=4b9'
        '3d555-529d-42bb-9191-461daaabbf8a',
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'email': email,
      'collageCode': collageCode,
      'yearOfAdmission': yearOfAdmission,
      'branchCode': branchCode,
      'rollNo': rollNo,
      'stayId': stayId,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
    };
  }

  static HostlrUser fromJson(Map<String, dynamic> json) {
    return HostlrUser(
      firstName: json['firstName'],
      lastName: json['lastName'],
      userName: json['username'],
      email: json['email'],
      collageCode: json['collageCode'],
      yearOfAdmission: json['yearOfAdmission'],
      branchCode: json['branchCode'],
      rollNo: json['rollNo'],
      stayId: json['stayId'],
      imageUrl: json['imageUrl'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
