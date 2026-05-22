import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'user_id')
  final String userId;

  final String name;

  @JsonKey(name: 'role_id')
  final String roleId;

  final String pokjar;

  final String nrp;
  final String pangkat;
  final String angkatan;
  final String agama;
  final String jabatan;

  @JsonKey(name: 'tanggal_lahir', defaultValue: '1990-01-01')
  final String tanggalLahir;

  @JsonKey(name: 'is_nak_approved', defaultValue: false)
  final bool isNakApproved;

  @JsonKey(name: 'jenis_kelamin', defaultValue: '-')
  final String jenisKelamin;

  @JsonKey(name: 'nilai_akademik', defaultValue: 0.0)
  final double nilaiAkademik;

  @JsonKey(name: 'nilai_mental', defaultValue: 0.0)
  final double nilaiMental;

  @JsonKey(name: 'nilai_jasmani', defaultValue: 0.0)
  final double nilaiJasmani;

  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  const LoginResponse({
    required this.userId,
    required this.name,
    required this.roleId,
    required this.pokjar,
    required this.nrp,
    required this.pangkat,
    required this.angkatan,
    required this.agama,
    required this.jenisKelamin,
    required this.jabatan,
    required this.tanggalLahir,
    required this.isNakApproved,
    required this.nilaiAkademik,
    required this.nilaiMental,
    required this.nilaiJasmani,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
