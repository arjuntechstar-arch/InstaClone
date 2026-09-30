import http from "http";
import { createApp } from "./app.js";
import { setupWebSocket } from "./ws/websocketHandler.js";

const PORT = process.env.PORT || 4000;
const app = createApp();
const server = http.createServer(app);

setupWebSocket(server);

server.listen(PORT, () => {
  console.log(`[TOKYO.GRAM API] Online on port ${PORT}`);
  console.log(`[NEURAL LINK] WebSocket relay active at ws://localhost:${PORT}`);
});
