import express from "express";
import cors from "cors";

import feedRoutes from "./routes/feedRoutes.js";
import storyRoutes from "./routes/storyRoutes.js";
import reelRoutes from "./routes/reelRoutes.js";
import exploreRoutes from "./routes/exploreRoutes.js";
import messageRoutes from "./routes/messageRoutes.js";
import commentRoutes from "./routes/commentRoutes.js";
import notificationRoutes from "./routes/notificationRoutes.js";
import userRoutes from "./routes/userRoutes.js";
import audioRoutes from "./routes/audioRoutes.js";
import shopRoutes from "./routes/shopRoutes.js";
import collectionRoutes from "./routes/collectionRoutes.js";
import liveRoutes from "./routes/liveRoutes.js";
import settingsRoutes from "./routes/settingsRoutes.js";

export function createApp() {
  const app = express();

  app.use(cors());
  app.use(express.json());

  // Health check endpoint
  app.get("/api/health", (req, res) => {
    res.json({
      status: "online",
      subNet: "Neo-Tokyo Sector 4",
      protocol: "Quantum E2EE v4.1",
      timestamp: new Date().toISOString()
    });
  });

  // Mount API routers
  app.use("/api/feed", feedRoutes);
  app.use("/api/stories", storyRoutes);
  app.use("/api/reels", reelRoutes);
  app.use("/api/explore", exploreRoutes);
  app.use("/api/messages", messageRoutes);
  app.use("/api/comments", commentRoutes);
  app.use("/api/notifications", notificationRoutes);
  app.use("/api/users", userRoutes);
  app.use("/api/audio", audioRoutes);
  app.use("/api/shop", shopRoutes);
  app.use("/api/collections", collectionRoutes);
  app.use("/api/live", liveRoutes);
  app.use("/api/settings", settingsRoutes);

  return app;
}
