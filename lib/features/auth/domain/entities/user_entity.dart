import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String userId;
  final String name;
  final String roleId;
  final String pokjar;
  final String nrp;
  final String pangkat;
  final String angkatan;
  final String agama;
  final String jenisKelamin;
  final String jabatan;
  final String? tanggalLahir;
  final String? umur;
  final bool? isNakApproved;
  final String? profilePhoto;
  final double nilaiAkademik;
  final double nilaiMental;
  final double nilaiJasmani;

  const UserEntity({
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
    this.tanggalLahir,
    this.umur,
    this.isNakApproved,
    this.profilePhoto,
    required this.nilaiAkademik,
    required this.nilaiMental,
    required this.nilaiJasmani,
  });

  String get displayUmur {
    if (umur != null && umur!.trim().isNotEmpty) return umur!;

    if (tanggalLahir != null) {
      try {
        final birthDate = DateTime.parse(tanggalLahir!);
        final today = DateTime(2026, 5, 15);
        int age = today.year - birthDate.year;
        if (today.month < birthDate.month ||
            (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }
        return age.toString();
      } catch (_) {
        return '41';
      }
    }
    return '41';
  }

  UserEntity copyWith({
    String? userId,
    String? name,
    String? roleId,
    String? pokjar,
    String? nrp,
    String? pangkat,
    String? angkatan,
    String? agama,
    String? jenisKelamin,
    String? jabatan,
    String? tanggalLahir,
    String? umur,
    bool? isNakApproved,
    String? profilePhoto,
    bool clearProfilePhoto = false,
    double? nilaiAkademik,
    double? nilaiMental,
    double? nilaiJasmani,
  }) {
    return UserEntity(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      roleId: roleId ?? this.roleId,
      pokjar: pokjar ?? this.pokjar,
      nrp: nrp ?? this.nrp,
      pangkat: pangkat ?? this.pangkat,
      angkatan: angkatan ?? this.angkatan,
      agama: agama ?? this.agama,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      jabatan: jabatan ?? this.jabatan,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      umur: umur ?? this.umur,
      isNakApproved: isNakApproved ?? this.isNakApproved,
      profilePhoto: clearProfilePhoto
          ? null
          : (profilePhoto ?? this.profilePhoto),
      nilaiAkademik: nilaiAkademik ?? this.nilaiAkademik,
      nilaiMental: nilaiMental ?? this.nilaiMental,
      nilaiJasmani: nilaiJasmani ?? this.nilaiJasmani,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    name,
    roleId,
    pokjar,
    nrp,
    pangkat,
    angkatan,
    agama,
    jenisKelamin,
    jabatan,
    tanggalLahir,
    umur,
    isNakApproved,
    profilePhoto,
    nilaiAkademik,
    nilaiMental,
    nilaiJasmani,
  ];
}
