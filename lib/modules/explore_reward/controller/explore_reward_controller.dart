import 'package:get/get.dart';
import 'package:loan_app/modules/explore_reward/model/explore_reward_model.dart';

class RewardController extends GetxController {
  var rewards = <Reward>[].obs;
  var userPoints = 120.obs; // Example: current points

  @override
  void onInit() {
    super.onInit();
    loadRewards();
  }

  void loadRewards() {
    rewards.value = [
      Reward(
        id: 'r1',
        title: '10% Cashback',
        description: 'Get 10% cashback on next loan repayment.',
        pointsRequired: 50,
        imageUrl: 'https://via.placeholder.com/100',
      ),
      Reward(
        id: 'r2',
        title: 'Free Transaction',
        description: 'Skip fees for one withdrawal.',
        pointsRequired: 80,
        imageUrl: 'https://via.placeholder.com/100',
      ),
      Reward(
        id: 'r3',
        title: 'Gift Voucher',
        description: 'Receive a ₱100 gift voucher.',
        pointsRequired: 150,
        imageUrl: 'https://via.placeholder.com/100',
      ),
    ];
  }

  void claimReward(int index) {
    final reward = rewards[index];
    if (userPoints.value >= reward.pointsRequired && !reward.isClaimed) {
      userPoints.value -= reward.pointsRequired;
      rewards[index] = reward.copyWith(isClaimed: true);
      Get.snackbar('Success', 'You have claimed ${reward.title}', snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Oops', 'Not enough points or already claimed.', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
