import { Router } from "express";
import { store } from "../data/store.js";

const router = Router();

// GET /api/collections - Get collections & folders
router.get("/", (req, res) => {
  const collections = store.getCollections();
  res.json({ success: true, data: collections });
});

// POST /api/collections/folders - Create new folder
router.post("/folders", (req, res) => {
  const { title, isPrivate, badge } = req.body;
  if (!title || !title.trim()) {
    return res.status(400).json({ success: false, message: "Folder title is required" });
  }
  const folder = store.createFolder({ title, isPrivate, badge });
  res.status(201).json({ success: true, data: folder });
});

export default router;
