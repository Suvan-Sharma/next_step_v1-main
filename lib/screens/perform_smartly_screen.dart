import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_app/widgets/custom_app_bar.dart';

class PerformSmartlyScreen extends StatelessWidget {
  const PerformSmartlyScreen({super.key});

  // Video data model
  static const List<VideoData> videos = [
    VideoData(
      title: "Tips for Teens Tuesday – Good Impressions & Interview Skills",
      url: "https://www.youtube.com/watch?v=1mEZ9ayiang",
      thumbnail: "https://img.youtube.com/vi/1mEZ9ayiang/maxresdefault.jpg",
    ),
    VideoData(
      title: "How to Dress for a Job Interview (For Teens)",
      url: "https://www.youtube.com/watch?v=IdYFdG3fC04",
      thumbnail: "https://img.youtube.com/vi/IdYFdG3fC04/maxresdefault.jpg",
    ),
    VideoData(
      title: "What to Wear to an Interview: Dress Codes, Outfit Ideas & What to Avoid",
      url: "https://www.youtube.com/watch?v=jzPAjrrtLxY",
      thumbnail: "https://img.youtube.com/vi/jzPAjrrtLxY/maxresdefault.jpg",
    ),
    VideoData(
      title: "Job Interview Tips for Teens: How to Prepare, Dress, and Ask the Right Questions",
      url: "https://www.youtube.com/watch?v=bXgvdUa-4l8",
      thumbnail: "https://img.youtube.com/vi/bXgvdUa-4l8/maxresdefault.jpg",
    ),
    VideoData(
      title: "Job Interview Prep (Teens mock interviews + feedback)",
      url: "https://www.youtube.com/watch?v=ytckc4Gljlo",
      thumbnail: "https://img.youtube.com/vi/ytckc4Gljlo/maxresdefault.jpg",
    ),
    VideoData(
      title: "Nail Your First Job Interview: Tips for Teens!",
      url: "https://www.youtube.com/watch?v=k2piOEkpmEc",
      thumbnail: "https://img.youtube.com/vi/k2piOEkpmEc/maxresdefault.jpg",
    ),
    VideoData(
      title: "How Teens Can Answer \"Tell Me About Yourself\"",
      url: "https://www.youtube.com/watch?v=WopdqLfLZ9c",
      thumbnail: "https://img.youtube.com/vi/WopdqLfLZ9c/maxresdefault.jpg",
    ),
    VideoData(
      title: "How to Crush a Job Interview | Tips for Students",
      url: "https://www.youtube.com/watch?v=pTmejUx-eTo",
      thumbnail: "https://img.youtube.com/vi/pTmejUx-eTo/maxresdefault.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: "Perform Smartly",
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Compute exact item height: 16:9 thumbnail + title area (2 lines) + padding
              final double gridWidth = constraints.maxWidth;
              const int columns = 2;
              const double crossAxisSpacing = 16;
              final double itemWidth = (gridWidth - crossAxisSpacing) / columns;
              final double thumbnailHeight = itemWidth * 9 / 16;
              // Title area estimate: two lines of text (approx 32px) + 16px vertical padding
              const double titleAreaHeight = 50; // tuned to avoid leftover space
              final double cardHeight = thumbnailHeight + titleAreaHeight;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: 16,
                  mainAxisExtent: cardHeight,
                ),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return VideoCard(video: videos[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class VideoData {
  final String title;
  final String url;
  final String thumbnail;

  const VideoData({
    required this.title,
    required this.url,
    required this.thumbnail,
  });
}

class VideoCard extends StatelessWidget {
  final VideoData video;

  const VideoCard({super.key, required this.video});

  Future<void> _launchVideo() async {
    final Uri url = Uri.parse(video.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchVideo,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play icon (16:9 aspect ratio)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(video.thumbnail),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Fallback to a placeholder if thumbnail fails to load
                    },
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xFFFF6B35),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                video.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0A1543),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}