import { Router } from "express";
import { store } from "../data/store.js";

const router = Router();

// GET /api/notifications - Get all notifications and activity
router.get("/", (req, res) => {
  const notifications = store.getNotifications();
  res.json({ success: true, data: notifications });
});

// POST /api/notifications/follow-back/:username - Toggle follow back on notification
router.post("/follow-back/:username", (req, res) => {
  const item = store.toggleFollowBack(req.params.username);
  if (!item) {
    return res.status(404).json({ success: false, message: "Notification item not found" });
  }
  res.json({ success: true, data: item });
});

export default router;
