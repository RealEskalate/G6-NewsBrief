// news_card.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class NewsCard extends StatefulWidget {
  final String title;
  final String description;
  final String source;
  final String imageUrl;
  final VoidCallback? onBookmark;

  const NewsCard({
    super.key,
    required this.title,
    required this.description,
    required this.source,
    required this.imageUrl,
    this.onBookmark,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      color: cardColor,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Image
          widget.imageUrl.isNotEmpty
              ? Image.network(
                  widget.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),

          // 🔹 Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source row with icon
                Row(
                  children: [
                    Icon(Icons.public, size: 14, color: secondaryTextColor),
                    const SizedBox(width: 4),
                    Text(
                      widget.source.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Title
                Text(
                  widget.title.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Description
                Text(
                  widget.description.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // 🔹 Action buttons row
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBookmark,
                      child: Icon(
                        Icons.bookmark_border,
                        size: 18,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.thumb_down_alt_outlined,
                      size: 18,
                      color: textColor,
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        // TODO: Hook up FlutterTTS here
                        debugPrint("Play news audio: ${widget.title}");
                      },
                      child: Icon(
                        Icons.volume_up,
                        size: 18,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class NewsCardData {
  final String title;
  final String description;
  final String source;
  final String imageUrl;

  NewsCardData({
    required this.title,
    required this.description,
    required this.source,
    required this.imageUrl,
  });
}


List<NewsCardData> sampleNews = [
  NewsCardData(
    title: 'ethiopia_tech_hub_title',
    description: 'ethiopia_tech_hub_desc',
    source: 'addis_standard',
    imageUrl: "https://picsum.photos/200/300?random=1",
  ),
  NewsCardData(
    title: 'ai_healthcare_africa_title',
    description: 'ai_healthcare_africa_desc',
    source: 'bbc_africa',
    imageUrl: "https://picsum.photos/200/300?random=2",
  ),
  NewsCardData(
    title: 'global_markets_oil_title',
    description: 'global_markets_oil_desc',
    source: 'reuters',
    imageUrl: "https://picsum.photos/200/300?random=3",
  ),
  NewsCardData(
    title: 'electric_cars_east_africa_title',
    description: 'electric_cars_east_africa_desc',
    source: 'the_guardian',
    imageUrl: "https://picsum.photos/200/300?random=4",
  ),
  NewsCardData(
    title: 'renewable_energy_storage_title',
    description: 'renewable_energy_storage_desc',
    source: 'techcrunch',
    imageUrl: "https://picsum.photos/200/300?random=5",
  ),
  NewsCardData(
    title: 'spacex_satellite_internet_title',
    description: 'spacex_satellite_internet_desc',
    source: 'cnn',
    imageUrl: "https://picsum.photos/200/300?random=6",
  ),
  NewsCardData(
    title: 'ethiopia_football_win_title',
    description: 'ethiopia_football_win_desc',
    source: 'bbc_sport',
    imageUrl: "https://picsum.photos/200/300?random=7",
  ),
  NewsCardData(
    title: 'climate_change_un_action_title',
    description: 'climate_change_un_action_desc',
    source: 'al_jazeera',
    imageUrl: "https://picsum.photos/200/300?random=8",
  ),
  NewsCardData(
    title: 'tech_giants_african_startups_title',
    description: 'tech_giants_african_startups_desc',
    source: 'forbes_africa',
    imageUrl: "https://picsum.photos/200/300?random=9",
  ),
  NewsCardData(
    title: 'cancer_research_breakthrough_title',
    description: 'cancer_research_breakthrough_desc',
    source: 'nature',
    imageUrl: "https://picsum.photos/200/300?random=10",
  ),
];
