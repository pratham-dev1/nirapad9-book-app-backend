const redis = require("../config/redisConfig");
const { generateCacheKey } = require("../utils/generateCacheKey");

const CacheMiddleware = ({ttl, common}) => {
  return async (req, res, next) => {
    const cacheKey = generateCacheKey(req, common)
    console.log("Cache Key:", cacheKey);

    try {
      const cachedData = await redis.get(cacheKey);

      if (cachedData) {
        console.log("Cache Hit:", cacheKey);
        const parsed = JSON.parse(cachedData);
        parsed.fromCache = true;
        return res.json(parsed);
      }

      console.log("Cache Miss:", cacheKey);
      res.sendResponse = res.json;

      res.json = async (body) => {     // in this body we will get all the properties whatever we are sending in res.json in controller function
        if(ttl) {
        await redis.setex(cacheKey, ttl, JSON.stringify(body)); // ttl in seconds
        }
        else {
            await redis.set(cacheKey, JSON.stringify(body));
        }
        res.sendResponse(body);
      };

      next();
    } catch (err) {
      console.error("Redis Cache Error:", err);
      next();
    }
  };
};

module.exports = CacheMiddleware;
