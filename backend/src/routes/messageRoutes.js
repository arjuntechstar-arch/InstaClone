import { Router } from "express";
import { store } from "../data/store.js";

const router = Router();

// GET /api/messages/threads - Get all DM threads with optional category filter
router.get("/threads", (req, res) => {
  const { category } = req.query;
  const threads = store.getDirectThreads(category);
  res.json({ success: true, count: threads.length, data: threads });
});

// GET /api/messages/threads/:id - Get a single thread by ID
router.get("/threads/:id", (req, res) => {
  const thread = store.getThread(req.params.id);
  if (!thread) {
    return res.status(404).json({ success: false, message: "Thread not found" });
  }
  res.json({ success: true, data: thread });
});

// POST /api/messages/threads/:id - Send a message to thread
router.post("/threads/:id", (req, res) => {
  const msg = store.sendDirectMessage(req.params.id, req.body);
  if (!msg) {
    return res.status(404).json({ success: false, message: "Thread not found" });
  }
  res.status(201).json({ success: true, data: msg });
});

export default router;
