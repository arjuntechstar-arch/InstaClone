import { Router } from "express";
import { store } from "../data/store.js";
import { broadcast } from "../ws/websocketHandler.js";

const router = Router();

// GET /api/messages or /api/messages/threads - Get all DM threads
const getThreadsHandler = (req, res) => {
  const { category } = req.query;
  const threads = store.getDirectThreads(category);
  res.json({
    success: true,
    count: threads.length,
    data: threads,
    threads: threads
  });
};

router.get("/", getThreadsHandler);
router.get("/threads", getThreadsHandler);

// POST /api/messages/start or /api/messages/threads/create - Start or retrieve thread for user
const startThreadHandler = (req, res) => {
  const { participantUsername, username } = req.body;
  const targetUser = participantUsername || username;
  if (!targetUser) {
    return res.status(400).json({ success: false, message: "participantUsername is required" });
  }
  const thread = store.getOrCreateThread(targetUser);
  res.json({
    success: true,
    data: thread,
    thread: thread
  });
};

router.post("/start", startThreadHandler);
router.post("/threads/create", startThreadHandler);

// GET /api/messages/:id or /api/messages/threads/:id - Get a single thread by ID
const getSingleThreadHandler = (req, res) => {
  const thread = store.getThread(req.params.id);
  if (!thread) {
    return res.status(404).json({ success: false, message: "Thread not found" });
  }
  res.json({ success: true, data: thread, thread: thread });
};

router.get("/:id", getSingleThreadHandler);
router.get("/threads/:id", getSingleThreadHandler);

// POST /api/messages/:id or /api/messages/threads/:id - Send a message to thread
const sendMessageHandler = (req, res) => {
  const msg = store.sendDirectMessage(req.params.id, req.body);
  if (!msg) {
    return res.status(404).json({ success: false, message: "Thread not found" });
  }
  const thread = store.getThread(req.params.id);

  broadcast({
    type: "DIRECT_MESSAGE",
    threadId: req.params.id,
    message: msg,
    lastMessage: thread ? thread.lastMessage : msg.text,
    lastTime: "Just now"
  });

  res.status(201).json({
    success: true,
    data: msg,
    message: msg
  });
};

router.post("/:id", sendMessageHandler);
router.post("/threads/:id", sendMessageHandler);

export default router;
