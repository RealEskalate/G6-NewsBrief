import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:newsbrief/features/news/presentation/widgets/animations/bounce_button.dart';
import 'package:newsbrief/features/news/presentation/widgets/animations/globe_background.dart';
import 'package:newsbrief/features/news/presentation/widgets/chat_bot_popup.dart';
import '../cubit/bookmark_cubit.dart';

class NewsDetailPage extends StatefulWidget {
  final String id; // unique news id for bookmarking
  final String topics;
  final String title;
  final String source;
  final String imageUrl;
  final String detail;

  const NewsDetailPage({
    super.key,
    required this.id,
    required this.topics,
    required this.title,
    required this.source,
    required this.imageUrl,
    required this.detail,
  });

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> with TickerProviderStateMixin {
  bool _isChatbotVisible = false;
  bool _isPlaying = false;
  double _audioSpeed = 0.5;
  String _language = 'EN';
  final double _sheetHeight = 180;

  late final FlutterTts _flutterTts;
  late final AnimationController _globeController;
  late final AnimationController _audioSheetController;
  late final AnimationController _progressController;
  late final AnimationController _discController;
  late final AnimationController _chatbotController;
  late final Animation<Offset> _chatbotOffsetAnimation;

  final LinearGradient activeGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF111827), Colors.black],
  );

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(_audioSpeed);
    _flutterTts.setCompletionHandler(() => setState(() => _isPlaying = false));

    // Animations
    _globeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _globeController.reverse();
        else if (status == AnimationStatus.dismissed) _globeController.forward();
      });

    _audioSheetController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 225));
    _discController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _chatbotController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _chatbotOffsetAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _chatbotController, curve: Curves.easeOutCubic),
    );
  }

  void _toggleChatbot() => setState(() => _isChatbotVisible = !_isChatbotVisible);

  Future<void> _togglePlay() async {
    setState(() => _isPlaying = !_isPlaying);

    if (_isPlaying) {
      _globeController.forward();
      _audioSheetController.forward();
      _discController.repeat();
      _progressController.forward();

      if (_language == 'EN') await _flutterTts.setLanguage("en-US");
      else await _flutterTts.setLanguage("am-ET");

      await _flutterTts.setSpeechRate(_audioSpeed);
      await _flutterTts.speak(widget.detail);
    } else {
      _globeController.stop();
      _globeController.value = 1.0;
      _audioSheetController.reverse();
      _discController.stop();
      _progressController.stop();
      await _flutterTts.stop();
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _globeController.dispose();
    _audioSheetController.dispose();
    _progressController.dispose();
    _discController.dispose();
    super.dispose();
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          const GlobeBackground(),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: size.height * 0.25,
                pinned: true,
                backgroundColor: theme.colorScheme.background.withOpacity(0.9),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: CircleAvatar(
                    backgroundColor: theme.colorScheme.background.withOpacity(0.8),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: theme.colorScheme.secondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  BlocBuilder<BookmarkCubit, BookmarkState>(
                    builder: (context, state) {
                      bool isBookmarked = false;
                      if (state is BookmarkLoaded) {
                        isBookmarked = state.bookmarks.any((b) => b.newsId == widget.id);
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: CircleAvatar(
                          backgroundColor: theme.colorScheme.background.withOpacity(0.8),
                          child: IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: theme.colorScheme.secondary,
                            ),
                            onPressed: () {
                              if (isBookmarked) {
                                context.read<BookmarkCubit>().removeBookmark(widget.id);
                              } else {
                                context.read<BookmarkCubit>().addBookmark(widget.id);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: CircleAvatar(
                      backgroundColor: theme.colorScheme.background.withOpacity(0.8),
                      child: IconButton(
                        icon: Icon(_isPlaying ? Icons.pause_circle_filled_outlined : Icons.play_circle_filled_outlined, color: theme.colorScheme.secondary),
                        onPressed: _togglePlay,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: CircleAvatar(
                      backgroundColor: theme.colorScheme.background.withOpacity(0.8),
                      child: IconButton(
                        icon: Icon(Icons.more_vert, color: theme.colorScheme.secondary),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                        child: Image.network(widget.imageUrl, fit: BoxFit.cover, width: size.width),
                      ),
                      if (_isPlaying)
                        Center(
                          child: RotationTransition(
                            turns: _discController,
                            child: Container(
                              height: size.height * 0.12,
                              width: size.height * 0.12,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.3)),
                              child: const Icon(Icons.public, color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                      if (_isPlaying) Container(color: Colors.black26),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.topics, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(widget.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(widget.source, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary)),
                          const Spacer(),
                          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: Text('Subscribe'.tr())),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(widget.detail, style: theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
      
          if (_isChatbotVisible)
            Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: Offset(0, -150), // move 50 pixels up
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: size.height * 0.6),
                  child: ChatbotPopup(onClose: _toggleChatbot),
                ),
              ),
            ),

          // 🔹 Audio Sheet with slide up animation
          AnimatedBuilder(
            animation: _audioSheetController,
            builder: (context, child) {
              final slide = Curves.easeOutBack.transform(
                _audioSheetController.value,
              );
              return Positioned(
                left: 0,
                right: 0,
                bottom: -(size.height * 0.25) + (size.height * 0.25 * slide),
                child: Opacity(
                  opacity: _audioSheetController.value,
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 10),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // spinning disc
                      RotationTransition(
                        turns: _discController,
                        child: Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white24,
                          ),
                          child: const Icon(
                            Icons.public,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _togglePlay,
                        icon: Icon(
                          _isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, _) {
                            final elapsed = Duration(
                              seconds: (_progressController.value * 225)
                                  .toInt(),
                            );
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: _progressController.value,
                                  backgroundColor: Colors.white24,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${formatDuration(elapsed)} / 3:45",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // speed & language toggle
                  Row(
                    children: [
                      Text(
                        "Speed: ${_audioSpeed.toStringAsFixed(1)}x",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Expanded(
                        child: Slider(
                          value: _audioSpeed,
                          min: 0.5,
                          max: 2.0,
                          divisions: 15,
                          label: "${_audioSpeed.toStringAsFixed(1)}x",
                          onChanged: (value) {
                            setState(() {
                              _audioSpeed = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ToggleButtons(
                        isSelected: [_language == 'EN', _language == 'AM'],
                        onPressed: (index) async {
                          setState(() {
                            _language = index == 0 ? 'EN' : 'AM';
                          });

                          // Change TTS language dynamically if playing
                          if (_isPlaying) {
                            await _flutterTts.stop();
                            if (_language == 'EN') {
                              await _flutterTts.setLanguage("en-US");
                            } else {
                              await _flutterTts.setLanguage("am-ET");
                            }
                            await _flutterTts.speak(widget.detail);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        selectedColor: Colors.white,
                        fillColor: Colors.blueAccent,
                        color: Colors.white70,
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("EN"),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("AM"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 🔹 Chat FAB dynamically above audio sheet
          AnimatedBuilder(
            animation: _audioSheetController,
            builder: (context, child) {
              final offset = Tween<Offset>(
                begin: Offset(0, 0), // normal FAB pos
                end: Offset(
                  0,
                  -(_sheetHeight / 56),
                ), // slide up by sheet height
              ).transform(_audioSheetController.value);

              return Positioned(
                right: 16,
                bottom: 16,
                child: FractionalTranslation(translation: offset, child: child),
              );
            },
            child: _isChatbotVisible
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: activeGradient,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chat_outlined,
                        color: Colors.white,
                      ),
                      onPressed: _toggleChatbot,
                    ),
                  )
                : BounceButton(
                    icon: Icons.chat_outlined,
                    onTap: _toggleChatbot,
                    isFab: true,
                    iconColor: theme.colorScheme.onPrimary,
                    backgroundColor: theme.colorScheme.primary,
                  ),
          ),
        ],
      ),
    );
  }
}
