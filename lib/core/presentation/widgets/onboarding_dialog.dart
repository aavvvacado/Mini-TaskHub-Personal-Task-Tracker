import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class OnboardingDialog extends StatelessWidget {
  const OnboardingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.tips_and_updates, color: Colors.amber),
          Gap(8),
          Text('Welcome to Flow!'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TutorialRow(
            icon: Icons.swipe_right,
            color: Colors.blue,
            text: 'Swipe RIGHT to progress a task.',
          ),
          Gap(12),
          _TutorialRow(
            icon: Icons.swipe_left,
            color: Colors.red,
            text: 'Swipe LEFT to delete/cancel.',
          ),
          Gap(16),
          Text('In Progress tasks cannot be deleted until finished!'),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it!'),
        ),
      ],
    );
  }
}

class _TutorialRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _TutorialRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const Gap(12),
        Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }
}
