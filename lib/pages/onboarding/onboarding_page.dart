// lib/pages/onboarding/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_profile.dart';
import 'onboarding_form.dart';

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
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _saveAndFinish();
    }
  }

  Future<void> _saveAndFinish() async {
    final provider = context.read<UserProvider>();
    await provider.saveUser(UserProfile(
      age: _age,
      gender: _gender,
      height: _height,
      weight: _weight,
      bodyFatRate: _bodyFatRate,
      healthReportNotes: _healthNotes.isNotEmpty ? _healthNotes : null,
      chronicDiseases: _chronicDiseases.isNotEmpty ? _chronicDiseases : null,
      targetWeight: _targetWeight,
      targetBodyFat: _targetBodyFat,
      preferredFoods: _preferredFoods.join(','),
      dislikedFoods: _dislikedFoods.join(','),
    ));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('欢迎使用 DeepFry'),
        leading: _currentStep > 0
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
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
                child: Text(_currentStep == 4 ? '完成' : '下一步'),
              ),
            ),
          ),
          if (_currentStep > 0 && _currentStep < 4)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('${_currentStep + 1} / 5', style: const TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset('assets/images/welcome_1080x1920.png',
              height: 250, fit: BoxFit.cover,
              errorBuilder: (_, __, _) => Container(
                height: 250, color: Colors.orange[100],
                child: const Icon(Icons.restaurant, size: 80, color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('欢迎来到 DeepFry！', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('让我先了解你的身体状况和饮食偏好，\n我会为你规划健康又美味的一周菜谱。', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return OnboardingForm(
      title: '基本信息',
      children: [
        TextField(decoration: const InputDecoration(labelText: '年龄'), keyboardType: TextInputType.number, onChanged: (v) => _age = int.tryParse(v) ?? 25),
        DropdownButtonFormField(initialValue: _gender, items: const [DropdownMenuItem(value: '男', child: Text('男')), DropdownMenuItem(value: '女', child: Text('女'))], onChanged: (v) => setState(() => _gender = v!), decoration: const InputDecoration(labelText: '性别')),
        TextField(decoration: const InputDecoration(labelText: '身高 (cm)'), keyboardType: TextInputType.number, onChanged: (v) => _height = double.tryParse(v) ?? 170),
        TextField(decoration: const InputDecoration(labelText: '体重 (kg)'), keyboardType: TextInputType.number, onChanged: (v) => _weight = double.tryParse(v) ?? 65),
      ],
    );
  }

  Widget _buildOptionalInfoStep() {
    return OnboardingForm(
      title: '补充信息（选填）',
      children: [
        TextField(decoration: const InputDecoration(labelText: '体脂率 %（选填）', helperText: '不知道可以不填'), keyboardType: TextInputType.number, onChanged: (v) => _bodyFatRate = double.tryParse(v)),
        TextField(decoration: const InputDecoration(labelText: '体检报告异常项（选填）'), onChanged: (v) => _healthNotes = v),
        TextField(decoration: const InputDecoration(labelText: '慢性病（选填）'), onChanged: (v) => _chronicDiseases = v),
      ],
    );
  }

  Widget _buildGoalsStep() {
    return OnboardingForm(
      title: '目标设定',
      children: [
        TextField(decoration: const InputDecoration(labelText: '目标体重 (kg)'), keyboardType: TextInputType.number, onChanged: (v) => _targetWeight = double.tryParse(v) ?? 60),
        TextField(decoration: const InputDecoration(labelText: '目标体脂率 %'), keyboardType: TextInputType.number, onChanged: (v) => _targetBodyFat = double.tryParse(v) ?? 20),
      ],
    );
  }

  Widget _buildFoodPreferencesStep() {
    return OnboardingForm(
      title: '食物偏好',
      children: [
        TextField(
          controller: _foodController,
          decoration: InputDecoration(
            labelText: '爱吃的食物',
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
          spacing: 8, runSpacing: 4,
          children: _preferredFoods.map((f) => Chip(label: Text(f), onDeleted: () => setState(() => _preferredFoods.remove(f)))).toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dislikeController,
          decoration: InputDecoration(
            labelText: '讨厌的食物',
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
          spacing: 8, runSpacing: 4,
          children: _dislikedFoods.map((f) => Chip(label: Text(f), onDeleted: () => setState(() => _dislikedFoods.remove(f)))).toList(),
        ),
      ],
    );
  }
}