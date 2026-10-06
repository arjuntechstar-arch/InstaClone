import { Router } from "express";
import { store } from "../data/store.js";
import { broadcast } from "../ws/websocketHandler.js";

const router = Router();

// GET /api/users/me - Get current logged-in user profile
router.get("/me", (req, res) => {
  const user = store.getCurrentUser();
  res.json({ success: true, data: user });
});

// PUT /api/users/me - Update profile bio/settings
router.put("/me", (req, res) => {
  const updated = store.updateCurrentUser(req.body);
  res.json({ success: true, data: updated });
});

// GET /api/users - Get all creators list
router.get("/", (req, res) => {
  const users = store.getUsers();
  res.json({ success: true, count: users.length, data: users, users });
});

// GET /api/users/suggestions - Get suggested users to follow
router.get("/suggestions", (req, res) => {
  const suggestions = store.getSuggestedUsers();
  res.json({ success: true, count: suggestions.length, data: suggestions });
});

// GET /api/users/:username - Get a specific user profile
router.get("/:username", (req, res) => {
  const user = store.getUserByUsername(req.params.username);
  if (!user) {
    return res.status(404).json({ success: false, message: "User not found" });
  }
  res.json({ success: true, data: user });
});

// POST /api/users/:username/follow - Toggle follow status
router.post("/:username/follow", (req, res) => {
  const user = store.toggleFollowUser(req.params.username);
  if (!user) {
    return res.status(404).json({ success: false, message: "User not found" });
  }
  broadcast({
    type: "USER_FOLLOWED",
    username: req.params.username,
    isFollowing: user.isFollowing,
    synapsesCount: user.synapsesCount
  });
  res.json({
    success: true,
    data: user,
    isFollowing: user.isFollowing,
    isFollowRequested: user.isFollowRequested ?? false,
  });
});

export default router;
