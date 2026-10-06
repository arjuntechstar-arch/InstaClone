import { Router } from "express";
import { store } from "../data/store.js";

const router = Router();

// GET /api/auth/roles - Get available personas and their pre-seeded credentials
router.get("/roles", (req, res) => {
  const accounts = store.getAccounts();
  res.json({
    success: true,
    count: accounts.length,
    roles: accounts.map(a => ({
      id: a.id,
      username: a.username,
      displayName: a.displayName,
      role: a.role,
      accessLevel: a.accessLevel,
      passkey: a.passkey,
      avatar: a.avatar,
      bio: a.bio,
      badge: a.badge,
      isVerified: a.isVerified,
    }))
  });
});

// POST /api/auth/login - Authenticate with username and passkey
router.post("/login", (req, res) => {
  const { username, passkey, password } = req.body;
  const key = passkey || password;

  if (!username || !key) {
    return res.status(400).json({
      success: false,
      message: "Neural identifier and Quantum passkey are required"
    });
  }

  const user = store.authenticate(username, key);
  if (!user) {
    return res.status(401).json({
      success: false,
      message: "Invalid Neural ID or Quantum passkey. Check pre-seeded credentials."
    });
  }

  res.json({
    success: true,
    message: `Neural handshake accepted. Welcome, ${user.displayName}`,
    token: `quantum_jwt_${user.id}_${Date.now()}`,
    user
  });
});

// POST /api/auth/register - Register a new cyberpunk persona
router.post("/register", (req, res) => {
  const { username, passkey, password, displayName, role } = req.body;
  const key = passkey || password || "tokyo_pass_2088";

  if (!username) {
    return res.status(400).json({
      success: false,
      message: "Username / Neural handle is required"
    });
  }

  const result = store.registerAccount({
    username,
    passkey: key,
    displayName: displayName || username,
    role: role || "Cyber Explorer"
  });

  if (result.error) {
    return res.status(409).json({
      success: false,
      message: result.error
    });
  }

  res.status(201).json({
    success: true,
    message: `Neural identity minted on Tokyo.Gram grid: @${result.account.username}`,
    token: `quantum_jwt_${result.account.id}_${Date.now()}`,
    user: result.account
  });
});

// POST /api/auth/switch-persona - Instantly switch active persona during testing
router.post("/switch-persona", (req, res) => {
  const { username } = req.body;
  if (!username) {
    return res.status(400).json({ success: false, message: "Username required" });
  }

  const user = store.switchCurrentUser(username);
  if (!user) {
    return res.status(404).json({ success: false, message: "Persona not found" });
  }

  res.json({
    success: true,
    message: `Switched active grid node to @${user.username}`,
    user
  });
});

export default router;
