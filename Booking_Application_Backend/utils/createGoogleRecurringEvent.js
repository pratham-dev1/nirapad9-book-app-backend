const { google } = require('googleapis');
const { SERVER_URL } = require("../config/urlsConfig");
const { v4: uuidv4 } = require('uuid');
const dayjs = require('dayjs');

async function createGoogleRecurringEvent(accessToken, refreshToken, startTime, attendees, title, endDateTime, meetLink, recurrence,recurrenceRepeat, recurrenceEndDate, recurrenceDays, recurrenceCount, recurrenceNeverEnds, hideGuestList, text, timezone) {
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
            let RECURRENCE_RULE = `RRULE:FREQ=${recurrence};`
            if(recurrenceRepeat) {
                RECURRENCE_RULE = RECURRENCE_RULE + `INTERVAL=${recurrenceRepeat};`
            }
            if(recurrenceDays) {
                RECURRENCE_RULE = RECURRENCE_RULE + `BYDAY=${recurrenceDays};`
            }
            if(recurrenceCount) {
                RECURRENCE_RULE = RECURRENCE_RULE + `COUNT=${recurrenceCount};`
            }
            if(recurrenceEndDate) {
                let formattedDate = dayjs.utc(recurrenceEndDate).format('YYYYMMDDTHHmmss[Z]');
                RECURRENCE_RULE = RECURRENCE_RULE + `UNTIL=${formattedDate};`
            }
            const endTime = endDateTime || new Date(new Date(startTime).getTime() + 30 * 60 * 1000).toISOString(); // Adding 30 minutes (30 * 60 * 1000 milliseconds)

            const event = {
                summary: title || 'Test title',
                description: text || "Test description",
                start: {
                    dateTime: startTime,
                    timeZone: timezone,
                },
                end: {
                    dateTime: endTime,
                    timeZone: timezone,
                },
                recurrence: [
                    RECURRENCE_RULE
                ],
                attendees: attendees,
                conferenceData: {
                    createRequest: {
                        requestId: uuidv4()
                    },
                },
                guestsCanSeeOtherGuests: !hideGuestList || false
            };

            const response = await calendar.events.insert({
                auth: oAuth2Client,
                calendarId: 'primary',
                resource: event,
                sendUpdates: 'all',
                conferenceDataVersion: (meetLink ? 0 : 1),
            });

            // console.log('Recurring event created', response.data);
            let meetingLink = response?.data?.hangoutLink
            let eventId = response?.data?.id
            resolve({ meetingLink, eventId });
        } catch (error) {
            console.error('Error creating recurring event:', error);
            reject(error);
        }
    });
}

module.exports = { createGoogleRecurringEvent };
