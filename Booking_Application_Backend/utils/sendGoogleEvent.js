const { google } = require('googleapis');
const { SERVER_URL } = require("../config/urlsConfig");
const { v4: uuidv4 } = require('uuid');

async function sendGoogleEvent(accessToken, refreshToken, startTime, attendees, title, endDateTime, meetLink, hideGuestList, text, source, meetType) {
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
        const event = {
            summary: title || 'Test title',
            description: text || 'Nirapad Description',
            location: meetLink,
            start: {
                dateTime: startTime,
                timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
            },
            end: {
                dateTime: endTime,
                timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
            },
            attendees: attendees,
            conferenceData: {
                createRequest: {
                    requestId: uuidv4()
                },
            },
            guestsCanSeeOtherGuests: !hideGuestList || false,
            extendedProperties: {
                private: { ...source } // Add extra parameters
            }

        };
        // console.log(event.guestsCanSeeOtherGuests)
        const response = await calendar.events.insert({         // await required here
            oAuth2Client,
            calendarId: 'primary',
            resource: event,
            sendUpdates: 'all',
            conferenceDataVersion: (meetType === 3 ? 0 : 1),   // meetType = 3 (In-person type)
        });

        // console.log('Event created -', response.data);
        let meetingLink = response?.data?.hangoutLink
        let eventId = response?.data?.id
        resolve({ meetingLink, eventId });
    }
    catch (error) {
        console.error('Error ', error);
        reject(error)
        // throw { statusCode: 500, message: error.message }
    }
    })
}

module.exports = { sendGoogleEvent }