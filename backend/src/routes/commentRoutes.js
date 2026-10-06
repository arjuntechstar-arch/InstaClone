import { Router } from "express";
import { store } from "../data/store.js";
import { broadcast } from "../ws/websocketHandler.js";

const router = Router();

// GET /api/comments/:postId - Get all comments for a post
router.get("/:postId", (req, res) => {
  const comments = store.getComments(req.params.postId);
  res.json({
    success: true,
    count: comments.length,
    data: comments,
    comments: comments
  });
});

// POST /api/comments/:postId - Add comment or reply
router.post("/:postId", (req, res) => {
  const { text, parentCommentId, replyToId, user } = req.body;
  if (!text || !text.trim()) {
    return res.status(400).json({ success: false, message: "Comment text is required" });
  }
  const comment = store.addComment(req.params.postId, {
    text,
    parentCommentId: parentCommentId || replyToId,
    user
  });
  const post = store.getPost(req.params.postId);

  broadcast({
    type: "COMMENT_ADDED",
    postId: req.params.postId,
    comment,
    commentsCount: post ? post.commentsCount : undefined
  });

  res.status(201).json({
    success: true,
    data: comment,
    comment: comment,
    commentsCount: post ? post.commentsCount : undefined
  });
});

export default router;
