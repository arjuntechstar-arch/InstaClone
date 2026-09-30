import { seedData } from "./seedData.js";

class TokyoStore {
  constructor() {
    this.reset();
  }

  reset() {
    this.data = JSON.parse(JSON.stringify(seedData));
  }

  // --- Current User ---
  getCurrentUser() {
    return this.data.currentUser;
  }

  updateCurrentUser(updates) {
    this.data.currentUser = { ...this.data.currentUser, ...updates };
    return this.data.currentUser;
  }

  // --- Users & Public Profiles ---
  getUsers() {
    return this.data.users;
  }

  getUserByUsername(username) {
    if (username === this.data.currentUser.username) {
      return this.data.currentUser;
    }
    return this.data.users.find(u => u.username.toLowerCase() === username.toLowerCase()) || null;
  }

  toggleFollowUser(username) {
    const user = this.data.users.find(u => u.username.toLowerCase() === username.toLowerCase());
    if (!user) return null;
    user.isFollowing = !user.isFollowing;
    if (user.isFollowing) {
      user.synapsesCount += 1;
      this.data.currentUser.followingCount += 1;
    } else {
      user.synapsesCount = Math.max(0, user.synapsesCount - 1);
      this.data.currentUser.followingCount = Math.max(0, this.data.currentUser.followingCount - 1);
    }
    return user;
  }

  // --- Feed Posts ---
  getFeed() {
    return this.data.feedPosts;
  }

  getPost(id) {
    return this.data.feedPosts.find(p => p.id === id) || null;
  }

  togglePostLike(postId) {
    const post = this.getPost(postId);
    if (!post) return null;
    post.isLiked = !post.isLiked;
    post.likesCount += post.isLiked ? 1 : -1;
    return post;
  }

  togglePostSave(postId) {
    const post = this.getPost(postId);
    if (!post) return null;
    post.isSaved = !post.isSaved;
    return post;
  }

  createPost(postData) {
    const newPost = {
      id: "post_" + Date.now(),
      creatorId: this.data.currentUser.id,
      creatorUsername: this.data.currentUser.username,
      creatorAvatar: this.data.currentUser.avatar,
      isVerified: this.data.currentUser.isVerified,
      location: postData.location || "Neo-Tokyo Grid",
      mediaUrl: postData.mediaUrl || "https://lh3.googleusercontent.com/aida/AEtjO1WUt3nQKGKSImsSwuvfxBUwJhgNTnkbjrooIsZ_KmOw-SYqCgNre8XgPfXf8WUjRYTr6o211sJ_nsVgNjkGnQUMw-LvGVwAmBOuqDkt-JHIrN3gVaEd0jvbJsz3QkvyZIThkDyT6GyCoLRrPVDoOxAfSxknZu5dUW-7F1X2duEV3T_Y9C1DABFrrYB5jYcZsMk5ShHI1IhAK0m4qhCcGaP8aMcPBytX3gjynIO33mxyFF1N2X6_sw2BM1I",
      aspectRatio: postData.aspectRatio || "4:5",
      audioTrack: postData.audioTrack || "Kavinsky • Nightcall (Remix)",
      hudStamp: "REC // 60FPS • 4K",
      likesCount: 0,
      isLiked: false,
      commentsCount: 0,
      isSaved: false,
      caption: postData.caption || "",
      tags: postData.tags || [],
      timeAgo: "JUST NOW",
      crossPosting: postData.crossPosting || { fediverse: true, cyberThreads: true, mintNft: false },
      createdAt: new Date().toISOString()
    };
    this.data.feedPosts.unshift(newPost);
    this.data.currentUser.postsCount += 1;
    return newPost;
  }

  // --- Stories ---
  getStories() {
    return this.data.stories;
  }

  getStory(id) {
    return this.data.stories.find(s => s.id === id) || null;
  }

  voteStoryPoll(storyId, segmentId, choice) {
    const story = this.getStory(storyId);
    if (!story) return null;
    const segment = story.segments.find(s => s.id === segmentId);
    if (!segment || !segment.poll) return null;
    if (choice === 'a') {
      segment.poll.optionA.votes += 1;
    } else if (choice === 'b') {
      segment.poll.optionB.votes += 1;
    }
    segment.poll.totalVotes += 1;
    segment.poll.userVoted = choice;
    return segment.poll;
  }

  // --- Reels ---
  getReels() {
    return this.data.reels;
  }

  toggleReelLike(id) {
    const reel = this.data.reels.find(r => r.id === id);
    if (!reel) return null;
    reel.isLiked = !reel.isLiked;
    reel.likesCount += reel.isLiked ? 1 : -1;
    return reel;
  }

  toggleReelFollow(creatorId) {
    const reel = this.data.reels.find(r => r.creatorId === creatorId);
    if (reel) {
      reel.isFollowing = !reel.isFollowing;
    }
    return reel;
  }

  // --- Explore & Search ---
  getExplore(category) {
    const result = { ...this.data.exploreMosaic };
    if (category && category !== "All Matrix") {
      result.items = result.items.filter(item => 
        (item.tag && item.tag.toLowerCase().includes(category.toLowerCase())) ||
        (item.badge && item.badge.toLowerCase().includes(category.toLowerCase()))
      );
    }
    return result;
  }

  search(query) {
    const q = (query || "").toLowerCase();
    const matchedUsers = this.data.users.filter(u => 
      u.username.toLowerCase().includes(q) || 
      u.displayName.toLowerCase().includes(q) ||
      u.bio.toLowerCase().includes(q)
    );
    const matchedPosts = this.data.feedPosts.filter(p =>
      p.caption.toLowerCase().includes(q) ||
      p.tags.some(t => t.toLowerCase().includes(q))
    );
    const matchedExplore = this.data.exploreMosaic.items.filter(item =>
      (item.tag && item.tag.toLowerCase().includes(q)) ||
      (item.author && item.author.toLowerCase().includes(q))
    );
    return {
      users: matchedUsers,
      posts: matchedPosts,
      exploreItems: matchedExplore
    };
  }

  // --- Comments ---
  getComments(postId) {
    return this.data.comments[postId] || [];
  }

  addComment(postId, { text, parentCommentId }) {
    if (!this.data.comments[postId]) {
      this.data.comments[postId] = [];
    }
    const user = this.data.currentUser;
    const post = this.getPost(postId);
    if (post) post.commentsCount += 1;

    if (parentCommentId) {
      const parent = this.data.comments[postId].find(c => c.id === parentCommentId);
      if (parent) {
        const reply = {
          id: "reply_" + Date.now(),
          userId: user.id,
          username: user.username,
          avatar: user.avatar,
          isOP: user.username === post?.creatorUsername,
          text,
          likesCount: 0,
          timeAgo: "Just now"
        };
        parent.replies.push(reply);
        return reply;
      }
    }

    const newComment = {
      id: "comm_" + Date.now(),
      userId: user.id,
      username: user.username,
      avatar: user.avatar,
      isPinned: false,
      text,
      likesCount: 0,
      timeAgo: "Just now",
      replies: []
    };
    this.data.comments[postId].push(newComment);
    return newComment;
  }

  // --- Direct Messages ---
  getDirectThreads(category) {
    if (category && category !== "All") {
      return this.data.directThreads.filter(t => t.category === category);
    }
    return this.data.directThreads;
  }

  getThread(threadId) {
    return this.data.directThreads.find(t => t.id === threadId) || null;
  }

  sendDirectMessage(threadId, msgData) {
    const thread = this.getThread(threadId);
    if (!thread) return null;
    const newMsg = {
      id: "msg_" + Date.now(),
      senderId: this.data.currentUser.id,
      text: msgData.text || "",
      type: msgData.type || "text",
      mediaUrl: msgData.mediaUrl || null,
      fileName: msgData.fileName || null,
      fileSize: msgData.fileSize || null,
      duration: msgData.duration || null,
      waveform: msgData.waveform || null,
      time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      status: "delivered"
    };
    thread.messages.push(newMsg);
    thread.lastMessage = msgData.text || (msgData.type === 'hologram' ? 'Sent a hologram clip' : 'Sent audio memo');
    thread.lastTime = "Just now";
    return newMsg;
  }

  // --- Notifications ---
  getNotifications() {
    return this.data.notifications;
  }

  toggleFollowBack(username) {
    const item = this.data.notifications.today.find(n => n.actor.username === username);
    if (item && item.canFollowBack) {
      item.isFollowing = !item.isFollowing;
      return item;
    }
    return null;
  }

  // --- Audio ---
  getAudio() {
    return this.data.audioTrack;
  }

  toggleSaveAudio() {
    this.data.audioTrack.isSaved = !this.data.audioTrack.isSaved;
    return this.data.audioTrack;
  }

  // --- Shop & Marketplace ---
  getShop(category) {
    return this.data.shop;
  }

  toggleWishlist(prodId) {
    const trending = this.data.shop.trendingDrops.find(p => p.id === prodId);
    if (trending) {
      trending.isWishlist = !trending.isWishlist;
      return trending;
    }
    return null;
  }

  // --- Saved Collections ---
  getCollections() {
    return this.data.collections;
  }

  createFolder({ title, isPrivate, badge }) {
    const newFolder = {
      id: "col_" + Date.now(),
      title,
      isPrivate: !!isPrivate,
      badge: badge || null,
      itemsCount: 0,
      nodeLabel: `Node #${String(this.data.collections.folders.length + 1).padStart(2, '0')}`,
      thumbnails: []
    };
    this.data.collections.folders.unshift(newFolder);
    return newFolder;
  }

  // --- Live Stream ---
  getLiveStream() {
    return this.data.liveStream;
  }

  sendLiveChat({ text, user }) {
    const chatMsg = {
      id: "chat_" + Date.now(),
      user: user || this.data.currentUser.username,
      text
    };
    this.data.liveStream.chat.push(chatMsg);
    if (this.data.liveStream.chat.length > 20) {
      this.data.liveStream.chat.shift();
    }
    return chatMsg;
  }

  sendLiveGift({ amount, label }) {
    const gift = {
      id: "gift_" + Date.now(),
      user: this.data.currentUser.username,
      amount: amount || 500,
      label: label || "Cyber-Bits"
    };
    this.data.liveStream.gifts.push(gift);
    return gift;
  }

  voteLivePoll(choice) {
    const poll = this.data.liveStream.pinnedPoll;
    if (choice === 'a') {
      poll.optionA.votes += 1;
    } else {
      poll.optionB.votes += 1;
    }
    return poll;
  }

  // --- Settings ---
  getSettings() {
    return this.data.settings;
  }

  updateSettings(updates) {
    this.data.settings = { ...this.data.settings, ...updates };
    return this.data.settings;
  }
}

export const store = new TokyoStore();
