import { Router } from "express";
import { store } from "../data/store.js";

const router = Router();

// GET /api/stories - Get all stories for tray
router.get("/", (req, res) => {
  const stories = store.getStories();
  res.json({ success: true, count: stories.length, data: stories });
});

// GET /api/stories/:id - Get a specific user's story
router.get("/:id", (req, res) => {
  const story = store.getStory(req.params.id);
  if (!story) {
    return res.status(404).json({ success: false, message: "Story not found" });
  }
  res.json({ success: true, data: story });
});

// POST /api/stories/:id/segments/:segmentId/vote - Vote on interactive story poll
router.post("/:id/segments/:segmentId/vote", (req, res) => {
  const { choice } = req.body;
  if (!choice || (choice !== 'a' && choice !== 'b')) {
    return res.status(400).json({ success: false, message: "Choice must be 'a' or 'b'" });
  }
  const poll = store.voteStoryPoll(req.params.id, req.params.segmentId, choice);
  if (!poll) {
    return res.status(404).json({ success: false, message: "Poll not found" });
  }
  res.json({ success: true, data: poll });
});

export default router;
