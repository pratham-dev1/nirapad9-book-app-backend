const express = require("express");
const { getIo, getConnectedUsers } = require("../utils/socket");
const db = require("../models");
const { Op } = require("sequelize");
const dbviews = require("../dbviews");
const { fetchMicrosoftEventById } = require("../utils/fetchMicrosoftEventById");
const { fetchMicrosoftEvents } = require("../utils/fetchMicrosoftEvents");
const dayjs = require("dayjs");
const router = express.Router();

let PQueue;

async function loadPQueue() {
  if (!PQueue) {
    PQueue = (await import('p-queue')).default; // Dynamically import PQueue
  }
}

function getAttendees(attendees) {
  return attendees?.map((item) => item?.emailAddress.address).join(',');
}

function extractMeetingLink(htmlContent) {
  const content = htmlContent?.match(/<a\s+href="([^"]+)"[^>]*>/);
  return content ? content[1]?.split('?')[0] : null;
}

router.post('/webhook', async (req, res) => {
    try {
        await loadPQueue(); // Ensure PQueue is loaded before using it
        const validationToken = req.query.validationToken;
        
        if (validationToken) {
            // required for creating subscription
            return res.status(200).send(validationToken);
        }

        const body = req.body?.value[0];
        const subscriptionId = body?.subscriptionId;

        if (subscriptionId) {
            // Initialize the queue with concurrency = 1
            const queue = new PQueue({ concurrency: 1 });
            // Send response early to acknowledge webhook notification
            res.status(202).send('OK');
            // Enqueue the notification processing task
            queue.add(async () => {
                try {
                    const eventId = body?.resourceData?.id;
                    const user = await db.user.findOne({
                        where: {
                            [Op.or]: [
                                { microsoftSubscriptionIdEmail1: subscriptionId },
                                { microsoftSubscriptionIdEmail2: subscriptionId },
                                { microsoftSubscriptionIdEmail3: subscriptionId }
                            ]
                        }
                    });

                    if (!user) return;
                    
                    let accessToken, refreshToken, email, nextSyncToken;
                    if (user.microsoftSubscriptionIdEmail1 === subscriptionId) {
                        accessToken = user.emailAccessToken;
                        refreshToken = user.emailRefreshToken;
                        email = user.email;
                        nextSyncToken = user.nextSyncTokenForEmail;
                    } else if (user.microsoftSubscriptionIdEmail2 === subscriptionId) {
                        accessToken = user.email2AccessToken;
                        refreshToken = user.email2RefreshToken;
                        email = user.email2;
                        nextSyncToken = user.nextSyncTokenForEmail2;
                    } else if (user.microsoftSubscriptionIdEmail3 === subscriptionId) {
                        accessToken = user.email3AccessToken;
                        refreshToken = user.email3RefreshToken;
                        email = user.email3;
                        nextSyncToken = user.nextSyncTokenForEmail3;
                    }

                    let description, type;
                    let eventsDetails = {};
                    const existingEvent = await db.event.findOne({
                        where: { eventId, userId: user?.id, emailAccount: email, activeFlag: true }
                    });
                    let newEvent, notFound = false;
                    try {
                      newEvent = await fetchMicrosoftEventById(accessToken, refreshToken, user?.id, email, eventId);
                    }
                    catch (err) {
                        if (err.statusCode === 404) {         // if event deleted or cancelled by creator itself then we will get this error if we try to find event in microsoft server
                            notFound = true
                        }
                    }
                    const startTime = dayjs.utc(newEvent?.start?.dateTime).toISOString();
                    const endTime = dayjs.utc(newEvent?.end?.dateTime).toISOString();
                    if (!existingEvent) {
                        description = "New Event Created";
                        type = 'create_event';
                        eventsDetails = {
                            userId: user?.id,
                            startTime,
                            endTime,
                            eventId: newEvent?.id,
                            sender: newEvent?.organizer?.emailAddress?.address.toLowerCase(),
                            title: newEvent?.subject || null,
                            attendees: newEvent?.attendees && getAttendees(newEvent?.attendees),
                            meetingLink: newEvent?.onlineMeeting?.joinUrl || extractMeetingLink(newEvent?.body?.content),
                            emailAccount: email,
                            seriesMasterId: newEvent?.seriesMasterId,
                            updatedAt: new Date().toISOString(),
                            isCancelled: newEvent?.isCancelled,
                            eventIdAcrossAllCalendar: newEvent?.uid,
                            source: newEvent?.categories?.[0]?.split('-')?.[0],
                            sourceId: newEvent?.categories?.[0]?.split('-')?.[1] ? parseInt(newEvent?.categories?.[0]?.split('-')?.[1]) : null,
                            isMicrosoftParentRecurringEvent: newEvent.type === 'seriesMaster' ? true : false      // extra flag to filter because recurring event is not coming in notification - only first instance is coming so we are fetching all events again - this causing saving 2 same duplicate event of first instance
                        };
                        await db.event.create(eventsDetails);
                        if(newEvent.type === 'seriesMaster') {                // if recurring event then need to fetch all instances because in notification we are only getting single event
                           await fetchMicrosoftEvents(accessToken, refreshToken, user.id, email, nextSyncToken)
                        }   
                    } 
                    else if(notFound && !existingEvent.isCancelled) {          //  !existingEvent.isCancelled - this condition is to prevent multiple db entry and multiple notification for cancel event
                        description = 'Event Cancelled'; 
                        type = "cancel_event";
                        eventsDetails = {
                            userId: user?.id,
                            startTime: existingEvent.startTime,
                            endTime: existingEvent.endTime,
                            eventId: existingEvent?.eventId,
                            sender: existingEvent.sender,
                            title: existingEvent.title || null,
                            attendees: existingEvent.attendees,
                            meetingLink: existingEvent.meetingLink,
                            emailAccount: existingEvent.emailAccount,
                            seriesMasterId: existingEvent?.seriesMasterId,
                            updatedAt: new Date().toISOString(),
                            isCancelled: true,
                            isDeleted: true,
                            eventIdAcrossAllCalendar: existingEvent.eventIdAcrossAllCalendar,
                            isMicrosoftParentRecurringEvent: existingEvent.isMicrosoftParentRecurringEvent,
                            source: existingEvent.source,
                            sourceId: existingEvent.sourceId
                        };
                        await db.event.create(eventsDetails);
                    }

                    else if (
                        existingEvent.startTime !== startTime ||
                        existingEvent.endTime !== endTime ||
                        existingEvent.title !== (newEvent.subject || null) ||
                        existingEvent.attendees !== getAttendees(newEvent.attendees) ||
                        existingEvent.meetingLink !== (newEvent.onlineMeeting?.joinUrl || extractMeetingLink(newEvent.body.content)) ||
                        existingEvent.emailAccount !== email ||
                        existingEvent.isCancelled !== newEvent.isCancelled
                    ) {
                        eventsDetails = {
                            userId: user?.id,
                            startTime,
                            endTime,
                            eventId: newEvent?.id,
                            sender: newEvent?.organizer?.emailAddress?.address,
                            title: newEvent?.subject || null,
                            attendees: newEvent?.attendees && getAttendees(newEvent?.attendees),
                            meetingLink: newEvent?.onlineMeeting?.joinUrl || extractMeetingLink(newEvent?.body?.content),
                            emailAccount: email,
                            seriesMasterId: newEvent?.seriesMasterId,
                            updatedAt: new Date().toISOString(),
                            isCancelled: newEvent?.isCancelled,
                            eventIdAcrossAllCalendar: newEvent?.uid,
                            source: existingEvent.source,
                            sourceId: existingEvent.sourceId
                        };
                        await db.event.create(eventsDetails);

                        if (existingEvent?.isCancelled !== newEvent?.isCancelled) {       // if user is not the owner
                            description = 'Event Cancelled';
                            type = "cancel_event";
                        } else {
                            description = 'Event Updated';
                            type = "update_event";
                        }
                    }
                    else {
                      return;
                    }
                    const io = getIo();
                    const connectedUsers = getConnectedUsers();
                    const createdAt = new Date().toISOString();
                    if(!user.isNotificationDisabled) {
                    const eventSource = await dbviews.event_hub_history_view.findOne({
                        where: { eventId: eventsDetails?.eventId, userId: eventsDetails?.userId, emailAccount: eventsDetails.emailAccount },
                        attributes: ['source', 'creatorFlag', 'sourceId']
                    });
                    let openAvailabilityData;
                    let initialData = {
                        description,
                        datetime: eventsDetails.startTime,
                        type,
                        meetingLink: eventsDetails.meetingLink,
                        createdAt,
                        creator: eventSource.creatorFlag,
                        eventId: eventsDetails.eventId,
                        title: eventsDetails.title,
                        source: eventSource?.source || eventsDetails?.source,
                        openAvailabilityId: eventSource?.sourceId || eventsDetails?.sourceId,
                        emailAccount: eventsDetails.emailAccount,
                        eventIdAcrossAllCalendar: eventsDetails.eventIdAcrossAllCalendar
                    };

                    if (initialData.source === 'open_availabilities') {
                        openAvailabilityData = await db.open_availability.findByPk(initialData?.openAvailabilityId, {
                            attributes: ['receiverName', 'receiverEmail', 'comments']
                        });
                    }

                    const notification = await db.notification.create({
                        ...initialData, userId: eventsDetails.userId
                    });
                    io.to(connectedUsers.get(+eventsDetails?.userId)).emit('EVENT_NOTIFICATION', {
                        ...initialData,
                        id: notification.id,
                        openAvailabilityData: {
                            receiverName: openAvailabilityData?.receiverName,
                            receiverEmail: openAvailabilityData?.receiverEmail,
                            comments: openAvailabilityData?.comments
                        }
                    });
                }
                else {
                    io.to(connectedUsers.get(+eventsDetails?.userId)).emit('EVENT_NOTIFICATION', {isNotificationDisabled: true})
                }
                } catch (error) {
                    console.log('Error in PQueue task:', error);
                }
            });

        }
    } catch (err) {
        console.log('Microsoft Webhook ERROR: ', err);
        return res.status(500).send('Error processing webhook');
    }
});

module.exports = router;
