import { Router } from "express";
import { store } from "../data/store.js";

const router = Router();

// GET /api/feed - Get all feed posts
router.get("/", (req, res) => {
  const posts = store.getFeed();
  res.json({ success: true, count: posts.length, data: posts });
});

// GET /api/feed/:id - Get a single post
router.get("/:id", (req, res) => {
  const post = store.getPost(req.params.id);
  if (!post) {
    return res.status(404).json({ success: false, message: "Post not found" });
  }
  res.json({ success: true, data: post });
});

// POST /api/feed - Create a new post
router.post("/", (req, res) => {
  const post = store.createPost(req.body);
  res.status(201).json({ success: true, data: post });
});

// POST /api/feed/:id/like - Toggle like on post
router.post("/:id/like", (req, res) => {
  const post = store.togglePostLike(req.params.id);
  if (!post) {
    return res.status(404).json({ success: false, message: "Post not found" });
  }
  res.json({ success: true, data: post });
});

// POST /api/feed/:id/save - Toggle save/bookmark on post
router.post("/:id/save", (req, res) => {
  const post = store.togglePostSave(req.params.id);
  if (!post) {
    return res.status(404).json({ success: false, message: "Post not found" });
  }
  res.json({ success: true, data: post });
});

export default router;
