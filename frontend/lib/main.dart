import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/core/cyber_theme.dart';
import 'viewmodels/feed_viewmodel.dart';
import 'viewmodels/reel_viewmodel.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'viewmodels/live_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';
import 'viewmodels/shop_viewmodel.dart';
import 'ui/screens/main_shell_screen.dart';
import 'ui/screens/home_feed_screen.dart';
import 'ui/screens/explore_screen.dart';
import 'ui/screens/create_camera_screen.dart';
import 'ui/screens/new_post_publishing_screen.dart';
import 'ui/screens/reels_screen.dart';
import 'ui/screens/user_profile_screen.dart';
import 'ui/screens/story_viewer_screen.dart';
import 'ui/screens/direct_messages_screen.dart';
import 'ui/screens/direct_chat_thread_screen.dart';
import 'ui/screens/comments_discussion_screen.dart';
import 'ui/screens/live_stream_viewer_screen.dart';
import 'ui/screens/shop_marketplace_screen.dart';
import 'ui/screens/saved_collections_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'data/services/api_service.dart';
import 'data/models/user_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TokyoGramApp());
}

class TokyoGramApp extends StatelessWidget {
  const TokyoGramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FeedViewModel()..init()),
        ChangeNotifierProvider(create: (_) => ReelViewModel()..init()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()..init()),
        ChangeNotifierProvider(create: (_) => LiveViewModel()..init()),
        ChangeNotifierProvider(create: (_) => UserViewModel()..init()),
        ChangeNotifierProvider(create: (_) => ShopViewModel()..init()),
      ],
      child: MaterialApp(
        title: 'TOKYO.GRAM',
        debugShowCheckedModeBanner: false,
        theme: CyberTheme.darkTheme,
        home: const TokyoGramRootView(),
      ),
    );
  }
}

class TokyoGramRootView extends StatefulWidget {
  const TokyoGramRootView({super.key});

  @override
  State<TokyoGramRootView> createState() => _TokyoGramRootViewState();
}

class _TokyoGramRootViewState extends State<TokyoGramRootView> {
  int _currentTab = 0;
  Map<String, dynamic>? _pendingCapture;
  Map<String, dynamic> _settings = {
    'quantumEncryption': true,
    'hologramPreview': true,
    'biometricAuth': true,
    'hapticFeedback': true,
    'stealthMode': false,
    'cyberOpticsMode': 'Neon Vivid',
  };

  @override
  Widget build(BuildContext context) {
    final feedVM = context.watch<FeedViewModel>();
    final reelVM = context.watch<ReelViewModel>();
    final chatVM = context.watch<ChatViewModel>();
    final liveVM = context.watch<LiveViewModel>();
    final userVM = context.watch<UserViewModel>();
    final shopVM = context.watch<ShopViewModel>();

    Widget body;
    switch (_currentTab) {
      case 0:
        body = HomeFeedScreen(
          posts: feedVM.posts,
          stories: feedVM.stories,
          isLoading: feedVM.isLoading,
          onRefresh: () => feedVM.init(),
          onLikePost: (id) => feedVM.toggleLike(id),
          onSavePost: (id) => feedVM.toggleSave(id),
          onCommentPost: (id) => _openComments(context, id),
          onSharePost: (id) => _sharePost(context, id),
          onAuthorTap: (userId) => _openPublicProfile(context, userId),
          onStorySelected: (story) => _openStoryViewer(context, feedVM, story),
          onAddStory: () => setState(() => _currentTab = 2),
          onOpenDMs: () => _openDirectMessages(context, chatVM),
          onOpenNotifications: () => _openNotificationsSheet(context),
          onOpenLiveStream: () => _openLiveStream(context, liveVM),
          onOpenCreateCamera: () => setState(() => _currentTab = 2),
        );
        break;

      case 1:
        body = ExploreScreen(
          exploreData: {
            'trendingTags': ['#NeoTokyo', '#CyberdeckMod', '#SynthwaveBeats', '#HoloFashion', '#NeuralArt'],
            'gridItems': feedVM.posts.map((p) => {
              'id': p.id,
              'type': p.filterName == 'Normal' ? 'image' : 'video',
              'imageUrl': p.mediaUrl,
              'likesCount': p.likesCount,
            }).toList(),
          },
          onTagSelected: (tag) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Filtered by $tag')),
            );
          },
          onItemTapped: (id) => _openComments(context, id),
        );
        break;

      case 2:
        if (_pendingCapture != null) {
          body = NewPostPublishingScreen(
            mediaUrl: _pendingCapture!['mediaUrl'] as String,
            filterName: _pendingCapture!['filterName'] as String,
            onCancel: () => setState(() => _pendingCapture = null),
            onPublish: (postData) async {
              final ok = await feedVM.addNewPost(
                caption: postData['caption'] as String,
                mediaUrl: postData['mediaUrl'] as String,
                location: postData['location'] as String?,
                musicTrack: postData['musicTrack'] as String?,
                filterName: postData['filterName'] as String?,
                tags: List<String>.from(postData['tags'] as List),
              );
              if (ok) {
                setState(() {
                  _pendingCapture = null;
                  _currentTab = 0;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Neural post published to Neo-Tokyo!')),
                  );
                }
              }
            },
          );
        } else {
          body = CreateCameraScreen(
            onClose: () => setState(() => _currentTab = 0),
            onCapture: (capturedData) {
              setState(() => _pendingCapture = capturedData);
            },
          );
        }
        break;

      case 3:
        body = ReelsScreen(
          reels: reelVM.reels,
          onLike: (id) => reelVM.toggleLike(id),
          onSave: (id) => reelVM.toggleSave(id),
          onFollow: (id) => reelVM.toggleFollow(id),
          onComment: (id) => _openComments(context, id),
          onShare: (id) => _sharePost(context, id),
          onCameraTap: () => setState(() => _currentTab = 2),
        );
        break;

      case 4:
        body = UserProfileScreen(
          profile: userVM.currentUser ??
              UserProfile(
                id: 'u1',
                username: 'cyber_ren',
                displayName: 'Ren Tanaka',
                avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
                bio: 'Cybernetic optics architect & nightscape photographer. ⚡🌆',
                followersCount: 142800,
                followingCount: 492,
                postsCount: 187,
                isVerified: true,
                badge: 'VERIFIED CREATOR',
              ),
          isCurrentUser: true,
          onOpenSaved: () => _openSavedCollections(context, shopVM),
          onOpenShop: () => _openShop(context, shopVM),
          onOpenSettings: () => _openSettings(context),
        );
        break;

      default:
        body = const SizedBox.shrink();
    }

    return MainShellScreen(
      currentIndex: _currentTab,
      onTabSelected: (index) {
        setState(() {
          _pendingCapture = null;
          _currentTab = index;
        });
      },
      currentScreen: body,
    );
  }

  void _openStoryViewer(BuildContext context, FeedViewModel feedVM, dynamic story) {
    final stories = feedVM.stories;
    final initialIndex = stories.indexOf(story);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryViewerScreen(
          stories: stories,
          initialIndex: initialIndex >= 0 ? initialIndex : 0,
          onVotePoll: (storyId, optionIndex) {
            feedVM.voteStoryPoll(storyId, optionIndex);
          },
        ),
      ),
    );
  }

  void _openDirectMessages(BuildContext context, ChatViewModel chatVM) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DirectMessagesScreen(
          threads: chatVM.threads,
          onSelectThread: (threadId) {
            chatVM.selectThread(threadId);
            if (chatVM.activeThread != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DirectChatThreadScreen(
                    thread: chatVM.activeThread!,
                    onSendText: (t) => chatVM.sendTextMessage(t),
                    onSendVoice: (dur, wf) => chatVM.sendVoiceMessage(dur, wf),
                    onSendHologram: (h) => chatVM.sendHologramMessage(h),
                    onBack: () => Navigator.of(context).pop(),
                  ),
                ),
              );
            }
          },
          onBack: () => Navigator.of(context).pop(),
          onNewMessage: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Frequency scan ready')),
            );
          },
        ),
      ),
    );
  }

  void _openComments(BuildContext context, String postId) async {
    final comments = await ApiService().getComments(postId);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsDiscussionScreen(
        postId: postId,
        comments: comments,
        onAddComment: (text, {replyToId}) async {
          await ApiService().addComment(postId, text, replyToId: replyToId);
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _openNotificationsSheet(BuildContext context) async {
    final notifications = await ApiService().getNotifications();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CyberTheme.darkTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NEURAL ACTIVITY NOTIFICATIONS',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, idx) {
                  final n = notifications[idx];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(n.actor.avatarUrl),
                    ),
                    title: Text('${n.actor.username} ${n.message}'),
                    subtitle: Text(n.timestamp),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLiveStream(BuildContext context, LiveViewModel liveVM) {
    if (liveVM.stream == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveStreamViewerScreen(
          stream: liveVM.stream!,
          floatingReactions: liveVM.floatingReactions,
          onSendReaction: (r) => liveVM.sendReaction(r),
          onSendChat: (t, {giftType}) => liveVM.sendChatMessage(t, giftType: giftType),
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _openShop(BuildContext context, ShopViewModel shopVM) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShopMarketplaceScreen(
          products: shopVM.filteredProducts,
          selectedCategory: shopVM.selectedCategory,
          onSelectCategory: (cat) => shopVM.filterCategory(cat),
          onToggleWishlist: (id) => shopVM.toggleWishlist(id),
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _openSavedCollections(BuildContext context, ShopViewModel shopVM) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SavedCollectionsScreen(
          collections: shopVM.collections,
          onAddCollection: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New vault folder created')),
            );
          },
          onSelectCollection: (id) {},
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          initialSettings: _settings,
          onUpdateSettings: (s) => setState(() => _settings = s),
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _openPublicProfile(BuildContext context, String userId) async {
    final profile = await ApiService().getUserProfile(userId);
    if (profile == null || !context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          profile: profile,
          isCurrentUser: false,
          onToggleFollow: () => ApiService().toggleFollow(userId),
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _sharePost(BuildContext context, String postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Neural beam transmitted for post $postId')),
    );
  }
}
