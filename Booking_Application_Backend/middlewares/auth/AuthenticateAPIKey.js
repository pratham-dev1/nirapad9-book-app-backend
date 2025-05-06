const {  compareValues } = require("../../utils/argon");

const db = require("../../models");

const AuthenticateApiKey = async (request, response, next) => {
  const apiKey = request.headers["x-api-key"];
  const secretKey = request.headers["x-org-secret-key"]; 
  const orgId = request.query.orgId;    
  const resourceId = request.query.resourceId;  

  if (!apiKey) {
    return response.status(401).send("API Key is missing");
  }

  if (!orgId || !resourceId) {
    return response.status(400).send("orgId and resourceId are required");
  }

  if (!secretKey) {
    return response.status(401).send("Secret Key is missing");
  }

  try {
    const result = await db.organization_resources.findOne({
      where: {
        orgId,
        resourceId
      },
      attributes: ['apiKey', 'orgSecretKey'] 
    });

    if (!result) {
      return response.status(401).send("Invalid Organization/Resource combination");
    }

    const isApiKeyValid = await compareValues(apiKey, result.apiKey);
    if (!isApiKeyValid) {
      return response.status(401).send("Invalid API Key");
    }

    const isSecretKeyValid = await compareValues(secretKey, result.orgSecretKey);
    if (!isSecretKeyValid) {
      return response.status(401).send("Invalid Secret Key");
    }

    request.orgId = orgId;
    request.resourceId = resourceId;

    next(); 
  } catch (error) {
    console.error(error);
    return response.status(500).send("Server error");
  }
};

module.exports = { AuthenticateApiKey };
