// lib/pages/onboarding/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../models/user_profile.dart';
import 'onboarding_form.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentStep = 0;

  // 表单数据
  int _age = 25;
  String _gender = '男';
  double _height = 170.0;
  double _weight = 65.0;
  double? _bodyFatRate;
  String _healthNotes = '';
  String _chronicDiseases = '';
  String _allergens = '';
  double _targetWeight = 60.0;
  double _targetBodyFat = 20.0;
  final List<String> _preferredFoods = [];
  final List<String> _dislikedFoods = [];
  final _foodController = TextEditingController();
  final _dislikeController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _foodController.dispose();
    _dislikeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveAndFinish();
    }
  }

  Future<void> _saveAndFinish() async {
    final provider = context.read<UserProvider>();
    await provider.saveUser(
      UserProfile(
        age: _age,
        gender: _gender,
        height: _height,
        weight: _weight,
        bodyFatRate: _bodyFatRate,
        healthReportNotes: _healthNotes.isNotEmpty ? _healthNotes : null,
        chronicDiseases: _chronicDiseases.isNotEmpty ? _chronicDiseases : null,
        allergens: _allergens,
        targetWeight: _targetWeight,
        targetBodyFat: _targetBodyFat,
        preferredFoods: _preferredFoods.join(','),
        dislikedFoods: _dislikedFoods.join(','),
      ),
    );
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingAppBar),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _buildWelcomeStep(),
                _buildBasicInfoStep(),
                _buildOptionalInfoStep(),
                _buildGoalsStep(),
                _buildFoodPreferencesStep(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep,
                child: Text(
                  _currentStep == 4 ? l10n.onboardingDone : l10n.onboardingNext,
                ),
              ),
            ),
          ),
          if (_currentStep > 0 && _currentStep < 4)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.onboardingProgress(_currentStep + 1, 5),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/welcome.png',
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (_, __, _) => Container(
                height: 250,
                color: kSeedBlue.withValues(alpha: 0.12),
                child: const Icon(Icons.restaurant, size: 80, color: kSeedBlue),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.welcomeTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.welcomeSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    final l10n = AppLocalizations.of(context);
    return OnboardingForm(
      title: l10n.basicInfoTitle,
      children: [
        TextField(
          decoration: InputDecoration(labelText: l10n.age),
          keyboardType: TextInputType.number,
          onChanged: (v) => _age = int.tryParse(v) ?? 25,
        ),
        DropdownButtonFormField(
          initialValue: _gender,
          items: [
            DropdownMenuItem(value: '男', child: Text(l10n.genderMale)),
            DropdownMenuItem(value: '女', child: Text(l10n.genderFemale)),
          ],
          onChanged: (v) => setState(() => _gender = v!),
          decoration: InputDecoration(labelText: l10n.gender),
        ),
        TextField(
          decoration: InputDecoration(labelText: l10n.heightCm),
          keyboardType: TextInputType.number,
          onChanged: (v) => _height = double.tryParse(v) ?? 170,
        ),
        TextField(
          decoration: InputDecoration(labelText: l10n.weightKg),
          keyboardType: TextInputType.number,
          onChanged: (v) => _weight = double.tryParse(v) ?? 65,
        ),
      ],
    );
  }

  Widget _buildOptionalInfoStep() {
    final l10n = AppLocalizations.of(context);
    return OnboardingForm(
      title: l10n.optionalInfoTitle,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: l10n.bodyFatPercent,
            helperText: l10n.bodyFatHelper,
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) => _bodyFatRate = double.tryParse(v),
        ),
        TextField(
          decoration: InputDecoration(labelText: l10n.healthNotes),
          onChanged: (v) => _healthNotes = v,
        ),
        TextField(
          decoration: InputDecoration(labelText: l10n.chronicDiseases),
          onChanged: (v) => _chronicDiseases = v,
        ),
        TextField(
          decoration: InputDecoration(labelText: l10n.allergens),
          onChanged: (v) => _allergens = v,
        ),
      ],
    );
  }

  Widget _buildGoalsStep() {
    final l10n = AppLocalizations.of(context);
    return OnboardingForm(
      title: l10n.goalsTitle,
      children: [
        TextField(
          decoration: InputDecoration(labelText: l10n.targetWeightKg),
          keyboardType: TextInputType.number,
          onChanged: (v) => _targetWeight = double.tryParse(v) ?? 60,
        ),
        TextField(
          decoration: InputDecoration(labelText: l10n.targetBodyFatPercent),
          keyboardType: TextInputType.number,
          onChanged: (v) => _targetBodyFat = double.tryParse(v) ?? 20,
        ),
      ],
    );
  }

  Widget _buildFoodPreferencesStep() {
    final l10n = AppLocalizations.of(context);
    return OnboardingForm(
      title: l10n.foodPrefsTitle,
      children: [
        TextField(
          controller: _foodController,
          decoration: InputDecoration(
            labelText: l10n.likedFoods,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_foodController.text.isNotEmpty) {
                  setState(() => _preferredFoods.add(_foodController.text));
                  _foodController.clear();
                }
              },
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _preferredFoods
              .map(
                (f) => Chip(
                  label: Text(f),
                  onDeleted: () => setState(() => _preferredFoods.remove(f)),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dislikeController,
          decoration: InputDecoration(
            labelText: l10n.dislikedFoods,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_dislikeController.text.isNotEmpty) {
                  setState(() => _dislikedFoods.add(_dislikeController.text));
                  _dislikeController.clear();
                }
              },
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _dislikedFoods
              .map(
                (f) => Chip(
                  label: Text(f),
                  onDeleted: () => setState(() => _dislikedFoods.remove(f)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
