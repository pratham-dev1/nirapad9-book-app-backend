
const MicrosoftGraph = require('@microsoft/microsoft-graph-client');
const db = require("../models/index");
const { refreshTokenMicrosoft } = require('./refreshTokenMicrosoft');

async function sendMicrosoftEvent(accessToken, refreshToken, startTime, attendees, userId, email, title, endDateTime, meetLink, hideGuestList, text, source, meetType) {
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
            const event = {
                subject: title || 'Test title',
                body: {
                    content: content,
                    contentType: 'HTML',
                },
                start: {
                    dateTime: startTime,
                    timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
                },
                end: {
                    dateTime: endTime,
                    timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
                },
                attendees: attendees,
                isOnlineMeeting: meetType === 3 ? false : true,     // meetType = 3 (In-person type)


                // onlineMeetingProvider: 'teamsForBusiness',
                hideAttendees: hideGuestList || false,    // if this is set to true - then it will not add the event in google attendees calendar until they respond to yes
                location: meetLink ? { displayName: 'Online Meeting', locationUri: meetLink} : null,
                categories: source ? [source] : []
            };
            // console.log(event.hideAttendees)
            // Will generate teams link for work account and skype link for personal account
            const response = await client.api('/me/events').post(event);
            // console.log('Event created -', response);
            let meetingLink = response?.onlineMeeting?.joinUrl || meetLink
            let eventId = response?.id
            resolve({ meetingLink, eventId });
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
                    sendMicrosoftEvent(response.access_token, response.refresh_token, startTime, attendees, userId, email, title, endDateTime, meetLink, hideGuestList, text, source, meetType).then((res) => {
                        let meetingLink = res?.meetingLink
                        let eventId = res?.eventId
                        resolve({ meetingLink, eventId });
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

module.exports = { sendMicrosoftEvent }