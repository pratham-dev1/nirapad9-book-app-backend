
const MicrosoftGraph = require('@microsoft/microsoft-graph-client');
const db = require("../models/index");
const { refreshTokenMicrosoft } = require('./refreshTokenMicrosoft');

async function updateMicrosoftEvent(accessToken, refreshToken, eventId, title, startTime, userId, endDateTime, attendees = [], email,text ) {
    return new Promise(async (resolve, reject) => {
        try {
            const client = MicrosoftGraph.Client.init({
                authProvider: (done) => {
                    done(null, accessToken);
                }
            });
             let content = text
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
                updatedEvent.subject = title; // Add title only if it's provided
            }
            if (text) {
                updatedEvent.body = {
                    content: content,
                    contentType: 'HTML',
                };
            }
            if (attendees) {
                updatedEvent.attendees = attendees;
            }
            const response = await client.api(`/me/events/${eventId}`).patch(updatedEvent);

            resolve()
        } catch (error) {
            console.error('Error creating microsoft event:', error);
            console.log('errrrrrrrrr------', error.statusCode)
            if (error.statusCode === 401) {
                try {
                    const response = await refreshTokenMicrosoft(refreshToken)
                    const user = await db.user.findByPk(userId)
                    let tokens = {}
                    if(user.email === email) {
                        tokens = { emailAccessToken: response.access_token, emailRefreshToken: response.refresh_token }
                    }
                    else if(user.email2 === email) {
                        tokens = { email2AccessToken: response.access_token, email2RefreshToken: response.refresh_token }
                    }
                    else if(user.email3 === email) {
                        tokens = { email3AccessToken: response.access_token, email3RefreshToken: response.refresh_token }
                    }
                    await db.user.update(tokens, { where: { id: userId } })
                    updateMicrosoftEvent(response.access_token, response.refresh_token, eventId, title, startTime, userId, email).then(() => {
                        resolve()
                    })
                }
                catch (err) {
                    console.log('Error in refreshing Microsoft token', err)
                    reject(err)
                }
            }
            else reject(error);
            // throw { statusCode: 500, message: error.message }
        }
    })
}

module.exports = { updateMicrosoftEvent }