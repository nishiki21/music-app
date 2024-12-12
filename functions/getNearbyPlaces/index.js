const express = require("express");
const axios = require("axios");

const app = express();

// CORS 設定
app.use((req, res, next) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
  if (req.method === "OPTIONS") {
    return res.status(204).end();
  }
  next();
});

// メインエンドポイント
app.get("/", async (req, res) => {
  const { lat, lng, type } = req.query;

  if (!lat || !lng || !type) {
    res.status(400).send("Missing query parameters: lat, lng, or type");
    return;
  }

  try {
    const response = await axios.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json", {
      params: {
        location: `${lat},${lng}`,
        radius: 100,
        type,
        key: process.env.GOOGLE_PLACES_API_KEY,
      },
    });
    res.json(response.data);
  } catch (error) {
    console.error("Error fetching nearby places:", error.message);
    res.status(500).send(`Error: ${error.message}`);
  }
});

// Cloud Functions 用エクスポート
exports.getNearbyPlaces = app;
