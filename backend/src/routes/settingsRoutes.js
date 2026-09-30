import { Router } from "express";
import { store } from "../data/store.js";

const router = Router();

// GET /api/settings - Get settings and privacy protocols
router.get("/", (req, res) => {
  const settings = store.getSettings();
  res.json({ success: true, data: settings });
});

// PUT /api/settings - Update settings and preferences
router.put("/", (req, res) => {
  const updated = store.updateSettings(req.body);
  res.json({ success: true, data: updated });
});

export default router;
