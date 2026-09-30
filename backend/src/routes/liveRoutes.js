import { Router } from "express";
import { store } from "../data/store.js";

const router = Router();

// GET /api/live - Get live stream state
router.get("/", (req, res) => {
  const live = store.getLiveStream();
  res.json({ success: true, data: live });
});

// POST /api/live/chat - Send live message
router.post("/chat", (req, res) => {
  const { text, user } = req.body;
  if (!text || !text.trim()) {
    return res.status(400).json({ success: false, message: "Chat text is required" });
  }
  const chatMsg = store.sendLiveChat({ text, user });
  res.status(201).json({ success: true, data: chatMsg });
});

// POST /api/live/gift - Send cyber tip/gift
router.post("/gift", (req, res) => {
  const { amount, label } = req.body;
  const gift = store.sendLiveGift({ amount, label });
  res.status(201).json({ success: true, data: gift });
});

// POST /api/live/poll/vote - Vote on live stream poll
router.post("/poll/vote", (req, res) => {
  const { choice } = req.body;
  if (!choice || (choice !== 'a' && choice !== 'b')) {
    return res.status(400).json({ success: false, message: "Choice must be 'a' or 'b'" });
  }
  const poll = store.voteLivePoll(choice);
  res.json({ success: true, data: poll });
});

export default router;
