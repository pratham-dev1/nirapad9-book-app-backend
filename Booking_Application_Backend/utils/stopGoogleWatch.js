const { google } = require('googleapis');

async function stopGoogleWatch(accessToken, refreshToken, channelId, resourceId, resourceIdColumnName, channelIdColumnName, expirationColumnName, user) {
    return new Promise(async (resolve, reject) => {
        try {
            const oAuth2Client = new google.auth.OAuth2({
                clientId: process.env.GOOGLE_CLIENT_ID,
                clientSecret: process.env.GOOGLE_CLIENT_SECRET,
            });

            oAuth2Client.setCredentials({
                access_token: accessToken,
                refresh_token: refreshToken
            });
            const calendar = google.calendar({ version: 'v3', auth: oAuth2Client });
            const result = await calendar.channels.stop({
                calendarId: 'primary',
                requestBody: {
                    id: channelId, // Unique identifier for the channel
                    resourceId: resourceId
                },
            })
            user[resourceIdColumnName] = null;
            user[channelIdColumnName] = null;
            user[expirationColumnName] = null;
            await user.save()
            // console.log('stopped google watch')
            resolve(result)
        }
        catch (error) {
            console.error('Error ', error);
            reject(error)
            // throw { statusCode: 500, message: error.message }
        }
    })
}

module.exports = { stopGoogleWatch }