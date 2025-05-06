const { google } = require('googleapis');
const { SERVER_URL } = require("../config/urlsConfig");

async function respondGoogleInvite(accessToken, refreshToken, eventId, email, status) {
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

            await calendar.events.patch({          // await requird here
                calendarId: 'primary',
                eventId: eventId,
                resource: {
                    attendees: [{
                        email,
                        responseStatus: status ? 'accepted' : 'declined'
                    }],
                },
            });
            resolve()
        }
        catch (error) {
            console.error('Error ', error);
            reject(error)
        }
    })
}

module.exports = { respondGoogleInvite }