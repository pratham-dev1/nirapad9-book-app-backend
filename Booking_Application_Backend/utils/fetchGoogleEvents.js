const { google } = require('googleapis');
const db = require('../models/index')
const dayjs = require('dayjs');
function fetchGoogleEvents(accessToken, refreshToken, userId, email, syncToken) {
    return new Promise(async (resolve, reject) => {
        try {
            const oAuth2Client = new google.auth.OAuth2({
                clientId: process.env.GOOGLE_CLIENT_ID,
                clientSecret: process.env.GOOGLE_CLIENT_SECRET,
                redirectUri: `/auth/google/callback`,
            });

            oAuth2Client.setCredentials({
                access_token: accessToken,
                refresh_token: refreshToken,
            });

            // const eventResponse = await db.event.findOne({
            //     attributes: [
            //         db.Sequelize.fn('max', db.Sequelize.col('updatedAt'))
            //     ],
            //     where: {
            //         emailAccount: email
            //     },
            //     raw: true
            // });

            // const lastUpdateTime = eventResponse.max;

            const startDate = new Date();
            // startDate.setDate(1);

            const calendar = google.calendar({ version: 'v3', auth: oAuth2Client });
            const props = {
                calendarId: 'primary',
                timeMin: startDate.toISOString(),
                // timeMax: endDate.toISOString(),
                // updatedMin: lastUpdateTime ? lastUpdateTime : undefined,
                singleEvents: true,
                maxResults: 2500,
                // orderBy: 'startTime',
            }
            if (syncToken) {
                props['syncToken'] = syncToken
                delete props.timeMin
            }
            const events = await calendar.events.list(props);

            // console.log('events', events);
            // console.log('details,', events.data.items)

            function extractMeetingLink(description) {
                const urlRegex = /(https?:\/\/[^\s>]+)/g;
                const meetingLinks = description?.match(urlRegex) || [];
                return meetingLinks.filter((item) => (item.includes('meetup-join') || item.includes('join.skype.com')))[0]
            }

            function getAttendees(attendees) {
                return attendees?.map((item) => item.email).join(',');
            }

            let eventsData = []
            // const eventsData = events.data.items.map( (item) => {
            const user = await db.user.findByPk(userId)
            for (const item of events.data.items) {
                const existingEvent = await db.event.findOne({where: { eventId: item.id, userId, emailAccount: email, activeFlag: true }})
                if (item.status === 'cancelled') {
                    // Handle cancelled event
                    if (existingEvent) {
                        eventsData.push({
                            userId: userId,
                            startTime: existingEvent.startTime,
                            endTime: existingEvent.endTime,
                            eventId: item.id,
                            sender: existingEvent.sender,
                            title: existingEvent.title || null,
                            attendees: existingEvent.attendees,
                            meetingLink: existingEvent.meetingLink,
                            emailAccount: email,
                            updatedAt: new Date().toISOString(),
                            isDeleted: true,
                            type: 'cancel_event',
                            eventIdAcrossAllCalendar: existingEvent.eventIdAcrossAllCalendar,
                            source: existingEvent.source,
                            sourceId: existingEvent.sourceId
                            // activeFlag: true
                        });
                    }
                } else if(item.start.dateTime) {
                    eventsData.push({
                        userId: userId,
                        startTime: new Date(item.start.dateTime || item.start.date).toISOString(),
                        endTime: new Date(item.end.dateTime || item.end.date).toISOString(),
                        eventId: item.id,
                        sender: item.organizer.email,
                        title: item.summary || null,
                        attendees: getAttendees(item.attendees),
                        meetingLink: item.hangoutLink || item?.location || extractMeetingLink(item.description),
                        emailAccount: email,
                        updatedAt: new Date().toISOString(),
                        eventIdAcrossAllCalendar: item.iCalUID,
                        // creator: (user.email === item.organizer.email || user.email2 === item.organizer.email || user.email3 === item.organizer.email) ? true : false,
                        type: existingEvent ? 'update_event' : 'create_event',
                        source: item?.extendedProperties?.private?.source,
                        sourceId: item?.extendedProperties?.private?.sourceId
                        // activeFlag: true
                    });
                } else if(item.start.date) {
                    const startDateTime = dayjs.tz(item.start.date, events.data.timeZone).utc();
                    const endDateTime = dayjs.tz(item.end.date, events.data.timeZone).utc();
                    // console.log(startDateTime.toISOString())
                    // console.log(endDateTime.toISOString())
                    eventsData.push({
                        userId: userId,
                        startTime: startDateTime.toISOString(),
                        endTime: endDateTime.toISOString(),
                        eventId: item.id,
                        sender: item.organizer.email,
                        title: item.summary || null,
                        attendees: getAttendees(item.attendees),
                        meetingLink: item.hangoutLink || extractMeetingLink(item.description),
                        emailAccount: email,
                        updatedAt: new Date().toISOString(),
                        eventIdAcrossAllCalendar: item.iCalUID,
                        // creator: (user.email === item.organizer.email || user.email2 === item.organizer.email || user.email3 === item.organizer.email) ? true : false,
                        type: existingEvent ? 'update_event' : 'create_event',
                        source: item?.extendedProperties?.private?.source,
                        sourceId: item?.extendedProperties?.private?.sourceId
                        // activeFlag: true
                    });
                }

            };

            // const user = await db.user.findByPk(userId)
            // const color = await db.event_color.findAll({})
            // eventsData = eventsData.map((item) => {  
            //         if(user.email === item.emailAccount) {
            //             return {...item, eventColorId: color[0].id, eventColor: color[0].color}
            //         }
            //         else if (user.email2 === item.emailAccount) {
            //             return {...item, eventColorId: color[1].id, eventColor: color[1].color}
            //         }
            //         else if (user.email3 === item.emailAccount) {
            //             return {...item, eventColorId: color[2].id, eventColor: color[2].color}
            //         }
            // })

            // for (const item of eventsData) {
            //     const response = await db.event.findAll({ where: { userId: item.userId, eventId: item.eventId, emailAccount: item.emailAccount } })
            //     for (const event of response) {
            //         event.activeFlag = false
            //         await event.save()
            //     }
            // }
            
            const nextSyncToken = events.data.nextSyncToken
                if (user.email == email) {
                    user.nextSyncTokenForEmail = nextSyncToken
                } else if (user.email2 == email) {
                    user.nextSyncTokenForEmail2 = nextSyncToken
                } else if (user.email3 == email) {
                    user.nextSyncTokenForEmail3 = nextSyncToken
                }
            await user.save()
            await db.event.bulkCreate(eventsData)
            resolve(eventsData);
        } catch (error) {
            console.log('Error in fetching google events', error)
            if(error.status === 410) {   // status 410 indicating that syncToken could not be verified - Full sync required again
                    fetchGoogleEvents(accessToken, refreshToken, userId, email, null) // passing syncToken = null
                    .then((eventsData) => {
                        resolve(eventsData)
                    }) 
                }
            else reject(error);
        }
    });
}

module.exports = { fetchGoogleEvents }
