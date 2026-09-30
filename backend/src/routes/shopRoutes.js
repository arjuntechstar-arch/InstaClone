import { Router } from "express";
import { store } from "../data/store.js";

const router = Router();

// GET /api/shop - Get shop data (hero drop, curated, trending)
router.get("/", (req, res) => {
  const shopData = store.getShop();
  res.json({ success: true, data: shopData });
});

// POST /api/shop/wishlist/:id - Toggle wishlist bookmark
router.post("/wishlist/:id", (req, res) => {
  const item = store.toggleWishlist(req.params.id);
  if (!item) {
    return res.status(404).json({ success: false, message: "Product not found" });
  }
  res.json({ success: true, data: item });
});

export default router;
