const MicrosoftGraph = require('@microsoft/microsoft-graph-client');
const db = require("../models/index");
const { refreshTokenMicrosoft } = require('./refreshTokenMicrosoft');
const dayjs = require('dayjs')
const dbviews = require("../dbviews") 

async function fetchMicrosoftEvents(accessToken, refreshToken, userId, email, nextSyncTokenForEvents) {
    return new Promise(async (resolve, reject) => {
        try {
            const client = MicrosoftGraph.Client.init({
                authProvider: (done) => {
                    done(null, accessToken);
                }
            });
            const startDate = new Date(); // set date for initial fetch
            // startDate.setDate(1);
            const endDate = new Date();
            endDate.setDate(endDate.getDate() + 30);
            let deltaLink = null;
            let nextLink = null;
            let eventsData = [];
            do {
                if (nextLink !== null) {     //for next page events fetching
                    deltaRequest = client
                        .api('/me/calendarView/delta')
                        .skipToken(nextLink)
                        .header('Prefer', 'odata.maxpagesize=100');
                }
                else if (nextSyncTokenForEvents == null) {  //for initial events fetching
                    deltaRequest = client
                        .api('/me/calendarView/delta')
                        .query({
                            startdatetime: startDate.toISOString(),
                            enddatetime: endDate.toISOString()
                        })
                        .header('Prefer', 'odata.maxpagesize=100');
                }
                else if (nextSyncTokenForEvents !== null) {    //for future events fetching
                    deltaRequest = client.api(nextSyncTokenForEvents);
                }
                let response = await deltaRequest.get();
                function extractMeetingLink(htmlContent) {
                    const content = htmlContent?.match(/<a\s+href="([^"]+)"[^>]*>/);
                    return content ? content[1]?.split('?')[0] : null;
                }
                function getAttendees(attendees) {
                    return attendees?.map((item) => item?.emailAddress.address).join(',');
                }
                if (response['@odata.nextLink']) {  // set next page token and next sync token
                    nextLink = response['@odata.nextLink'].split('$skiptoken=')[1];
                } else {
                    nextLink = null;
                    deltaLink = response['@odata.deltaLink'];
                }
                
                for (const item of response.value) {
                    const startDateTime = dayjs.utc(item?.start?.dateTime).toISOString()
                    const endDateTime =  dayjs.utc(item?.end?.dateTime).toISOString()
                    if (item['@removed']) {  // condition to handle deleted events 
                        const ifEventExist = await dbviews.event_merge_calendar_view.findAll({
                            where: {
                                emailAccount: email,
                                seriesMasterId: item.id,
                            },
                            raw: true
                        });
                        // console.log(ifEventExist)
                        // handle deletion of whole series
                        if (ifEventExist.length > 0) {
                            ifEventExist.forEach(event => {
                                const eventInResponse = response.value.find(responseEvent => responseEvent.id === event.eventId && responseEvent.type !== 'seriesMaster');
                                if (!eventInResponse) {
                                    eventsData.push({
                                        userId: userId,
                                        startTime: event.startTime,
                                        endTime: event.endTime,
                                        eventId: event.eventId,
                                        sender: event.sender,
                                        title: event.title || null,
                                        attendees: event.attendees,
                                        meetingLink: event.meetingLink,
                                        emailAccount: event.emailAccount,
                                        seriesMasterId: event.seriesMasterId,
                                        updatedAt: new Date().toISOString(),
                                        isDeleted: true,
                                        eventIdAcrossAllCalendar: event.eventIdAcrossAllCalendar
                                        // activeFlag: true
                                    });
                                }
                            });
                        }
                        else { // creating deletion row for single instances  
                            const existingEvent = await db.event.findOne({ where: { eventId: item.id } })
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
                                    seriesMasterId: existingEvent.seriesMasterId,
                                    updatedAt: new Date().toISOString(),
                                    isDeleted: true,
                                    eventIdAcrossAllCalendar: existingEvent.eventIdAcrossAllCalendar
                                    // activeFlag: true
                                });
                            }
                        }
                    }
                    else if (item.type == 'occurrence') {
                        const ifEventExist = await dbviews.event_merge_calendar_view.findAll({
                            where: {
                                emailAccount: email,
                                seriesMasterId: item.seriesMasterId,
                            },
                            raw: true
                        });
                        //   console.log(ifEventExist)
                        // let allEventsMatch = true;
                        const seriesMasterItem = response.value.find(instance => instance.type === 'seriesMaster' && instance.id === item.seriesMasterId);
                      
                        if (ifEventExist.length > 0) {
                            ifEventExist.forEach(event => {
                                const eventInResponse = response.value.find(responseEvent  => responseEvent.id === event.eventId && responseEvent.type !== 'seriesMaster');
                                if(!eventInResponse){
                                    const isDuplicate = eventsData.some(eventData => eventData.eventId === item.id);
                                    if (!isDuplicate) {
                                    eventsData.push({
                                        userId: userId,
                                        startTime: startDateTime,
                                        endTime:  endDateTime,
                                        eventId: item.id,
                                        sender: seriesMasterItem.organizer.emailAddress.address,
                                        title: seriesMasterItem.subject || null,
                                        attendees: getAttendees(seriesMasterItem.attendees),
                                        meetingLink: seriesMasterItem.onlineMeeting?.joinUrl || extractMeetingLink(seriesMasterItem.body.content),
                                        emailAccount: email,
                                        seriesMasterId: item.seriesMasterId,
                                        updatedAt: new Date().toISOString(),
                                        isDeleted: true,
                                        eventIdAcrossAllCalendar: seriesMasterItem.uid
                                        // activeFlag: true
                                    });
                                }
                                }
                            })
                        }     
                                const existingEvent = await dbviews.event_merge_calendar_view.findAll({
                                    where: {
                                        userId: userId,
                                        eventId: item.id,
                                        emailAccount: email,
                                        seriesMasterId: item.seriesMasterId,
                                    },
                                });
                                
                                let addEvent = true
                                if (existingEvent.length > 0) {
                                    if (
                                        existingEvent[0].dataValues.userId == userId &&
                                        existingEvent[0].dataValues.startTime == startDateTime &&
                                        existingEvent[0].dataValues.endTime == endDateTime &&
                                        existingEvent[0].dataValues.eventId == item.id &&
                                        existingEvent[0].dataValues.sender == seriesMasterItem.organizer.emailAddress.address &&
                                        (existingEvent[0].dataValues.title == seriesMasterItem.subject || null) && // Corrected parentheses
                                        existingEvent[0].dataValues.attendees == getAttendees(seriesMasterItem.attendees) && // Corrected comparison
                                        existingEvent[0].dataValues.meetingLink == (seriesMasterItem.onlineMeeting?.joinUrl || extractMeetingLink(seriesMasterItem.body.content)) && // Corrected parentheses
                                        existingEvent[0].dataValues.emailAccount == email &&
                                        existingEvent[0].dataValues.seriesMasterId == item.seriesMasterId &&
                                        existingEvent[0].dataValues.isCancelled == seriesMasterItem.isCancelled
                                    ) {
                                        addEvent = false;
                                    }
                                }
                                
                              if (addEvent) {
                                    eventsData.push({
                                        userId: userId,
                                        startTime: startDateTime,
                                        endTime:  endDateTime,
                                        eventId: item.id,
                                        sender: seriesMasterItem.organizer.emailAddress.address,
                                        title: seriesMasterItem.subject || null,
                                        attendees: getAttendees(seriesMasterItem.attendees),
                                        meetingLink: seriesMasterItem.onlineMeeting?.joinUrl || extractMeetingLink(seriesMasterItem.body.content),
                                        emailAccount: email,
                                        seriesMasterId: item.seriesMasterId,
                                        updatedAt: new Date().toISOString(),
                                        isCancelled: seriesMasterItem.isCancelled,
                                        eventIdAcrossAllCalendar: seriesMasterItem.uid
                                        // activeFlag: true
                                    });
                                }
                    }
                    else
                     if (item.type == 'seriesMaster'){
  
                        const existingEvent = await dbviews.event_merge_calendar_view.findAll({
                            where: {
                                userId: userId,
                                eventId: item.id,
                                emailAccount: email,
                                seriesMasterId: item.seriesMasterId,
                            },
                        });
                        let addEvent = true
                        if (existingEvent.length > 0) {
                            if (
                                existingEvent[0].dataValues.userId == userId &&
                                existingEvent[0].dataValues.startTime == startDateTime &&
                                existingEvent[0].dataValues.endTime == endDateTime &&
                                existingEvent[0].dataValues.eventId == item.id &&
                                existingEvent[0].dataValues.sender == item.organizer.emailAddress.address &&
                                (existingEvent[0].dataValues.title == item.subject || null) && 
                                existingEvent[0].dataValues.attendees == getAttendees(item.attendees) && 
                                existingEvent[0].dataValues.meetingLink == (item.onlineMeeting?.joinUrl || extractMeetingLink(item.body.content)) && // Corrected parentheses
                                existingEvent[0].dataValues.emailAccount == email &&
                                existingEvent[0].dataValues.seriesMasterId == item.seriesMasterId &&
                                existingEvent[0].dataValues.isCancelled == item.isCancelled
                            ) {
                                addEvent = false;
                            }
                        }
                        const existingEventInResponse = response.value.find(instance => instance.type === 'occurrence' && instance.seriesMasterId === item.id
                         && instance.startTime == item.startTime && instance.endTime == item.endTime);
                        if(addEvent && !existingEventInResponse){
                            eventsData.push({
                                userId: userId,
                                startTime: startDateTime,
                                endTime:  endDateTime,
                                eventId: item.id,
                                sender: item.organizer.emailAddress.address,
                                title: item.subject || null,
                                attendees: getAttendees(item.attendees),
                                meetingLink: item.onlineMeeting?.joinUrl || extractMeetingLink(item.body.content),
                                emailAccount: email,
                                seriesMasterId: item.seriesMasterId,
                                updatedAt: new Date().toISOString(),
                                isCancelled: item.isCancelled,
                                eventIdAcrossAllCalendar: item.uid
                                // activeFlag: true
    
                            });
                        }
                     }
                     else { 
                        const existingEvent = await dbviews.event_merge_calendar_view.findAll({
                            where: {
                                userId: userId,
                                eventId: item.id,
                                emailAccount: email,
                                seriesMasterId: item.seriesMasterId,
                            },
                        });
                        let addEvent = true
                        if (existingEvent.length > 0) {
                            if (
                                existingEvent[0].dataValues.userId == userId &&
                                existingEvent[0].dataValues.startTime == startDateTime &&
                                existingEvent[0].dataValues.endTime ==  endDateTime &&
                                existingEvent[0].dataValues.eventId == item.id &&
                                existingEvent[0].dataValues.sender == item.organizer.emailAddress.address &&
                                (existingEvent[0].dataValues.title == item.subject || null) && // Corrected parentheses
                                existingEvent[0].dataValues.attendees ==  getAttendees(item.attendees) && // Corrected comparison
                                existingEvent[0].dataValues.meetingLink == (item.onlineMeeting?.joinUrl || extractMeetingLink(item.body.content)) && // Corrected parentheses
                                existingEvent[0].dataValues.emailAccount == email &&
                                existingEvent[0].dataValues.seriesMasterId == item.seriesMasterId &&
                                existingEvent[0].dataValues.isCancelled == item.isCancelled
                            ) {
                                addEvent = false;
                            }
                        }
                        if(addEvent){
                        const startDateTime = dayjs.utc(item.start.dateTime).toISOString();
                        const isEventAlreadyExist = await dbviews.event_merge_calendar_view.findOne({where: {eventId: item.id, userId, emailAccount: email}})
                        eventsData.push({
                            userId: userId,
                            startTime: startDateTime,
                            endTime: endDateTime,
                            eventId: item.id,
                            sender: item.organizer.emailAddress.address,
                            title: item.subject || null,
                            attendees: getAttendees(item.attendees),
                            meetingLink: item.onlineMeeting?.joinUrl || extractMeetingLink(item.body.content),
                            emailAccount: email,
                            seriesMasterId: item.seriesMasterId,
                            updatedAt: new Date().toISOString(),
                            isCancelled: item.isCancelled,
                            eventIdAcrossAllCalendar: item.uid,
                            type: item.isCancelled ? 'cancel_event' : isEventAlreadyExist ? 'update_event' : 'create_event'
                            // activeFlag: true
                        });
                    }
                    }                                   
                }
                //  console.log(response)
                //  console.log(deltaLink)
                //save the next Sync token for matching emails
                const user = await db.user.findByPk(userId)
                if (user.email == email) {
                    user.nextSyncTokenForEmail = deltaLink
                } else if (user.email2 == email) {
                    user.nextSyncTokenForEmail2 = deltaLink
                } else if (user.email3 == email) {
                    user.nextSyncTokenForEmail3 = deltaLink
                }
                await user.save()
            //     const color = await db.event_color.findAll({})
            //     eventsData = eventsData.map((item) => {  
            //     if(user.email === item.emailAccount) {
            //         return {...item, eventColorId: color[0].id, eventColor: color[0].color}
            //     }
            //     else if (user.email2 === item.emailAccount) {
            //         return {...item, eventColorId: color[1].id, eventColor: color[1].color}
            //     }
            //     else if (user.email3 === item.emailAccount) {
            //         return {...item, eventColorId: color[2].id, eventColor: color[2].color}
            //     }
            // })
            
                // for (const item of eventsData) {
                //     const response = await db.event.findAll({ where: { userId: item.userId, eventId: item.eventId, emailAccount: item.emailAccount } })
                //     for (const event of response) {
                //         event.activeFlag = false
                //         await event.save()
                //     }
                // }
                await db.event.bulkCreate(eventsData);
            } while (nextLink !== null)//run loop until there is no next page
            resolve(eventsData);
        } catch (error) {
            console.log('Error in fetching microsoft events', error)
            console.log('errrrrrrrrr------', error.statusCode)
            if (error.statusCode === 401) {
                try {
                    const response = await refreshTokenMicrosoft(refreshToken)
                    const user = await db.user.findByPk(userId)
                    let tokens = {}
                    if (user.email === email) {
                        tokens = { emailAccessToken: response.access_token, emailRefreshToken: response.refresh_token }
                    }
                    else if (user.email2 === email) {
                        tokens = { email2AccessToken: response.access_token, email2RefreshToken: response.refresh_token }
                    }
                    else if (user.email3 === email) {
                        tokens = { email3AccessToken: response.access_token, email3RefreshToken: response.refresh_token }
                    }
                    await db.user.update(tokens, { where: { id: userId } })
                    fetchMicrosoftEvents(response.access_token, response.refresh_token, userId, email).then(() => {
                        resolve()
                    })
                }
                catch (err) {
                    console.log(err)
                    reject('Error in refresing microsoft token', err)
                }
            }
            else reject(error);
        }
    });
}

module.exports = { fetchMicrosoftEvents }
