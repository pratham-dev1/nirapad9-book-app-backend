const { createGoogleWatch } = require("./createGoogleWatch");

const checkGoogleWatchExpiration = async (user, expirationTime, accessToken, refreshToken, resourceIdColumnName, channelIdColumnName, expirationColumnName) => {
    if (!expirationTime || (new Date(expirationTime) < new Date())) {
        await createGoogleWatch(accessToken, refreshToken, resourceIdColumnName, channelIdColumnName, expirationColumnName, user)
        // console.log('Watch response:', result.data);
        // user[resourceIdColumnName] = response.resourceId;
        // user[channelIdColumnName] = response.id;
        // user[expirationColumnName] = new Date(+response.expiration).toISOString();
        // await user.save()
}
}

module.exports = {checkGoogleWatchExpiration}