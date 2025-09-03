import 'package:flutter/material.dart';


class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      image: 'assets/images/onboarding_1.png',
      title: 'Welcome to NewsBrief!',
      description: "Stay informed in Amharic or English.",
      buttonText: 'Continue',
    ),
    _OnboardingPageData(
      image: 'assets/images/onboarding_2.png',
      title: 'News made simple',
      description:
      "Read or listen to quick summaries.",
      buttonText: 'Next',
    ),
    _OnboardingPageData(
      image: 'assets/images/onboarding_3.png',
      title: 'Stay updated, anywhere',
      description:
      "Access news even with low data or no internet.",
      buttonText: 'Get started',
      isLast: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboardingbackground.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return _OnboardingPage(
                        data: page,
                        onButtonPressed: _nextPage,
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 16,
                      ),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  final String image;
  final String title;
  final String description;
  final String buttonText;
  final bool isLast;

  const _OnboardingPageData({
    required this.image,
    required this.title,
    required this.description,
    required this.buttonText,
    this.isLast = false,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;
  final VoidCallback onButtonPressed;

  const _OnboardingPage({required this.data, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        // Image
        SizedBox(
          height: 490,
          child: Image.asset(
            data.image,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image, size: 120, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            data.description,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black),
          ),
        ),
        const Spacer(),
        // Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.buttonText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (data.isLast) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}