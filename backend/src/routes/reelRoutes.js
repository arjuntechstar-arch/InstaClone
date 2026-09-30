import { Router } from "express";
import { store } from "../data/store.js";

const router = Router();

// GET /api/reels - Get all reels
router.get("/", (req, res) => {
  const reels = store.getReels();
  res.json({ success: true, count: reels.length, data: reels });
});

// POST /api/reels/:id/like - Toggle like on reel
router.post("/:id/like", (req, res) => {
  const reel = store.toggleReelLike(req.params.id);
  if (!reel) {
    return res.status(404).json({ success: false, message: "Reel not found" });
  }
  res.json({ success: true, data: reel });
});

// POST /api/reels/:id/follow - Toggle follow creator of reel
router.post("/:id/follow", (req, res) => {
  const reel = store.data.reels.find(r => r.id === req.params.id);
  if (!reel) {
    return res.status(404).json({ success: false, message: "Reel not found" });
  }
  const updatedReel = store.toggleReelFollow(reel.creatorId);
  res.json({ success: true, data: updatedReel });
});

export default router;
