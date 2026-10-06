import { seedData } from "./seedData.js";

class TokyoStore {
  constructor() {
    this.reset();
  }

  reset() {
    this.data = JSON.parse(JSON.stringify(seedData));
  }

  // --- Accounts & Authentication ---
  getAccounts() {
    return this.data.accounts || [];
  }

  authenticate(username, passkey) {
    const account = this.getAccounts().find(
      a => a.username.toLowerCase() === username.toLowerCase() && a.passkey === passkey
    );
    if (!account) return null;
    this.data.currentUser = { ...account };
    return account;
  }

  registerAccount(accountData) {
    const existing = this.getAccounts().find(
      a => a.username.toLowerCase() === accountData.username.toLowerCase()
    );
    if (existing) {
      return { error: "Neural ID already registered on grid" };
    }

    const newAccount = {
      id: "u_" + Date.now(),
      username: accountData.username,
      passkey: accountData.passkey || "tokyo_pass_2088",
      displayName: accountData.displayName || accountData.username,
      role: accountData.role || "Cyber Explorer",
      accessLevel: accountData.accessLevel || 2,
      avatar: accountData.avatar || "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300",
      bio: accountData.bio || "Newly connected to the Tokyo.Gram grid. ⚡",
      link: `holo.grid/${accountData.username}`,
      postsCount: 0,
      followersCount: 1,
      followingCount: 1,
      isVerified: false,
      badge: "INITIATE",
      nodeId: `NODE #NEO-${Math.floor(1000 + Math.random() * 9000)}`,
      syncRate: "95.0%",
      currentNote: "Online // Handshake OK"
    };

    if (!this.data.accounts) this.data.accounts = [];
    this.data.accounts.push(newAccount);
    this.data.currentUser = { ...newAccount };
    return { account: newAccount };
  }

  switchCurrentUser(username) {
    const account = this.getAccounts().find(
      a => a.username.toLowerCase() === username.toLowerCase()
    );
    if (account) {
      this.data.currentUser = { ...account };
      return this.data.currentUser;
    }
    return null;
  }

  // --- Current User ---
  getCurrentUser() {
    return this.data.currentUser;
  }

  updateCurrentUser(updates) {
    this.data.currentUser = { ...this.data.currentUser, ...updates };
    const username = (this.data.currentUser.username || "").toLowerCase();
    const acc = (this.data.accounts || []).find(a => a.username.toLowerCase() === username);
    if (acc) {
      Object.assign(acc, updates);
    }
    const u = (this.data.users || []).find(u => u.username.toLowerCase() === username);
    if (u) {
      Object.assign(u, updates);
    }
    return this.data.currentUser;
  }

  // --- Users & Public Profiles ---
  getUsers() {
    const map = new Map();
    // 1. Add all accounts (personas + registered)
    (this.data.accounts || []).forEach(acc => {
      map.set(acc.username.toLowerCase(), {
        id: acc.id,
        username: acc.username,
        displayName: acc.displayName || acc.username,
        category: acc.role || acc.category || "Cyber Resident",
        subNet: "Neo-Tokyo Sector 4",
        bio: acc.bio || "Active node on Tokyo.Gram grid. ⚡",
        avatar: acc.avatar,
        avatarUrl: acc.avatar,
        nodesCount: acc.postsCount || 0,
        synapsesCount: acc.followersCount || 10,
        linkedCount: acc.followingCount || 5,
        isVerified: !!acc.isVerified,
        isFollowing: false,
        badge: acc.badge || "VERIFIED NODE",
        currentNote: acc.currentNote || "Online // Handshake OK"
      });
    });
    // 2. Add or overlay users
    (this.data.users || []).forEach(u => {
      const existing = map.get(u.username.toLowerCase());
      if (existing) {
        map.set(u.username.toLowerCase(), { ...existing, ...u, avatarUrl: u.avatar || existing.avatar });
      } else {
        map.set(u.username.toLowerCase(), { ...u, avatarUrl: u.avatar });
      }
    });
    return Array.from(map.values());
  }

  getUserByUsername(username) {
    if (!username) return null;
    if (this.data.currentUser && this.data.currentUser.username.toLowerCase() === username.toLowerCase()) {
      return this.data.currentUser;
    }
    return this.getUsers().find(u => u.username.toLowerCase() === username.toLowerCase()) || null;
  }

  toggleFollowUser(username) {
    const user = this.data.users.find(u => u.username.toLowerCase() === username.toLowerCase());
    if (!user) {
      // Check in accounts/allUsers
      const anyUser = this.getUserByUsername(username);
      if (!anyUser) return null;
      anyUser.isFollowing = !anyUser.isFollowing;
      anyUser.synapsesCount = (anyUser.synapsesCount || 0) + (anyUser.isFollowing ? 1 : -1);
      return anyUser;
    }
    if (user.isPrivate && !user.isFollowing) {
      user.isFollowRequested = !user.isFollowRequested;
      return user;
    }
    user.isFollowing = !user.isFollowing;
    if (user.isFollowing) {
      user.synapsesCount += 1;
      this.data.currentUser.followingCount += 1;
    } else {
      user.synapsesCount = Math.max(0, user.synapsesCount - 1);
      this.data.currentUser.followingCount = Math.max(0, this.data.currentUser.followingCount - 1);
    }
    user.isFollowRequested = false;
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

  togglePostRepost(postId) {
    const post = this.getPost(postId);
    if (!post) return null;
    post.isReposted = !post.isReposted;
    post.repostsCount = (post.repostsCount || 0) + (post.isReposted ? 1 : -1);
    if (post.repostsCount < 0) post.repostsCount = 0;
    return post;
  }

  getSuggestedUsers() {
    const currentUsername = ((this.data.currentUser && this.data.currentUser.username) || "").toLowerCase();
    return (this.data.users || []).filter(u => u.username.toLowerCase() !== currentUsername);
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
    const allUsers = this.getUsers();
    const matchedUsers = q.isEmpty
        ? allUsers
        : allUsers.filter(u => 
            (u.username && u.username.toLowerCase().includes(q)) || 
            (u.displayName && u.displayName.toLowerCase().includes(q)) ||
            (u.bio && u.bio.toLowerCase().includes(q)) ||
            (u.category && u.category.toLowerCase().includes(q))
          );
    const matchedPosts = this.data.feedPosts.filter(p =>
      (p.caption && p.caption.toLowerCase().includes(q)) ||
      (p.tags && p.tags.some(t => t.toLowerCase().includes(q)))
    );
    const matchedExplore = (this.data.exploreMosaic?.items || []).filter(item =>
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
  _normalizeComment(c, postId) {
    const authorObj = c.author || {
      id: c.userId || "u_anon",
      username: c.username || "anon",
      displayName: c.displayName || c.username || "Anonymous",
      avatarUrl: c.avatar || c.avatarUrl || "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150",
      isVerified: !!c.isVerified
    };
    return {
      id: c.id,
      postId: c.postId || postId,
      author: authorObj,
      userId: c.userId || authorObj.id,
      username: c.username || authorObj.username,
      avatar: c.avatar || authorObj.avatarUrl,
      text: c.text,
      timestamp: c.timestamp || c.timeAgo || "Just now",
      timeAgo: c.timeAgo || c.timestamp || "Just now",
      likesCount: c.likesCount || 0,
      isLiked: !!c.isLiked,
      isPinned: !!c.isPinned,
      replies: (c.replies || []).map(r => this._normalizeComment(r, postId))
    };
  }

  getComments(postId) {
    const list = this.data.comments[postId] || [];
    return list.map(c => this._normalizeComment(c, postId));
  }

  addComment(postId, { text, parentCommentId, user }) {
    if (!this.data.comments[postId]) {
      this.data.comments[postId] = [];
    }
    const authorUser = user || this.data.currentUser || {
      id: "u1",
      username: "cyber_ren",
      displayName: "Ren Tanaka",
      avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150",
      isVerified: true
    };
    const post = this.getPost(postId);
    if (post) post.commentsCount += 1;

    const newComment = {
      id: "comm_" + Date.now(),
      postId,
      author: {
        id: authorUser.id || "u_" + (authorUser.username || "anon"),
        username: authorUser.username || "cyber_ren",
        displayName: authorUser.displayName || authorUser.username || "Ren Tanaka",
        avatarUrl: authorUser.avatarUrl || authorUser.avatar || "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150",
        isVerified: !!authorUser.isVerified
      },
      userId: authorUser.id,
      username: authorUser.username,
      avatar: authorUser.avatar || authorUser.avatarUrl,
      isPinned: false,
      text,
      likesCount: 0,
      isLiked: false,
      timeAgo: "Just now",
      timestamp: "Just now",
      replies: []
    };

    if (parentCommentId) {
      const parent = this.data.comments[postId].find(c => c.id === parentCommentId);
      if (parent) {
        if (!parent.replies) parent.replies = [];
        parent.replies.push(newComment);
        return this._normalizeComment(newComment, postId);
      }
    }

    this.data.comments[postId].unshift(newComment);
    return this._normalizeComment(newComment, postId);
  }

  // --- Direct Messages ---
  _normalizeThread(t) {
    const p = t.participant || t.user || {};
    const userObj = {
      id: p.id || "u_anon",
      username: p.username || "unknown",
      displayName: p.displayName || p.username || "User",
      avatarUrl: p.avatar || p.avatarUrl || "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300",
      isVerified: !!p.isVerified
    };
    const currentUserId = (this.data.currentUser && this.data.currentUser.id) || "u1";
    const messages = (t.messages || []).map(m => ({
      id: m.id || "m_" + Date.now(),
      sender: m.sender || (m.senderId === currentUserId ? "me" : (m.senderId || "other")),
      senderId: m.senderId || (m.sender === "me" ? currentUserId : m.sender),
      text: m.text || "",
      type: m.type || "text",
      mediaUrl: m.mediaUrl || null,
      fileName: m.fileName || null,
      fileSize: m.fileSize || null,
      duration: m.duration || null,
      waveform: m.waveform || null,
      timestamp: m.timestamp || m.time || "Just now",
      time: m.time || m.timestamp || "Just now",
      status: m.status || "delivered",
      isEncrypted: m.isEncrypted !== false
    }));

    return {
      ...t,
      participant: p,
      user: userObj,
      messages,
      lastMessage: t.lastMessage || (messages.length > 0 ? messages[messages.length - 1].text : "Encrypted channel"),
      unreadCount: t.unreadCount ?? (t.unread ? 1 : 0),
      isEncrypted: t.isEncrypted !== false
    };
  }

  getDirectThreads(category) {
    let threads = this.data.directThreads || [];
    if (category && category !== "All") {
      threads = threads.filter(t => t.category === category);
    }
    return threads.map(t => this._normalizeThread(t));
  }

  getThread(threadId) {
    const thread = (this.data.directThreads || []).find(t => t.id === threadId);
    return thread ? this._normalizeThread(thread) : null;
  }

  getOrCreateThread(participantUsername) {
    if (!participantUsername) return null;
    const existing = (this.data.directThreads || []).find(
      t => (t.participant?.username || t.user?.username || "").toLowerCase() === participantUsername.toLowerCase()
    );
    if (existing) {
      return this._normalizeThread(existing);
    }

    const userProfile = this.getUserByUsername(participantUsername) || {
      id: "u_" + participantUsername.toLowerCase(),
      username: participantUsername,
      displayName: participantUsername,
      avatar: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300"
    };

    const newThread = {
      id: "thread_" + participantUsername.toLowerCase() + "_" + Date.now(),
      participant: {
        id: userProfile.id,
        username: userProfile.username,
        displayName: userProfile.displayName,
        avatar: userProfile.avatar || userProfile.avatarUrl,
        isOnline: true,
        status: "Neural Mesh Active"
      },
      lastMessage: "Encrypted neural handshake open",
      lastTime: "Just now",
      unread: false,
      unreadCount: 0,
      category: "Primary",
      securityBanner: "Quantum-Encrypted Neural Link • 24h Purge Active • E2EE v4.1",
      messages: []
    };

    this.data.directThreads.unshift(newThread);
    return this._normalizeThread(newThread);
  }

  sendDirectMessage(threadId, msgData) {
    let rawThread = (this.data.directThreads || []).find(t => t.id === threadId);
    if (!rawThread) {
      // If threadId is formatted like thread_username or username, create it
      const uname = threadId.replace(/^thread_/, '');
      rawThread = (this.data.directThreads || []).find(
        t => (t.participant?.username || "").toLowerCase() === uname.toLowerCase()
      );
      if (!rawThread) {
        this.getOrCreateThread(uname);
        rawThread = (this.data.directThreads || []).find(
          t => (t.participant?.username || "").toLowerCase() === uname.toLowerCase()
        );
      }
    }
    if (!rawThread) return null;

    const currentUserId = (this.data.currentUser && this.data.currentUser.id) || "u1";
    const sender = msgData.sender || "me";
    const newMsg = {
      id: "msg_" + Date.now(),
      sender,
      senderId: sender === "me" ? currentUserId : (msgData.senderId || sender),
      text: msgData.text || "",
      type: msgData.type || "text",
      mediaUrl: msgData.mediaUrl || null,
      fileName: msgData.fileName || null,
      fileSize: msgData.fileSize || null,
      duration: msgData.duration || null,
      waveform: msgData.waveform || null,
      time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      timestamp: "Just now",
      status: "delivered",
      isEncrypted: true
    };

    if (!rawThread.messages) rawThread.messages = [];
    rawThread.messages.push(newMsg);
    rawThread.lastMessage = msgData.text || (msgData.type === 'hologram' ? 'Sent a hologram clip' : 'Sent audio memo');
    rawThread.lastTime = "Just now";
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
