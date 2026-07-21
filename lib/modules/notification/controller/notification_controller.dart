import 'package:get/get.dart';
import 'package:loan_app/modules/notification/model/notification_model.dart';
import 'package:loan_app/utils/api_base_helper.dart';

class NotificationController extends GetxController {
  final _apiBaseHelper = ApiBaseHelper();
  final listNotification = <NotificationModel>[].obs;
  final getNotificationLoading = false.obs;

  Future<List<NotificationModel>> fetchAllNoticaitons() async {
    getNotificationLoading(true);
    try {
      final value = await _apiBaseHelper.onNetworkRequesting(
        url: 'notifications',
        methode: METHODE.get,
        isAuthorize: true,
      );
      final rawNotifications = value is Map<String, dynamic>
          ? value['notifications']
          : value;
      final notifications = rawNotifications is List
          ? rawNotifications
                .map(
                  (item) => NotificationModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : <NotificationModel>[];
      listNotification.assignAll(notifications);
      return notifications;
    } finally {
      getNotificationLoading(false);
    }
  }
}
