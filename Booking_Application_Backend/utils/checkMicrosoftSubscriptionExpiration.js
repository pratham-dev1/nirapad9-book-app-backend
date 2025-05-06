const { createMicrosoftSubscription } = require("./createMicrosoftSubscription");

const checkMicrosoftSubscriptionExpiration = async (user, email, expirationTime, accessToken, refreshToken, subscriptionIdColumnName, expirationColumnName) => {
    if (!expirationTime || (new Date(expirationTime) < new Date())) {
        await createMicrosoftSubscription(accessToken, refreshToken, user.id, email, subscriptionIdColumnName, expirationColumnName, user)
    }
}
module.exports = { checkMicrosoftSubscriptionExpiration }