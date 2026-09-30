import 'package:flutter/material.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class NewPostPublishingScreen extends StatefulWidget {
  final String mediaUrl;
  final String filterName;
  final Future<void> Function(Map<String, dynamic> postData) onPublish;
  final VoidCallback onCancel;

  const NewPostPublishingScreen({
    super.key,
    required this.mediaUrl,
    this.filterName = 'Normal',
    required this.onPublish,
    required this.onCancel,
  });

  @override
  State<NewPostPublishingScreen> createState() => _NewPostPublishingScreenState();
}

class _NewPostPublishingScreenState extends State<NewPostPublishingScreen> {
  final TextEditingController _captionController = TextEditingController();
  String _selectedLocation = 'Shinjuku Sector 4, Neo-Tokyo';
  String _selectedAudio = 'Kavinsky - Nightcall (Synthwave Rework)';
  bool _mintAsHologram = true;
  bool _isPublishing = false;

  final List<String> _locations = [
    'Shinjuku Sector 4, Neo-Tokyo',
    'Shibuya Crossing Sky-Bridge',
    'Akihabara Level 7 Sky-Lanes',
    'Roppongi Underground Grid',
  ];

  final List<String> _audioTracks = [
    'Kavinsky - Nightcall (Synthwave Rework)',
    'Perturbator - Future Club',
    'Carpenter Brut - Turbo Killer',
    'Lorn - Acid Rain (Cyber Remix)',
  ];

  final List<String> _hashtagSuggestions = [
    '#cyberpunk',
    '#neotokyo',
    '#synthwave',
    '#nightscape',
    '#neuralnet',
  ];

  void _addHashtag(String tag) {
    setState(() {
      if (_captionController.text.isNotEmpty && !_captionController.text.endsWith(' ')) {
        _captionController.text += ' ';
      }
      _captionController.text += '$tag ';
    });
  }

  Future<void> _handlePublish() async {
    if (_isPublishing) return;
    setState(() => _isPublishing = true);

    final tags = _captionController.text
        .split(' ')
        .where((w) => w.startsWith('#'))
        .map((w) => w.replaceAll('#', ''))
        .toList();

    await widget.onPublish({
      'mediaUrl': widget.mediaUrl,
      'caption': _captionController.text.trim().isEmpty
          ? 'Neural capture from Neo-Tokyo'
          : _captionController.text.trim(),
      'location': _selectedLocation,
      'musicTrack': _selectedAudio,
      'filterName': widget.filterName,
      'tags': tags,
    });

    if (mounted) {
      setState(() => _isPublishing = false);
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      appBar: AppBar(
        backgroundColor: CyberColors.bgVoid,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onCancel,
        ),
        title: Text(
          'NEW NEURAL POST',
          style: CyberTypography.hudHeader.copyWith(color: Colors.white, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CyberButton(
              label: 'SHARE',
              isSmall: true,
              isLoading: _isPublishing,
              onPressed: _handlePublish,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Media Thumbnail & Caption Field
            CyberCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail preview with neon frame
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CyberColors.secondaryCyan, width: 1.2),
                      boxShadow: CyberColors.cyanGlowShadow(blur: 6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            widget.mediaUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.image, color: CyberColors.textMuted),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              color: Colors.black87,
                              child: Text(
                                widget.filterName,
                                style: const TextStyle(fontSize: 8, color: CyberColors.secondaryCyan),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Caption input
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      maxLines: 3,
                      style: CyberTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Describe this neural transmission...',
                        hintStyle: CyberTypography.bodySecondary,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. Hashtag Quick Suggestions
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _hashtagSuggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tag = _hashtagSuggestions[index];
                  return GestureDetector(
                    onTap: () => _addHashtag(tag),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: CyberColors.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CyberColors.borderSubtle),
                      ),
                      child: Text(
                        tag,
                        style: CyberTypography.hudCaption.copyWith(
                          color: CyberColors.secondaryCyan,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 3. Location Selector
            Text('LOCATION TAG', style: CyberTypography.hudCaption.copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 8),
            CyberCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLocation,
                  isExpanded: true,
                  dropdownColor: CyberColors.surfaceModal,
                  icon: const Icon(Icons.arrow_drop_down, color: CyberColors.secondaryCyan),
                  items: _locations.map((loc) {
                    return DropdownMenuItem<String>(
                      value: loc,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: CyberColors.primaryHotPink, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(loc, style: CyberTypography.bodyMedium),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLocation = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 4. Soundtrack Audio Selector
            Text('AUDIO TRACK', style: CyberTypography.hudCaption.copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 8),
            CyberCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAudio,
                  isExpanded: true,
                  dropdownColor: CyberColors.surfaceModal,
                  icon: const Icon(Icons.arrow_drop_down, color: CyberColors.secondaryCyan),
                  items: _audioTracks.map((trk) {
                    return DropdownMenuItem<String>(
                      value: trk,
                      child: Row(
                        children: [
                          const Icon(Icons.music_note, color: CyberColors.secondaryCyan, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(trk, style: CyberTypography.bodyMedium),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAudio = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 5. Hologram Collectible Toggle
            CyberCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              borderColor: _mintAsHologram ? CyberColors.primaryHotPink : CyberColors.borderSubtle,
              hasGlow: _mintAsHologram,
              child: Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: CyberColors.primaryHotPink,
                  activeTrackColor: CyberColors.primaryHotPink.withValues(alpha: 0.4),
                  title: Text(
                    'Mint as Digital Hologram',
                    style: CyberTypography.bodyBold.copyWith(fontSize: 13),
                  ),
                  subtitle: Text(
                    'Registers neural fingerprint onto the public Shibuya Sky-Grid ledger.',
                    style: CyberTypography.bodySecondary.copyWith(fontSize: 11),
                  ),
                  value: _mintAsHologram,
                  onChanged: (v) => setState(() => _mintAsHologram = v),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 6. Transmit Button
            CyberButton(
              width: double.infinity,
              label: 'TRANSMIT TO FEED',
              isLoading: _isPublishing,
              onPressed: _handlePublish,
            ),
          ],
        ),
      ),
    );
  }
}
