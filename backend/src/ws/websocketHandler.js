import { WebSocketServer } from "ws";
import { store } from "../data/store.js";

let wssInstance = null;

export function broadcast(event) {
  if (!wssInstance) return;
  const raw = JSON.stringify(event);
  wssInstance.clients.forEach(client => {
    if (client.readyState === 1) {
      client.send(raw);
    }
  });
}

export function setupWebSocket(server) {
  const wss = new WebSocketServer({ server });
  wssInstance = wss;

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
          case "DIRECT_MESSAGE":
          case "CHAT_MESSAGE": {
            const threadId = data.threadId;
            const msgData = data.message || {
              text: data.text,
              sender: data.sender || data.user,
              type: data.messageType || data.type || "text",
            };
            const savedMsg = store.sendDirectMessage(threadId, msgData);
            const thread = store.getThread(threadId);
            broadcast({
              type: "DIRECT_MESSAGE",
              threadId,
              message: savedMsg,
              lastMessage: thread ? thread.lastMessage : msgData.text,
              lastTime: "Just now"
            });
            break;
          }

          case "POST_LIKE": {
            const post = store.togglePostLike(data.postId);
            if (post) {
              broadcast({
                type: "POST_LIKED",
                postId: data.postId,
                isLiked: post.isLiked,
                likesCount: post.likesCount
              });
            }
            break;
          }

          case "COMMENT_ADD": {
            const comment = store.addComment(data.postId, {
              text: data.text,
              parentCommentId: data.parentCommentId || data.replyToId,
              user: data.user
            });
            const post = store.getPost(data.postId);
            if (comment) {
              broadcast({
                type: "COMMENT_ADDED",
                postId: data.postId,
                comment,
                commentsCount: post ? post.commentsCount : undefined
              });
            }
            break;
          }

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
            broadcast({
              type: "LIVE_REACTION",
              emoji: data.emoji || "💖",
              timestamp: Date.now()
            });
            break;

          case "LIVE_CHAT_MESSAGE": {
            const newChat = store.sendLiveChat({ text: data.text, user: data.user });
            broadcast({
              type: "LIVE_CHAT_MESSAGE",
              data: newChat
            });
            break;
          }

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
