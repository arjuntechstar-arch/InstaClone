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
import 'ui/screens/auth_screen.dart';
import 'data/services/api_service.dart';
import 'data/models/user_model.dart';
import 'data/models/feed_model.dart';
import 'ui/core/cyber_colors.dart';
import 'ui/core/cyber_typography.dart';
import 'ui/widgets/share_post_sheet.dart';
import 'ui/widgets/story_creator_sheet.dart';
import 'ui/screens/post_detail_screen.dart';

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

    if (!userVM.isAuthenticated) {
      return AuthScreen(
        availableRoles: userVM.availableRoles,
        onLogin: (u, p) => userVM.login(u, p),
        onRegister: ({
          required username,
          required passkey,
          displayName,
          role,
        }) =>
            userVM.register(
          username: username,
          passkey: passkey,
          displayName: displayName,
          role: role,
        ),
      );
    }

    Widget body;
    switch (_currentTab) {
      case 0:
        body = HomeFeedScreen(
          posts: feedVM.posts,
          stories: feedVM.stories,
          suggestedUsers: feedVM.suggestedUsers,
          isLoading: feedVM.isLoading,
          onRefresh: () => feedVM.init(),
          onLikePost: (id) => feedVM.toggleLike(id),
          onSavePost: (id) => feedVM.toggleSave(id),
          onCommentPost: (id) => _openComments(context, id),
          onSharePost: (id) => _sharePost(context, id),
          onRepostPost: (id) => feedVM.toggleRepost(id),
          onFollowSuggestion: (u) => feedVM.toggleFollowSuggestion(u),
          onDismissSuggestion: (u) => feedVM.dismissSuggestion(u),
          onSelectSuggestedUser: (u) => _openPublicProfile(context, u.username),
          onAuthorTap: (userId) => _openPublicProfile(context, userId),
          onStorySelected: (story) => _openStoryViewer(context, feedVM, story),
          onAddStory: () => _openStoryCreator(context, feedVM, userVM),
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
          availableUsers: userVM.allUsers,
          onSelectUser: (user) => _openPublicProfile(context, user.username),
          onChatWithUser: (user) async {
            final thread = await chatVM.startChatWithUser(
              user.username,
              displayName: user.displayName,
              avatarUrl: user.avatarUrl,
            );
            if (!context.mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DirectChatThreadScreen(
                  thread: thread,
                  onSendText: (t) => chatVM.sendTextMessage(t),
                  onSendVoice: (dur, wf) => chatVM.sendVoiceMessage(dur, wf),
                  onSendHologram: (h) => chatVM.sendHologramMessage(h),
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            );
          },
          onTagSelected: (tag) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Filtered by $tag')),
            );
          },
          onItemTapped: (id) => _openPostDetailById(context, id, feedVM),
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
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Neural post published to Neo-Tokyo!')),
                );
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
          onOpenSettings: () => _openSettings(context, userVM),
          onUpdateProfile: (updates) => userVM.updateProfile(
            displayName: updates['displayName'] as String?,
            bio: updates['bio'] as String?,
            location: updates['location'] as String?,
            isPrivate: updates['isPrivate'] as bool?,
          ),
          onSwitchPersona: (username) => userVM.switchPersona(username),
          onPostSelected: (item) => _openPostDetailByGallery(context, item, feedVM),
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
    final userVM = context.read<UserViewModel>();
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
          onNewMessage: () => _openNewChatSheet(context, chatVM, userVM),
        ),
      ),
    );
  }

  void _openNewChatSheet(BuildContext context, ChatViewModel chatVM, UserViewModel userVM) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CyberColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        final allUsers = userVM.allUsers;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'START NEW ENCRYPTED LINK',
                      style: CyberTypography.hudHeader.copyWith(fontSize: 14, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'AVAILABLE NEURAL AGENTS // 1-TAP CONNECT',
                  style: CyberTypography.hudCaption.copyWith(color: CyberColors.secondaryCyan, fontSize: 10),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                  child: allUsers.isEmpty
                      ? Center(
                          child: Text(
                            'No agents discovered on neural mesh',
                            style: CyberTypography.bodySecondary,
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: allUsers.length,
                          separatorBuilder: (_, __) => const Divider(color: CyberColors.borderSubtle, height: 12),
                          itemBuilder: (ctx, index) {
                            final u = allUsers[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: CyberColors.secondaryCyan, width: 1),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: CyberColors.surfaceElevated,
                                  backgroundImage: NetworkImage(u.avatarUrl),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    '@${u.username}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  if (u.isVerified) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, color: CyberColors.secondaryCyan, size: 14),
                                  ],
                                ],
                              ),
                              subtitle: Text(
                                u.displayName,
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: CyberColors.primaryHotPink.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: CyberColors.primaryHotPink, width: 0.8),
                                ),
                                child: Text(
                                  'CONNECT',
                                  style: CyberTypography.hudCaption.copyWith(
                                    color: CyberColors.primaryHotPink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              onTap: () async {
                                Navigator.of(sheetCtx).pop();
                                final thread = await chatVM.startChatWithUser(
                                  u.username,
                                  displayName: u.displayName,
                                  avatarUrl: u.avatarUrl,
                                );
                                if (!context.mounted) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DirectChatThreadScreen(
                                      thread: thread,
                                      onSendText: (t) => chatVM.sendTextMessage(t),
                                      onSendVoice: (dur, wf) => chatVM.sendVoiceMessage(dur, wf),
                                      onSendHologram: (h) => chatVM.sendHologramMessage(h),
                                      onBack: () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openComments(BuildContext context, String postId) async {
    final comments = await ApiService().getComments(postId);
    if (!context.mounted) return;
    final feedVM = context.read<FeedViewModel>();
    final userVM = context.read<UserViewModel>();
    final currentUser = userVM.currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsDiscussionScreen(
        postId: postId,
        comments: comments,
        onAddComment: (text, {replyToId}) async {
          await ApiService().addComment(
            postId,
            text,
            replyToId: replyToId,
            user: currentUser != null
                ? {
                    'id': currentUser.id,
                    'username': currentUser.username,
                    'displayName': currentUser.displayName,
                    'avatarUrl': currentUser.avatarUrl,
                    'isVerified': currentUser.isVerified,
                  }
                : null,
          );
          feedVM.recordCommentAdded(postId);
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

  void _openSettings(BuildContext context, UserViewModel userVM) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          initialSettings: {
            ..._settings,
            'isPrivateAccount': userVM.currentUser?.isPrivate ?? false,
          },
          onUpdateSettings: (s) {
            setState(() => _settings = s);
            if (s['isPrivateAccount'] != null) {
              userVM.setAccountPrivacy(s['isPrivateAccount'] as bool);
            }
          },
          onBack: () => Navigator.of(context).pop(),
          onLogout: () {
            userVM.logout();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _openPublicProfile(BuildContext context, String userId) async {
    final userVM = context.read<UserViewModel>();
    await userVM.loadPublicProfile(userId);
    if (userVM.publicUser == null || !context.mounted) return;
    final chatVM = context.read<ChatViewModel>();
    final feedVM = context.read<FeedViewModel>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Consumer<UserViewModel>(
          builder: (context, uVM, _) {
            final profile = uVM.publicUser ?? userVM.currentUser!;
            return UserProfileScreen(
              profile: profile,
              isCurrentUser: false,
              onToggleFollow: () => uVM.toggleFollowUser(userId),
              onMessage: () => _openDirectMessagesWithUser(context, chatVM, profile.username),
              onPostSelected: (item) => _openPostDetailByGallery(context, item, feedVM),
              onBack: () => Navigator.of(context).pop(),
            );
          },
        ),
      ),
    );
  }

  void _sharePost(BuildContext context, String postId) {
    final feedVM = context.read<FeedViewModel>();
    final chatVM = context.read<ChatViewModel>();

    PostItem post;
    try {
      post = feedVM.posts.firstWhere((p) => p.id == postId);
    } catch (_) {
      post = PostItem(
        id: postId,
        author: const PostAuthor(
          id: 'u1',
          username: 'cyber_ren',
          displayName: 'Ren Tanaka',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
        ),
        mediaUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1080',
        caption: 'Neural pulse transmission #NeoTokyo',
        timestamp: 'Just now',
        likesCount: 1420,
        commentsCount: 38,
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SharePostSheet(
        post: post,
        onSend: (recipientUsername, note) {
          chatVM.sharePostToContact(recipientUsername, post, note);
        },
      ),
    );
  }

  void _openStoryCreator(BuildContext context, FeedViewModel feedVM, UserViewModel userVM) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StoryCreatorSheet(
        onPublish: ({
          required mediaUrl,
          caption,
          pollQuestion,
          pollOptions,
        }) {
          final currentUser = userVM.currentUser;
          feedVM.addStory(
            mediaUrl: mediaUrl,
            username: currentUser?.username ?? 'cyber_ren',
            avatarUrl: currentUser?.avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
            caption: caption,
            pollQuestion: pollQuestion,
            pollOptions: pollOptions,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: CyberColors.surfaceModal,
              content: Text('Story broadcast to your neural timeline! ⚡', style: CyberTypography.bodyMedium),
            ),
          );
        },
      ),
    );
  }

  void _openPostDetailById(BuildContext context, String postId, FeedViewModel feedVM) {
    PostItem post;
    try {
      post = feedVM.posts.firstWhere((p) => p.id == postId);
    } catch (_) {
      post = PostItem(
        id: postId,
        author: const PostAuthor(
          id: 'u1',
          username: 'cyber_ren',
          displayName: 'Ren Tanaka',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
        ),
        mediaUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1080',
        caption: 'Akihabara High-Voltage Grid #NeoTokyo #Cyberpunk',
        timestamp: '2 hours ago',
        likesCount: 1420,
        commentsCount: 38,
      );
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
          onLike: () => feedVM.toggleLike(post.id),
          onSave: () => feedVM.toggleSave(post.id),
          onComment: () => _openComments(context, post.id),
          onShare: () => _sharePost(context, post.id),
          onAuthorTap: () => _openPublicProfile(context, post.author.id),
        ),
      ),
    );
  }

  void _openPostDetailByGallery(BuildContext context, GalleryItem item, FeedViewModel feedVM) {
    PostItem post;
    try {
      post = feedVM.posts.firstWhere((p) => p.id == item.id);
    } catch (_) {
      post = PostItem(
        id: item.id,
        author: const PostAuthor(
          id: 'u1',
          username: 'cyber_ren',
          displayName: 'Ren Tanaka',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
        ),
        mediaUrl: item.imageUrl,
        caption: 'Holographic matrix capture // Tokyo Sector 9',
        timestamp: '3 hours ago',
        likesCount: item.likesCount,
        commentsCount: 12,
      );
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
          onLike: () => feedVM.toggleLike(post.id),
          onSave: () => feedVM.toggleSave(post.id),
          onComment: () => _openComments(context, post.id),
          onShare: () => _sharePost(context, post.id),
          onAuthorTap: () => _openPublicProfile(context, post.author.id),
        ),
      ),
    );
  }

  void _openDirectMessagesWithUser(BuildContext context, ChatViewModel chatVM, String username) {
    final thread = chatVM.openOrCreateThread(username);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DirectChatThreadScreen(
          thread: thread,
          onSendText: (t) => chatVM.sendTextMessage(t),
          onSendVoice: (dur, wf) => chatVM.sendVoiceMessage(dur, wf),
          onSendHologram: (h) => chatVM.sendHologramMessage(h),
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

