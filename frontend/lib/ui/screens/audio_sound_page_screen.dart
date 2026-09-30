import 'package:flutter/material.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class AudioSoundPageScreen extends StatefulWidget {
  final String trackTitle;
  final String artistName;
  final String coverUrl;
  final int reelsCount;
  final VoidCallback onUseAudio;
  final VoidCallback onBack;

  const AudioSoundPageScreen({
    super.key,
    required this.trackTitle,
    required this.artistName,
    required this.coverUrl,
    this.reelsCount = 14280,
    required this.onUseAudio,
    required this.onBack,
  });

  @override
  State<AudioSoundPageScreen> createState() => _AudioSoundPageScreenState();
}

class _AudioSoundPageScreenState extends State<AudioSoundPageScreen> {
  bool _isPlaying = false;

  final List<String> _sampleReelThumbs = [
    'https://images.unsplash.com/photo-1542051841857-5f90071e7989?w=400',
    'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=400',
    'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400',
    'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=400',
    'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400',
    'https://images.unsplash.com/photo-1563089145-599997674d42?w=400',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      appBar: AppBar(
        backgroundColor: CyberColors.bgVoid,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: Text(
          'AUDIO SYNTH',
          style: CyberTypography.hudHeader.copyWith(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: CyberColors.surfaceModal,
                  content: Text('Audio saved to Sound Vault'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Audio Header Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Album cover
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CyberColors.secondaryCyan, width: 1.5),
                    boxShadow: CyberColors.cyanGlowShadow(blur: 10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.network(
                      widget.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.music_note, color: CyberColors.secondaryCyan, size: 36),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Track metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.trackTitle,
                        style: CyberTypography.titleSmall.copyWith(fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.artistName,
                        style: CyberTypography.hudCaption.copyWith(color: CyberColors.secondaryCyan),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.reelsCount} reels',
                        style: CyberTypography.bodySecondary.copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 8),
                      CyberButton(
                        label: 'USE AUDIO',
                        isSmall: true,
                        isSecondary: true,
                        onPressed: widget.onUseAudio,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Interactive Audio Waveform Scrubber
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: CyberColors.surfaceDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CyberColors.borderSubtle),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isPlaying = !_isPlaying),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: CyberColors.pinkGlow,
                      boxShadow: CyberColors.pinkGlowShadow(blur: 8),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CyberWaveformWidget(
                    isPlaying: _isPlaying,
                    color: CyberColors.primaryHotPink,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '0:30',
                  style: CyberTypography.hudCaption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. Reels Grid using this soundtrack
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 0.75,
              ),
              itemCount: _sampleReelThumbs.length,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _sampleReelThumbs[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: CyberColors.surfaceElevated,
                        child: const Icon(Icons.movie, color: CyberColors.textMuted),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      left: 6,
                      child: Row(
                        children: [
                          const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '${(index + 1) * 12}K',
                            style: CyberTypography.hudCaption.copyWith(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
