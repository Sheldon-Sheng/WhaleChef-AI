// lib/pages/onboarding/onboarding_form.dart
import 'package:flutter/material.dart';

class OnboardingForm extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const OnboardingForm({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}