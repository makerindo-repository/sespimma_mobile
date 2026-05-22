// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      roleId: json['role_id'] as String,
      pokjar: json['pokjar'] as String,
      nrp: json['nrp'] as String,
      nosis: json['nosis'] as String? ?? '-',
      pangkat: json['pangkat'] as String,
      angkatan: json['angkatan'] as String,
      agama: json['agama'] as String,
      jenisKelamin: json['jenis_kelamin'] as String? ?? '-',
      jabatan: json['jabatan'] as String,
      tanggalLahir: json['tanggal_lahir'] as String? ?? '1990-01-01',
      isNakApproved: json['is_nak_approved'] as bool? ?? false,
      nilaiAkademik: (json['nilai_akademik'] as num?)?.toDouble() ?? 0.0,
      nilaiMental: (json['nilai_mental'] as num?)?.toDouble() ?? 0.0,
      nilaiJasmani: (json['nilai_jasmani'] as num?)?.toDouble() ?? 0.0,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'role_id': instance.roleId,
      'pokjar': instance.pokjar,
      'nrp': instance.nrp,
      'nosis': instance.nosis,
      'pangkat': instance.pangkat,
      'angkatan': instance.angkatan,
      'agama': instance.agama,
      'jabatan': instance.jabatan,
      'tanggal_lahir': instance.tanggalLahir,
      'is_nak_approved': instance.isNakApproved,
      'jenis_kelamin': instance.jenisKelamin,
      'nilai_akademik': instance.nilaiAkademik,
      'nilai_mental': instance.nilaiMental,
      'nilai_jasmani': instance.nilaiJasmani,
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
    };
