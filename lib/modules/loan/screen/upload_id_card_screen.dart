import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_app/modules/loan/controller/loan_controller.dart';
import 'package:loan_app/modules/loan/loan_routes.dart';
import 'package:loan_app/modules/loan/widget/loan_step_header.dart';

class UploadScreen extends StatelessWidget {
  UploadScreen({super.key});

  final LoanController controller = LoanController.ensure();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity documents')),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const LoanStepHeader(
              step: 2,
              title: 'Verify your identity',
              subtitle:
                  'Upload clear, readable images. Files are sent securely with your application.',
            ),
            const SizedBox(height: 22),
            _DocumentTile(
              icon: Icons.badge_outlined,
              title: 'Front of ID',
              subtitle: controller.frontId.value,
              isComplete: controller.frontId.value.isNotEmpty,
              onTap: () => _chooseSource(context, 'ID_FRONT'),
            ),
            const SizedBox(height: 12),
            _DocumentTile(
              icon: Icons.badge_outlined,
              title: 'Back of ID',
              subtitle: controller.backId.value,
              isComplete: controller.backId.value.isNotEmpty,
              onTap: () => _chooseSource(context, 'ID_BACK'),
            ),
            const SizedBox(height: 12),
            _DocumentTile(
              icon: Icons.face_retouching_natural_outlined,
              title: 'Identity selfie',
              subtitle: controller.selfie.value,
              isComplete: controller.selfie.value.isNotEmpty,
              onTap: () => _chooseSource(context, 'SELFIE'),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Use original images without glare. Your name and ID number must be visible.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: controller.allUploaded()
                  ? () => context.push(LoanRoutes.personalInformation)
                  : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Continue to personal information'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseSource(BuildContext context, String target) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.pickFromCamera(target);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose a file'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.pickFromGallery(target);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isComplete,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isComplete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isComplete ? subtitle : 'Tap to upload',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              isComplete ? Icons.check_circle_rounded : Icons.upload_rounded,
              color: isComplete ? Theme.of(context).colorScheme.primary : null,
            ),
          ],
        ),
      ),
    ),
  );
}
