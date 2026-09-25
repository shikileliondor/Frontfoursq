import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_assets.dart';
import '../models/onboarding_page_data.dart';
import '../widgets/onboarding_page_indicator.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.onCompleted, super.key});

  final Future<void> Function() onCompleted;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

  bool get _isLastPage => _currentPage == onboardingPages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);
    try {
      await widget.onCompleted();
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  Future<void> _nextPage() async {
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingPages.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  return OnboardingSlide(data: onboardingPages[index]);
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        AppAssets.logo,
                        key: const Key('onboarding-logo'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    if (!_isLastPage)
                      TextButton(
                        onPressed: _isCompleting ? null : _complete,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          backgroundColor: Colors.white.withValues(alpha: 0.92),
                          minimumSize: const Size(72, 42),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Passer'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(24, 8, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OnboardingPageIndicator(
                currentPage: _currentPage,
                pageCount: onboardingPages.length,
                activeColor: theme.colorScheme.secondary,
                inactiveColor: const Color(0xFFD8DCE6),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _isCompleting
                      ? null
                      : (_isLastPage ? _complete : _nextPage),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: theme.colorScheme.secondary
                        .withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isCompleting && _isLastPage
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isLastPage ? 'Commencer' : 'Suivant'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
