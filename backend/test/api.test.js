import { test, before, after } from "node:test";
import assert from "node:assert/strict";
import http from "http";
import { createApp } from "../src/app.js";
import { store } from "../src/data/store.js";

let server;
let baseUrl;

before(async () => {
  store.reset();
  const app = createApp();
  server = http.createServer(app);
  await new Promise((resolve) => server.listen(0, resolve));
  const port = server.address().port;
  baseUrl = `http://localhost:${port}`;
});

after(async () => {
  await new Promise((resolve) => server.close(resolve));
});

test("GET /api/health - returns online system health", async () => {
  const res = await fetch(`${baseUrl}/api/health`);
  assert.equal(res.status, 200);
  const data = await res.json();
  assert.equal(data.status, "online");
  assert.equal(data.subNet, "Neo-Tokyo Sector 4");
});

test("Feed Endpoints: GET, LIKE, SAVE, CREATE", async () => {
  // GET feed
  const res = await fetch(`${baseUrl}/api/feed`);
  assert.equal(res.status, 200);
  const feed = await res.json();
  assert.equal(feed.success, true);
  assert.ok(feed.data.length >= 2);
  const firstPostId = feed.data[0].id;

  // GET single post
  const singleRes = await fetch(`${baseUrl}/api/feed/${firstPostId}`);
  assert.equal(singleRes.status, 200);
  const single = await singleRes.json();
  assert.equal(single.data.id, firstPostId);

  // Toggle like
  const likeRes = await fetch(`${baseUrl}/api/feed/${firstPostId}/like`, { method: "POST" });
  assert.equal(likeRes.status, 200);
  const liked = await likeRes.json();
  assert.equal(liked.success, true);

  // Toggle save
  const saveRes = await fetch(`${baseUrl}/api/feed/${firstPostId}/save`, { method: "POST" });
  assert.equal(saveRes.status, 200);
  const saved = await saveRes.json();
  assert.equal(saved.success, true);

  // Create new post
  const createRes = await fetch(`${baseUrl}/api/feed`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      caption: "Test transmission from Sector 9",
      tags: ["#test", "#tokyo"],
      location: "Shinjuku Sector 9"
    })
  });
  assert.equal(createRes.status, 201);
  const created = await createRes.json();
  assert.equal(created.data.caption, "Test transmission from Sector 9");
});

test("Stories Endpoints: GET and Poll Vote", async () => {
  const res = await fetch(`${baseUrl}/api/stories`);
  assert.equal(res.status, 200);
  const stories = await res.json();
  assert.ok(stories.data.length >= 2);

  // Poll voting on k1ra_neo story
  const voteRes = await fetch(`${baseUrl}/api/stories/story_1/segments/seg_1/vote`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ choice: "a" })
  });
  assert.equal(voteRes.status, 200);
  const voted = await voteRes.json();
  assert.equal(voted.success, true);
  assert.equal(voted.data.userVoted, "a");
});

test("Reels Endpoints: GET, LIKE, FOLLOW", async () => {
  const res = await fetch(`${baseUrl}/api/reels`);
  assert.equal(res.status, 200);
  const reels = await res.json();
  assert.ok(reels.data.length >= 1);
  const reelId = reels.data[0].id;

  // Like reel
  const likeRes = await fetch(`${baseUrl}/api/reels/${reelId}/like`, { method: "POST" });
  assert.equal(likeRes.status, 200);
  const liked = await likeRes.json();
  assert.equal(liked.success, true);

  // Follow reel creator
  const followRes = await fetch(`${baseUrl}/api/reels/${reelId}/follow`, { method: "POST" });
  assert.equal(followRes.status, 200);
  const followed = await followRes.json();
  assert.equal(followed.success, true);
});

test("Explore & Search Endpoints", async () => {
  // GET Explore mosaic
  const res = await fetch(`${baseUrl}/api/explore`);
  assert.equal(res.status, 200);
  const explore = await res.json();
  assert.ok(explore.data.items.length >= 3);

  // Search query
  const searchRes = await fetch(`${baseUrl}/api/explore/search?q=cyber`);
  assert.equal(searchRes.status, 200);
  const searchResults = await searchRes.json();
  assert.ok(searchResults.data.users.length > 0 || searchResults.data.posts.length > 0);
});

test("Messages Endpoints: GET threads and POST message", async () => {
  const res = await fetch(`${baseUrl}/api/messages/threads`);
  assert.equal(res.status, 200);
  const threads = await res.json();
  assert.ok(threads.data.length >= 1);

  // Send message to thread_kira
  const msgRes = await fetch(`${baseUrl}/api/messages/threads/thread_kira`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ text: "Neural link verified. System operational." })
  });
  assert.equal(msgRes.status, 201);
  const msg = await msgRes.json();
  assert.equal(msg.data.text, "Neural link verified. System operational.");
});

test("Comments Endpoints: GET and ADD comment", async () => {
  const res = await fetch(`${baseUrl}/api/comments/post_1`);
  assert.equal(res.status, 200);
  const comments = await res.json();
  assert.ok(comments.data.length >= 1);

  // Add comment
  const addRes = await fetch(`${baseUrl}/api/comments/post_1`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ text: "Incredible chromatic dispersion!" })
  });
  assert.equal(addRes.status, 201);
  const newComment = await addRes.json();
  assert.equal(newComment.data.text, "Incredible chromatic dispersion!");
});

test("Notifications & Follow-back", async () => {
  const res = await fetch(`${baseUrl}/api/notifications`);
  assert.equal(res.status, 200);
  const notifs = await res.json();
  assert.equal(notifs.data.followRequestsCount, 12);

  // Toggle follow back
  const fbRes = await fetch(`${baseUrl}/api/notifications/follow-back/cyber_valkyrie`, { method: "POST" });
  assert.equal(fbRes.status, 200);
  const fb = await fbRes.json();
  assert.equal(fb.data.isFollowing, true);
});

test("Users Endpoints: ME, Public Profile, Follow", async () => {
  // Current user
  const meRes = await fetch(`${baseUrl}/api/users/me`);
  assert.equal(meRes.status, 200);
  const me = await meRes.json();
  assert.equal(me.data.username, "aoi_kurogane");

  // Public user
  const userRes = await fetch(`${baseUrl}/api/users/k1ra_neo`);
  assert.equal(userRes.status, 200);
  const user = await userRes.json();
  assert.equal(user.data.username, "k1ra_neo");

  // Toggle follow
  const followRes = await fetch(`${baseUrl}/api/users/k1ra_neo/follow`, { method: "POST" });
  assert.equal(followRes.status, 200);
  const followed = await followRes.json();
  assert.equal(followed.success, true);
});

test("Audio Track & Save", async () => {
  const res = await fetch(`${baseUrl}/api/audio`);
  assert.equal(res.status, 200);
  const audio = await res.json();
  assert.equal(audio.data.title, "Nightcall");

  // Save audio
  const saveRes = await fetch(`${baseUrl}/api/audio/save`, { method: "POST" });
  assert.equal(saveRes.status, 200);
  const saved = await saveRes.json();
  assert.equal(saved.data.isSaved, true);
});

test("Shop & Wishlist", async () => {
  const res = await fetch(`${baseUrl}/api/shop`);
  assert.equal(res.status, 200);
  const shop = await res.json();
  assert.equal(shop.data.heroDrop.title, "SECTOR 9 TACTICAL HOODIE");

  // Wishlist toggle
  const wishRes = await fetch(`${baseUrl}/api/shop/wishlist/prod_4`, { method: "POST" });
  assert.equal(wishRes.status, 200);
  const wished = await wishRes.json();
  assert.equal(wished.data.isWishlist, true);
});

test("Collections & Create Folder", async () => {
  const res = await fetch(`${baseUrl}/api/collections`);
  assert.equal(res.status, 200);
  const collections = await res.json();
  assert.ok(collections.data.folders.length >= 5);

  // Create folder
  const folderRes = await fetch(`${baseUrl}/api/collections/folders`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title: "Neo Shaders", isPrivate: true, badge: "NEW" })
  });
  assert.equal(folderRes.status, 201);
  const created = await folderRes.json();
  assert.equal(created.data.title, "Neo Shaders");
});

test("Live Stream: GET, CHAT, GIFT, POLL", async () => {
  const res = await fetch(`${baseUrl}/api/live`);
  assert.equal(res.status, 200);
  const live = await res.json();
  assert.equal(live.data.title, "NEO-SHINJUKU MIDNIGHT SYNTH");

  // Send chat
  const chatRes = await fetch(`${baseUrl}/api/live/chat`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ text: "Cyberpunk beat is immaculate!" })
  });
  assert.equal(chatRes.status, 201);

  // Send gift
  const giftRes = await fetch(`${baseUrl}/api/live/gift`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ amount: 1000, label: "Neural Crystal" })
  });
  assert.equal(giftRes.status, 201);
  const gift = await giftRes.json();
  assert.equal(gift.data.amount, 1000);

  // Vote live poll
  const pollRes = await fetch(`${baseUrl}/api/live/poll/vote`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ choice: "a" })
  });
  assert.equal(pollRes.status, 200);
});

test("Settings & Update Preferences", async () => {
  const res = await fetch(`${baseUrl}/api/settings`);
  assert.equal(res.status, 200);
  const settings = await res.json();
  assert.equal(settings.data.accountPrivacy, "Public");

  // Update settings
  const updateRes = await fetch(`${baseUrl}/api/settings`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ darkNeonTheme: true, isPrivateAccount: true })
  });
  assert.equal(updateRes.status, 200);
  const updated = await updateRes.json();
  assert.equal(updated.data.isPrivateAccount, true);
});
