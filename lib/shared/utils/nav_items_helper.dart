import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';

import '../../features/auth/presentation/pages/profile_screen.dart';
import '../../features/report/presentation/pages/report_screen.dart';
import '../../features/attendance/presentation/pages/attendance_screen.dart';
import '../../features/assignment/presentation/pages/assignment_screen.dart';
import '../../features/dashboard/presentation/pages/home_screen.dart';
import '../../features/assessment/presentation/pages/patun_sociometry_monitoring_screen.dart';
import '../../features/assessment/presentation/pages/gadik_assessment_screen.dart';
import '../../features/assessment/presentation/pages/patun_academic_monitoring_screen.dart';
import '../../features/assessment/presentation/pages/patun_mental_monitoring_screen.dart';
import '../../features/assessment/presentation/pages/patun_physical_monitoring_screen.dart';
import '../../features/assessment/presentation/pages/korsis_inbox_screen.dart';
import '../../features/gadik_assignment/presentation/pages/gadik_assignment_monitoring_screen.dart';
import '../../features/assessment/presentation/pages/korsis_mental_monitoring_screen.dart';
import '../../features/assessment/presentation/pages/korsis_sociometry_monitoring_screen.dart';
import '../../features/leadership_report/presentation/pages/leadership_report_screen.dart';
import '../../features/leadership_ews/presentation/pages/ews_screen.dart';
import '../../features/leadership_dashboard/presentation/pages/pimpinan_home_screen.dart';
import '../../features/attendance/presentation/pages/patun_attendance_monitoring_screen.dart';
import '../../features/attendance/presentation/pages/korsis_zone_screen.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });
}

List<NavItem> getNavItemsByRole(String roleId) {
  switch (roleId) {
    case 'pimpinan':
      return const [
        NavItem(
          label: 'Dashboard',
          icon: AppIcons.squaresFour,
          activeIcon: AppIcons.squaresFourFill,
          screen: PimpinanHomeScreen(),
        ),
        NavItem(
          label: 'Monitoring',
          icon: AppIcons.warningCircle,
          activeIcon: AppIcons.warningCircleFill,
          screen: EwsScreen(),
        ),
        NavItem(
          label: 'Laporan',
          icon: AppIcons.fileText,
          activeIcon: AppIcons.fileTextFill,
          screen: LeadershipReportScreen(),
        ),
        NavItem(
          label: 'Profil',
          icon: AppIcons.user,
          activeIcon: AppIcons.userFill,
          screen: ProfileScreen(),
        ),
      ];
    case 'pengajar':
      return const [
        NavItem(
          label: 'Tugas',
          icon: AppIcons.clipboardText,
          activeIcon: AppIcons.clipboardTextFill,
          screen: GadikAssignmentMonitoringScreen(),
        ),
        NavItem(
          label: 'Profil',
          icon: AppIcons.user,
          activeIcon: AppIcons.userFill,
          screen: ProfileScreen(),
        ),
      ];
    case 'pengajar_patun':
      return const [
        NavItem(
          label: 'Akademik',
          icon: AppIcons.bookOpen,
          activeIcon: AppIcons.bookOpenFill,
          screen: PatunAcademicMonitoringScreen(),
        ),
        NavItem(
          label: 'Mental',
          icon: AppIcons.shieldCheck,
          activeIcon: AppIcons.shieldCheckFill,
          screen: PatunMentalMonitoringScreen(),
        ),
        NavItem(
          label: 'Jasmani',
          icon: AppIcons.barbellFill,
          activeIcon: AppIcons.barbellFill,
          screen: PatunPhysicalMonitoringScreen(),
        ),
        NavItem(
          label: 'Absen',
          icon: AppIcons.mapPin,
          activeIcon: AppIcons.mapPinFill,
          screen: PatunAttendanceMonitoringScreen(),
        ),
        NavItem(
          label: 'Sosiometri',
          icon: Icons.groups_outlined,
          activeIcon: AppIcons.usersThreeFill,
          screen: PatunSociometryMonitoringScreen(),
        ),
        NavItem(
          label: 'Profil',
          icon: AppIcons.user,
          activeIcon: AppIcons.userFill,
          screen: ProfileScreen(),
        ),
      ];
    case 'pengajar_medis':
      return const [
        NavItem(
          label: 'Akademik',
          icon: AppIcons.bookOpen,
          activeIcon: AppIcons.bookOpenFill,
          screen: PatunAcademicMonitoringScreen(),
        ),
        NavItem(
          label: 'Penilaian',
          icon: AppIcons.pencilSimple,
          activeIcon: AppIcons.pencilSimpleFill,
          screen: GadikAssessmentScreen(),
        ),
        NavItem(
          label: 'Profil',
          icon: AppIcons.user,
          activeIcon: AppIcons.userFill,
          screen: ProfileScreen(),
        ),
      ];
    case 'pengajar_korsis':
      return const [
        NavItem(
          label: 'Inbox',
          icon: AppIcons.archive,
          activeIcon: AppIcons.archive,
          screen: KorsisInboxScreen(),
        ),
        NavItem(
          label: 'Mental',
          icon: AppIcons.shieldCheck,
          activeIcon: AppIcons.shieldCheckFill,
          screen: KorsisMentalMonitoringScreen(),
        ),
        NavItem(
          label: 'Sosiometri',
          icon: Icons.groups_outlined,
          activeIcon: AppIcons.usersThreeFill,
          screen: KorsisSociometryMonitoringScreen(),
        ),
        NavItem(
          label: 'Zona',
          icon: AppIcons.mapPin,
          activeIcon: AppIcons.mapPinFill,
          screen: KorsisZoneScreen(),
        ),
        NavItem(
          label: 'Profil',
          icon: AppIcons.user,
          activeIcon: AppIcons.userFill,
          screen: ProfileScreen(),
        ),
      ];
    case 'siswa':
    default:
      return const [
        NavItem(
          label: 'Beranda',
          icon: AppIcons.house,
          activeIcon: AppIcons.houseFill,
          screen: HomeScreen(),
        ),
        NavItem(
          label: 'Tugas',
          icon: AppIcons.clipboardText,
          activeIcon: AppIcons.clipboardTextFill,
          screen: AssignmentScreen(),
        ),
        NavItem(
          label: 'Zona',
          icon: AppIcons.mapPin,
          activeIcon: AppIcons.mapPinFill,
          screen: AttendanceScreen(),
        ),
        NavItem(
          label: 'Nilai',
          icon: AppIcons.chartBar,
          activeIcon: AppIcons.chartBarFill,
          screen: ReportScreen(),
        ),
        NavItem(
          label: 'Profil',
          icon: AppIcons.user,
          activeIcon: AppIcons.userFill,
          screen: ProfileScreen(),
        ),
      ];
  }
}
