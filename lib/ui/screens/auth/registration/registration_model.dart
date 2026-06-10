class RegistrationData {
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  DateTime? birthday;
  String? gender;
  String? password;
  String? selfiePath;
  String? idPath;
  String? idBackPath;
  String? roles;

  // New address fields
  String? region;
  String? province;
  String? city;
  String? brgy;
  String? streetHouseBuilding;

  // Optional residence address (if different)
  String? residenceAddress;

  String status = "pending";

  // Computed full address
  String get fullAddress {
    final parts = [
      streetHouseBuilding,
      brgy,
      city,
      province,
      region,
    ].where((part) => part != null && part!.isNotEmpty).toList();

    return parts.join(", ");
  }

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phoneNumber": phoneNumber,
        "birthday": birthday != null
            ? "${birthday!.year}-${birthday!.month.toString().padLeft(2, '0')}-${birthday!.day.toString().padLeft(2, '0')}"
            : null,
        "gender": gender,
        "password": password,
        "selfiePath": selfiePath,
        "idPath": idPath,
        "idBackPath": idBackPath,

        // New fields
        "region": region,
        "province": province,
        "city": city,
        "brgy": brgy,
        "streetHouseBuilding": streetHouseBuilding,

        "residenceAddress": residenceAddress,
        "fullAddress": fullAddress,
        "status": status,
        "roles": roles,
      };
}
