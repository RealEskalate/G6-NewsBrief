import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../auth/presentation/pages/signup_landing.dart';


class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onFinish;

  const OnboardingScreen({super.key, this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _acceptedTerms = false;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      image: 'assets/images/onboarding_1.png',
      title: 'Welcome to NewsBrief!',
      description:
      "Stay informed with concise news summaries in Amharic or English.",
      buttonText: 'Continue',
      padding: EdgeInsets.all(40),
    ),
    _OnboardingPageData(
      image: '',
      title: 'News made simple',
      description:
      "Summarized in Amharic & English • Audio playback • Chatbot integration",
      buttonText: 'Next',
    ),
    _OnboardingPageData(
      image: '',
      title: 'Always in the Loop',
      description: "Never miss a headline, even without internet connection.",
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
      if (_acceptedTerms) {
        if (widget.onFinish != null) {
          widget.onFinish!();
        } else {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const SignupLandingPage(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept Terms & Conditions to continue.'),
          ),
        );
      }
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
                        acceptedTerms: _acceptedTerms,
                        onTermsChanged: (val) {
                          setState(() {
                            _acceptedTerms = val;
                          });
                        },
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
                        color:
                        _currentPage == index ? Colors.white : Colors.black,
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
  final EdgeInsets padding;

  const _OnboardingPageData({
    required this.image,
    required this.title,
    required this.description,
    required this.buttonText,
    this.isLast = false,
    this.padding = EdgeInsets.zero,
  });
}

class _OnboardingPage extends StatefulWidget {
  final _OnboardingPageData data;
  final VoidCallback onButtonPressed;
  final bool acceptedTerms;
  final ValueChanged<bool> onTermsChanged;

  const _OnboardingPage({
    required this.data,
    required this.onButtonPressed,
    required this.acceptedTerms,
    required this.onTermsChanged,
  });

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage> {
  bool _showTitle = false;
  bool _showDescription = false;
  bool _showFeatures = false;
  double _imageOpacity = 0;

  @override
  void initState() {
    super.initState();

    if (widget.data.image.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        setState(() {
          _imageOpacity = 1;
          _showTitle = true;
        });
      });
    } else {
      _showTitle = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Column(
      children: [
        const SizedBox(height: 32),
        SizedBox(
          height: 300,
          child: data.image.isNotEmpty
              ? Padding(
            padding: data.padding,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _imageOpacity),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.9 + (0.1 * value),
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                data.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image,
                    size: 120, color: Colors.grey),
              ),
            ),
          )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
        if (_showTitle)
          AnimatedTextKit(
            isRepeatingAnimation: false,
            animatedTexts: [
              TyperAnimatedText(
                data.title,
                textStyle: GoogleFonts.merriweather(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                speed: const Duration(milliseconds: 80),
              ),
            ],
            onFinished: () {
              setState(() {
                _showDescription = true;
                if (data.title == "News made simple") {
                  _showFeatures = true;
                }
              });
            },
          ),
        const SizedBox(height: 16),
        if (_showDescription)
          data.title == "News made simple"
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_showFeatures) ...[
                _AnimatedFeatureRow(
                  icon: Icons.language,
                  text: "Summarized in Amharic & English",
                  delay: 0,
                ),
                const SizedBox(height: 12),
                _AnimatedFeatureRow(
                  icon: Icons.volume_up,
                  text: "Audio playback",
                  delay: 300,
                ),
                const SizedBox(height: 12),
                _AnimatedFeatureRow(
                  icon: Icons.chat,
                  text: "Chatbot integration",
                  delay: 600,
                ),
              ],
            ],
          )
              : _DescriptionAnimated(text: data.description),
        const Spacer(),
        if (data.isLast)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: widget.acceptedTerms,
                  onChanged: (val) => widget.onTermsChanged(val ?? false),
                  checkColor: Colors.black,
                  activeColor: Colors.white,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Terms & Conditions"),
                        content: const Text(
                          "Here you can display your Terms & Conditions in detail...",
                          textAlign: TextAlign.justify,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    " I agree to the Terms and Conditions",
                    style: GoogleFonts.lora(
                      fontSize: 14,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: data.isLast && !widget.acceptedTerms
                  ? null
                  : widget.onButtonPressed,
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

class _AnimatedFeatureRow extends StatefulWidget {
  final IconData icon;
  final String text;
  final int delay;

  const _AnimatedFeatureRow({
    required this.icon,
    required this.text,
    required this.delay,
  });

  @override
  State<_AnimatedFeatureRow> createState() => _AnimatedFeatureRowState();
}

class _AnimatedFeatureRowState extends State<_AnimatedFeatureRow> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.5),
        duration: const Duration(milliseconds: 500),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              widget.text,
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionAnimated extends StatelessWidget {
  final String text;

  const _DescriptionAnimated({required this.text});

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      isRepeatingAnimation: false,
      animatedTexts: [
        TyperAnimatedText(
          text,
          textStyle: GoogleFonts.lora(
            fontSize: 18,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          speed: const Duration(milliseconds: 50),
        ),
      ],
    );
  }
}