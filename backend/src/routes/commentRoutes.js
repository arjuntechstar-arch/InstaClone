import { Router } from "express";
import { store } from "../data/store.js";

const router = Router();

// GET /api/comments/:postId - Get all comments for a post
router.get("/:postId", (req, res) => {
  const comments = store.getComments(req.params.postId);
  res.json({ success: true, count: comments.length, data: comments });
});

// POST /api/comments/:postId - Add comment or reply
router.post("/:postId", (req, res) => {
  const { text, parentCommentId } = req.body;
  if (!text || !text.trim()) {
    return res.status(400).json({ success: false, message: "Comment text is required" });
  }
  const comment = store.addComment(req.params.postId, { text, parentCommentId });
  res.status(201).json({ success: true, data: comment });
});

export default router;
