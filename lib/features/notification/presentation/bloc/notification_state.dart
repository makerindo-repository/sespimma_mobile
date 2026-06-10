import 'package:equatable/equatable.dart';

class NotificationState extends Equatable {
  final int unreadCount;

  const NotificationState({this.unreadCount = 0});

  NotificationState copyWith({int? unreadCount}) {
    return NotificationState(
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [unreadCount];
}
