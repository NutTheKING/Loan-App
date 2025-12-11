import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_app/modules/explore_reward/controller/explore_reward_controller.dart';

class RewardScreen extends StatelessWidget {
  final RewardController rc = Get.put(RewardController());

  RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Explore Rewards"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Obx(
              () => Text(
                "Your Points: ${rc.userPoints.value}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: rc.rewards.length,
                  itemBuilder: (context, i) {
                    final r = rc.rewards[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Image.network(r.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                        title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${r.description}\nPoints: ${r.pointsRequired}"),
                        trailing: Obx(
                          () => ElevatedButton(
                            onPressed: r.isClaimed ? null : () => rc.claimReward(i),
                            style: ElevatedButton.styleFrom(backgroundColor: r.isClaimed ? Colors.grey : Colors.blue),
                            child: Text(r.isClaimed ? "Claimed" : "Claim"),
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
