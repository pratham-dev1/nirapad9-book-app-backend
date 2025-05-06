/**
 * 
 * @param {boolean} common 
 */

const generateCacheKey = (req, common) => {
  console.log(req.path)
  const params = req.query
  const sortedParams = Object.keys(params).sort().map((key) => `${key}=${params[key]}`).join('&')         // sorting the keys to ensure everytime it creates and consumes keys in the same pattern4
  const keyPrefix = req.originalUrl.split('?')[0]
  let  finalKey;
  if (common) {     // common for all users
    const initialKey = keyPrefix
    finalKey = sortedParams ? `${initialKey}#${sortedParams}` : initialKey
    return finalKey
  }
  else {
    const initialKey = `${keyPrefix}#userId:${req.user.userId}`
    finalKey = sortedParams ? `${initialKey}#${sortedParams}` : initialKey
    console.log(finalKey)
    return finalKey
  }
}

module.exports = {generateCacheKey}