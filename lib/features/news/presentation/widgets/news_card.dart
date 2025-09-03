import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class NewsCard extends StatelessWidget {
  final String title;
  final String description;
  final String source;
  final String imageUrl;

  const NewsCard({
    super.key,
    required this.title,
    required this.description,
    required this.source,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDE (text content)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.public, size: 14, color: secondaryTextColor),
                      const SizedBox(width: 4),
                      Text(
                        source.tr(),
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.7),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 18,
                        color: textColor,
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.thumb_down_alt_outlined,
                        size: 18,
                        color: textColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // RIGHT SIDE (image)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
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

// Use keys for translation
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
