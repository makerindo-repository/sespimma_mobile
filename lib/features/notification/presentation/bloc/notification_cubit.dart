import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService;

  NotificationCubit({required NotificationService notificationService})
    : _notificationService = notificationService,
      super(const NotificationState(unreadCount: 0));

  void incrementUnreadCount() {
    emit(state.copyWith(unreadCount: state.unreadCount + 1));
  }

  void resetUnreadCount() {
    emit(state.copyWith(unreadCount: 0));
  }

  void showIncomingNotification({
    required String title,
    required String body,
    String? payload,
  }) {
    incrementUnreadCount();
    _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: payload,
    );
  }

  void setUnreadCount(int count) {
    emit(state.copyWith(unreadCount: count));
  }
}
