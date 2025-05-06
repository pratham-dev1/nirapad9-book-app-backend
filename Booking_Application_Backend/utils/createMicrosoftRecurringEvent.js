const MicrosoftGraph = require('@microsoft/microsoft-graph-client');
const db = require("../models/index");
const { refreshTokenMicrosoft } = require('./refreshTokenMicrosoft');
const dayjs = require('dayjs');

async function createMicrosoftRecurringEvent(accessToken, refreshToken, startTime, attendees, userId, email, title, endDateTime, meetLink, recurrence, recurrenceRepeat, recurrenceEndDate, recurrenceDaysArray,recurrenceCount, recurrenceNeverEnds, hideGuestList, text, timezone) {
    return new Promise(async (resolve, reject) => {
        try {
            const client = MicrosoftGraph.Client.init({
                authProvider: (done) => {
                    done(null, accessToken);
                }
            });
            const endTime = endDateTime || new Date(new Date(startTime).getTime() + 30 * 60 * 1000).toISOString(); // Adding 30 minutes (30 * 60 * 1000 milliseconds)
            let content = text || 'Event Created'
            if (meetLink) {
                content += `
                    <p><a href="${meetLink}">Join meet</a></p>
                `;
            }

            let pattern = {
                type: recurrence === "DAILY" ? "daily" : recurrence === "WEEKLY" ? "weekly" : recurrence === "MONTHLY" ? 'absoluteMonthly' : null, // recurrence type
                interval: recurrenceRepeat || 1, // every week
                daysOfWeek: recurrenceDaysArray, // specify days
                // firstDayOfWeek: "sunday"
                dayOfMonth: dayjs(startTime).tz(timezone).date()
            }
            let range = {
                startDate : dayjs(startTime).tz(timezone).format('YYYY-MM-DD'),
                recurrenceTimeZone: timezone
            }
            if(recurrenceEndDate) {
                range.type = "endDate", // recurrence end type
                range.endDate = dayjs(recurrenceEndDate).tz(timezone).format('YYYY-MM-DD')
            }

            else if(recurrenceCount) {
                range.type = "numbered";
                range.numberOfOccurrences = recurrenceCount
            }
            else if(recurrenceNeverEnds) {
                range.type = "noEnd"
            }
            const event = {
                subject: title || 'Test Title',
                body: {
                    content: content,
                    contentType: "HTML",
                },
                start: {
                    dateTime: startTime, // ISO 8601 format
                    timeZone: 'UTC'
                },
                end: {
                    dateTime: endTime, // ISO 8601 format
                    timeZone: 'UTC'
                },
                attendees: attendees,
                isOnlineMeeting: meetLink ? false : true,
                // onlineMeetingProvider: 'teamsForBusiness',
                hideAttendees: hideGuestList || false,
                location: meetLink ? { displayName: 'Online Meeting', locationUri: meetLink} : null,
                recurrence: {
                    pattern: pattern,
                    range: range
                },
            };

            const response = await client.api('/me/events').post(event);
            // console.log('Recurring event created:', response);
            let meetingLink = response?.onlineMeeting?.joinUrl
            let eventId = response?.id
            resolve({ meetingLink, eventId });
        } catch (error) {
            console.error('Error creating microsoft recurring event:', error);
            console.log('errrrrrrrrr------', error.statusCode)
            // Check if the error is due to expired token
            if (error.statusCode === 401) {
                console.log('Access token expired, refreshing token...');
                try {
                    const response = await refreshTokenMicrosoft(refreshToken);
                    const user = await db.user.findByPk(userId);

                    let tokens = {};

                    // Update tokens based on the email
                    if (user.email === email) {
                        tokens = { emailAccessToken: response.access_token, emailRefreshToken: response.refresh_token };
                    } else if (user.email2 === email) {
                        tokens = { email2AccessToken: response.access_token, email2RefreshToken: response.refresh_token };
                    } else if (user.email3 === email) {
                        tokens = { email3AccessToken: response.access_token, email3RefreshToken: response.refresh_token };
                    }

                    await db.user.update(tokens, { where: { id: userId } });

                    // Retry creating the recurring event with the new access token
                    createMicrosoftRecurringEvent(response.access_token, response.refresh_token, startTime, attendees, userId, email, title, endDateTime, meetLink, recurrence, recurrenceRepeat, recurrenceEndDate, recurrenceDaysArray,recurrenceCount, recurrenceNeverEnds)
                    .then(() => {
                        resolve();
                    });

                } catch (err) {
                    console.error('Error refreshing Microsoft token', err);
                    reject(err);
                }
            } else {
                reject(error);
            }
        }
    });
}

module.exports = { createMicrosoftRecurringEvent };
