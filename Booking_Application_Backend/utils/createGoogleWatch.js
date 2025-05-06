const { google } = require('googleapis');
const { v4: uuidv4 } = require('uuid');
const { SERVER_URL } = require('../config/urlsConfig');

async function createGoogleWatch(accessToken, refreshToken, resourceIdColumnName, channelIdColumnName, expirationColumnName, user) {
  return new Promise(async (resolve, reject) => {
    try {
      const oAuth2Client = new google.auth.OAuth2({
        clientId: process.env.GOOGLE_CLIENT_ID,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      });

      oAuth2Client.setCredentials({
        access_token: accessToken,
        refresh_token: refreshToken,
      });
      const calendar = google.calendar({ version: 'v3', auth: oAuth2Client });
      const result = await calendar.events.watch({
        calendarId: 'primary',
        resource: {
          id: uuidv4(), // Unique identifier for the channel
          type: 'web_hook',
          address: `${SERVER_URL}/api/google/webhook`,
          address: `https://4d66-2405-201-3044-697f-b5d2-68d0-f04a-6be5.ngrok-free.app/api/google/webhook`, // Your webhook URL
          // address: `https://fg.f.com/api/notifications`,
          expiration: Date.now() + (2592000 * 1000), // Adding 1 month for expiration time in milliseconds ---- (Note:-- Maximum limit is 1 month)
        },
      });

      user[resourceIdColumnName] = result.data.resourceId;
      user[channelIdColumnName] = result.data.id;
      user[expirationColumnName] = new Date(+result.data.expiration).toISOString();
      await user.save()
      resolve(result.data)
    }
    catch (error) {
      console.error('Error ', error);
      reject(error)
      // throw { statusCode: 500, message: error.message }
    }
  })
}

module.exports = { createGoogleWatch }