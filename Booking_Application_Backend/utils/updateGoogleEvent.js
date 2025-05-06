const { google } = require('googleapis');
const { SERVER_URL } = require("../config/urlsConfig");
const { v4: uuidv4 } = require('uuid');

async function updateGoogleEvent(accessToken, refreshToken,  eventId, title, startTime, endDateTime, attendees = [], text) {
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

        const endTime = endDateTime || new Date(new Date(startTime).getTime() + 30 * 60 * 1000).toISOString(); // Adding 30 minutes (30 * 60 * 1000 milliseconds)
        const updatedEvent = {
            start: {
                dateTime: startTime,
                timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
            },
            end: {
                dateTime: endTime,
                timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
            },
        };
        if (title) {
            updatedEvent.summary = title; // Add title only if it's provided
        }
        if (text) {
            updatedEvent.description = text; // Add title only if it's provided
        }
        if (attendees) {
            updatedEvent.attendees = attendees;
        }
        const response = await calendar.events.patch({
            auth: oAuth2Client,
            calendarId: 'primary',
            sendUpdates: 'all',
            eventId: eventId, 
            resource: updatedEvent,
        });
        if(response.data.status === "cancelled") {
           reject({statusCode: 404})
        }
        else {
            resolve()
        }
    }
    catch (error) {
        console.error('Error ', error);
        reject(error)
        // throw { statusCode: 500, message: error.message }
    }
    })
}

module.exports = { updateGoogleEvent }