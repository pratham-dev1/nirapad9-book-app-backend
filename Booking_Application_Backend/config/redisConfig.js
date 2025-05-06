const Redis = require("ioredis");

const redis = new Redis({
  host: process.env.REDIS_HOST || "localhost",
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD || null,
  db: 0,
  retryStrategy: (times) => Math.min(times * 50, 2000), // Auto-reconnect strategy
});

redis.on("connect", () => console.log("Connected to Redis"));
redis.on("error", (err) => console.log("Redis Error:", err));

module.exports = redis;
