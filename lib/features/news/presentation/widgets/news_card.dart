// news_card.dart
import 'package:flutter/material.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
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

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.source,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                // Action buttons row
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBookmark,
                      child: const Icon(
                        Icons.bookmark_border,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.thumb_down_alt_outlined,
                      size: 18,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        // TODO: Hook up FlutterTTS here
                        print("Play news audio: ${widget.title}");
                      },
                      child: const Icon(
                        Icons.volume_up,
                        size: 18,
                        color: Colors.black,
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

// 🔹 Dummy sample data
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
