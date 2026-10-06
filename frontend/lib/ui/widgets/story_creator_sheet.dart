import 'package:flutter/material.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

/// Modal bottom sheet allowing users to compose and publish an interactive Story with optional Poll
class StoryCreatorSheet extends StatefulWidget {
  final Function({
    required String mediaUrl,
    String? caption,
    String? pollQuestion,
    List<String>? pollOptions,
  }) onPublish;

  const StoryCreatorSheet({
    super.key,
    required this.onPublish,
  });

  @override
  State<StoryCreatorSheet> createState() => _StoryCreatorSheetState();
}

class _StoryCreatorSheetState extends State<StoryCreatorSheet> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _pollQuestionController = TextEditingController();
  final TextEditingController _opt1Controller = TextEditingController(text: 'OVERCLOCK ⚡');
  final TextEditingController _opt2Controller = TextEditingController(text: 'COOLDOWN ❄️');

  bool _includePoll = true;
  int _selectedBackgroundIndex = 0;

  final List<String> _sampleBackgrounds = [
    'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1080',
    'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1080',
    'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=1080',
    'https://images.unsplash.com/photo-1542051841857-5f90071e7989?w=1080',
  ];

  @override
  void dispose() {
    _captionController.dispose();
    _pollQuestionController.dispose();
    _opt1Controller.dispose();
    _opt2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: CyberColors.surfaceModal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: CyberColors.primaryHotPink, width: 1.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CyberColors.borderHighlight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MINT NEURAL STORY',
                  style: CyberTypography.hudHeader.copyWith(
                    color: CyberColors.primaryHotPink,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: CyberColors.textSecondary, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Background preview picker
            Text('SELECT HOLOGRAM FEED', style: CyberTypography.hudCaption.copyWith(fontSize: 10)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _sampleBackgrounds.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSel = index == _selectedBackgroundIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBackgroundIndex = index),
                    child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSel ? CyberColors.primaryHotPink : CyberColors.borderSubtle,
                          width: isSel ? 2 : 1,
                        ),
                        boxShadow: isSel ? CyberColors.pinkGlowShadow(blur: 8) : null,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        _sampleBackgrounds[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Caption Field
            Text('STORY CAPTION', style: CyberTypography.hudCaption.copyWith(fontSize: 10)),
            const SizedBox(height: 6),
            TextField(
              controller: _captionController,
              style: CyberTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Transmit ephemeral thought to timeline...',
                hintStyle: CyberTypography.bodySecondary,
                filled: true,
                fillColor: CyberColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CyberColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CyberColors.secondaryCyan),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 16),

            // Poll Toggle & Setup
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.poll_outlined, color: CyberColors.secondaryCyan, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'ATTACH INTERACTIVE POLL',
                      style: CyberTypography.hudHeader.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                Switch(
                  value: _includePoll,
                  activeColor: CyberColors.secondaryCyan,
                  onChanged: (v) => setState(() => _includePoll = v),
                ),
              ],
            ),

            if (_includePoll) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _pollQuestionController,
                style: CyberTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Poll Question (e.g. Overclock quantum rig?)',
                  hintStyle: CyberTypography.bodySecondary,
                  filled: true,
                  fillColor: CyberColors.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: CyberColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: CyberColors.secondaryCyan),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _opt1Controller,
                      style: CyberTypography.bodyMedium.copyWith(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Option 1',
                        filled: true,
                        fillColor: CyberColors.surfaceDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: CyberColors.borderSubtle),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _opt2Controller,
                      style: CyberTypography.bodyMedium.copyWith(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Option 2',
                        filled: true,
                        fillColor: CyberColors.surfaceDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: CyberColors.borderSubtle),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: CyberButton(
                label: 'BROADCAST STORY TO TIMELINE',
                onPressed: () {
                  final media = _sampleBackgrounds[_selectedBackgroundIndex];
                  final caption = _captionController.text.trim();
                  final pollQ = _pollQuestionController.text.trim().isNotEmpty
                      ? _pollQuestionController.text.trim()
                      : (_includePoll ? 'Overclock quantum cyberdeck tonight?' : null);
                  final pollOpts = _includePoll
                      ? [
                          _opt1Controller.text.trim().isNotEmpty ? _opt1Controller.text.trim() : 'YES ⚡',
                          _opt2Controller.text.trim().isNotEmpty ? _opt2Controller.text.trim() : 'NO ❄️',
                        ]
                      : null;

                  widget.onPublish(
                    mediaUrl: media,
                    caption: caption.isNotEmpty ? caption : null,
                    pollQuestion: pollQ,
                    pollOptions: pollOpts,
                  );
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
