import 'package:flutter/material.dart';

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
                        source,
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
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
                    description,
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

List<NewsCardData> sampleNews = [
  NewsCardData(
    title: "Ethiopia Launches New Tech Hub in Addis Ababa",
    description:
    "The government has inaugurated a state-of-the-art technology hub to support startups and innovation.",
    source: "Addis Standard",
    imageUrl: "https://picsum.photos/200/300?random=1",
  ),
  NewsCardData(
    title: "AI Revolutionizes Healthcare in Africa",
    description:
    "New AI tools are being deployed to improve early diagnosis and patient care in hospitals.",
    source: "BBC Africa",
    imageUrl: "https://picsum.photos/200/300?random=2",
  ),
  NewsCardData(
    title: "Global Markets React to Oil Price Surge",
    description:
    "Oil prices hit a new high this month, causing ripple effects across international markets.",
    source: "Reuters",
    imageUrl: "https://picsum.photos/200/300?random=3",
  ),
  NewsCardData(
    title: "Electric Cars Gain Popularity in East Africa",
    description:
    "More cities are adopting charging stations as electric vehicles become increasingly popular.",
    source: "The Guardian",
    imageUrl: "https://picsum.photos/200/300?random=4",
  ),
  NewsCardData(
    title: "Breakthrough in Renewable Energy Storage",
    description:
    "Scientists announce a new battery design that could store solar energy more efficiently.",
    source: "TechCrunch",
    imageUrl: "https://picsum.photos/200/300?random=5",
  ),
  NewsCardData(
    title: "SpaceX Launches Satellite for Global Internet",
    description:
    "The satellite aims to improve internet connectivity in rural and underserved regions.",
    source: "CNN",
    imageUrl: "https://picsum.photos/200/300?random=6",
  ),
  NewsCardData(
    title: "Football: Ethiopia Wins Historic Match",
    description:
    "The Ethiopian national team secures a surprise victory in the African Cup of Nations.",
    source: "BBC Sport",
    imageUrl: "https://picsum.photos/200/300?random=7",
  ),
  NewsCardData(
    title: "Climate Change: UN Urges Action",
    description:
    "A new UN report highlights urgent measures needed to address global climate challenges.",
    source: "Al Jazeera",
    imageUrl: "https://picsum.photos/200/300?random=8",
  ),
  NewsCardData(
    title: "Tech Giants Invest in African Startups",
    description:
    "Major international companies are funding innovative African tech startups.",
    source: "Forbes Africa",
    imageUrl: "https://picsum.photos/200/300?random=9",
  ),
  NewsCardData(
    title: "Breakthrough in Cancer Research",
    description:
    "Scientists discover a new treatment method that could reduce recovery time significantly.",
    source: "Nature",
    imageUrl: "https://picsum.photos/200/300?random=10",
  ),
];
