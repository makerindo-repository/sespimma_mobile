import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest {
  @JsonKey(name: 'nrp_nip')
  final String nrpNip;
  final String password;

  @JsonKey(name: 'fcm_token')
  final String fcmToken;

  const LoginRequest({
    required this.nrpNip,
    required this.password,
    required this.fcmToken,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
