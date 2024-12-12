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
  const { lat, lon } = req.query;

  if (!lat || !lon) {
    res.status(400).send("Missing query parameters: lat or lon");
    return;
  }

  try {
    const response = await axios.get("https://api.openweathermap.org/data/2.5/weather", {
      params: {
        lat,
        lon,
        appid: process.env.OPENWEATHER_API_KEY,
      },
    });
    res.json(response.data);
  } catch (error) {
    console.error("Error fetching weather data:", error.message);
    res.status(500).send(`Error: ${error.message}`);
  }
});

// Cloud Functions 用エクスポート
exports.getWeatherData = app;
