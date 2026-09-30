import { Router } from "express";
import { store } from "../data/store.js";

const router = Router();

// GET /api/audio - Get audio track details
router.get("/", (req, res) => {
  const audio = store.getAudio();
  res.json({ success: true, data: audio });
});

// POST /api/audio/save - Toggle save/bookmark audio track
router.post("/save", (req, res) => {
  const audio = store.toggleSaveAudio();
  res.json({ success: true, data: audio });
});

export default router;
