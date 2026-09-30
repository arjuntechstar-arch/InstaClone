import { WebSocketServer } from "ws";
import { store } from "../data/store.js";

export function setupWebSocket(server) {
  const wss = new WebSocketServer({ server });

  wss.on("connection", (ws) => {
    ws.isAlive = true;
    ws.on("pong", () => { ws.isAlive = true; });

    ws.send(JSON.stringify({
      type: "SYSTEM_WELCOME",
      message: "Neural Link Established with Neo-Tokyo Grid",
      timestamp: new Date().toISOString()
    }));

    ws.on("message", (raw) => {
      try {
        const data = JSON.parse(raw.toString());
        switch (data.type) {
          case "CHAT_TYPING":
            // Broadcast typing event to all clients except sender
            wss.clients.forEach(client => {
              if (client !== ws && client.readyState === 1) {
                client.send(JSON.stringify({
                  type: "CHAT_TYPING",
                  user: data.user || "k1ra_neo",
                  threadId: data.threadId
                }));
              }
            });
            break;

          case "LIVE_REACTION":
            // Broadcast floating emoji particle reaction
            wss.clients.forEach(client => {
              if (client.readyState === 1) {
                client.send(JSON.stringify({
                  type: "LIVE_REACTION",
                  emoji: data.emoji || "💖",
                  timestamp: Date.now()
                }));
              }
            });
            break;

          case "LIVE_CHAT_MESSAGE":
            const newChat = store.sendLiveChat({ text: data.text, user: data.user });
            wss.clients.forEach(client => {
              if (client.readyState === 1) {
                client.send(JSON.stringify({
                  type: "LIVE_CHAT_MESSAGE",
                  data: newChat
                }));
              }
            });
            break;

          default:
            break;
        }
      } catch (err) {
        console.error("WS Parse error:", err);
      }
    });
  });

  const interval = setInterval(() => {
    wss.clients.forEach((ws) => {
      if (ws.isAlive === false) return ws.terminate();
      ws.isAlive = false;
      ws.ping();
    });
  }, 30000);

  wss.on("close", () => {
    clearInterval(interval);
  });

  return wss;
}
