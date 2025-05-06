const { google } = require('googleapis');
const { SERVER_URL } = require("../config/urlsConfig");
const { v4: uuidv4 } = require('uuid');

async function cancelGoogleEvent(accessToken, refreshToken, eventId) {
    return new Promise(async (resolve, reject) => {
        try {
            const oAuth2Client = new google.auth.OAuth2({
                clientId: process.env.GOOGLE_CLIENT_ID,
                clientSecret: process.env.GOOGLE_CLIENT_SECRET,
                redirectUri: `${SERVER_URL}/auth/google/callback`,
            });

            oAuth2Client.setCredentials({
                access_token: accessToken,
                refresh_token: refreshToken,
            });

            const calendar = google.calendar({ version: 'v3', auth: oAuth2Client });

            const response = await calendar.events.delete({
                calendarId: 'primary',
                eventId: eventId,
                sendUpdates: 'all',
            });

            resolve(response)
        }
        catch (error) {
            console.error('Error ', error);
            reject(error)
            // throw { statusCode: 500, message: error.message }
        }
    })
}

module.exports = { cancelGoogleEvent }