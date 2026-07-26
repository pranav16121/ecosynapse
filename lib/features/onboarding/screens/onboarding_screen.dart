import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/widgets/eco_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Smart Waste Management',
      description:
          'EcoSynapse connects intelligent waste handling with communities for a cleaner tomorrow.',
      icon: Icons.auto_delete_outlined,
      color: EcoColors.darkGreen,
    ),
    OnboardingData(
      title: 'Measure Your Impact',
      description:
          'Track your EcoScore, recycling habits, and waste reduction with real-time analytics.',
      icon: Icons.bar_chart_outlined,
      color: EcoColors.primaryGreen,
    ),
    OnboardingData(
      title: 'Build Greener Communities',
      description:
          'Earn EcoPoints, participate in challenges, and contribute to your community\'s sustainability goals.',
      icon: Icons.people_outline,
      color: EcoColors.freshAccent,
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    context.read<AuthState>().completeOnboarding();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(EcoSpacing.l),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: EcoSpacing.s),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(EcoRadius.small),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: EcoSpacing.xl),
                  EcoButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: _onNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: EcoSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(EcoSpacing.xl),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 100, color: data.color),
          ),
          const SizedBox(height: EcoSpacing.xxl),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: EcoSpacing.m),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
