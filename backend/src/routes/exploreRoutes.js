import { Router } from "express";
import { store } from "../data/store.js";

const router = Router();

// GET /api/explore - Get explore mosaic grid (with optional category filter)
router.get("/", (req, res) => {
  const { category } = req.query;
  const exploreData = store.getExplore(category);
  res.json({ success: true, data: exploreData });
});

// GET /api/explore/search - Search across users, posts, and explore items
router.get("/search", (req, res) => {
  const { q } = req.query;
  const results = store.search(q);
  res.json({ success: true, query: q || "", data: results });
});

export default router;
