const express = require("express");
const { fetchGoogleEvents } = require("../utils/fetchGoogleEvents");
const { getIo, getConnectedUsers } = require("../utils/socket");
const db = require("../models");
const { Op } = require("sequelize");
const dbviews = require("../dbviews");
const router = express.Router();

router.post('/webhook', async (req, res) => {
  try {
    // console.log('listening')
    // console.log('details',req.headers)
    // console.log('body',req.body)
    const resourceId = req.headers['x-goog-resource-id']
    const channelId = req.headers['x-goog-channel-id']
    if (!channelId) {
      return res.status(400).send('Invalid request: Missing resource ID');
    }
    // const user = await db.user.findOne({where: {googleResourceIdEmail1: resourceId}})
    const user = await db.user.findOne({
      where: {
        [Op.or]: [
          { googleChannelIdEmail1: channelId },
          { googleChannelIdEmail2: channelId },
          { googleChannelIdEmail3: channelId }
        ]
      }
    });
    if (!user) return;
    let failedEmails = [], accessToken, refreshToken, email, nextSyncToken
    if (user.googleChannelIdEmail1 === channelId) {
      accessToken = user.emailAccessToken
      refreshToken = user.emailRefreshToken
      email = user.email
      nextSyncToken = user.nextSyncTokenForEmail
    }
    else if (user.googleChannelIdEmail2 === channelId) {
      accessToken = user.email2AccessToken
      refreshToken = user.email2RefreshToken
      email = user.email2
      nextSyncToken = user.nextSyncTokenForEmail2
    }
    else if (user.googleChannelIdEmail3 === channelId) {
      accessToken = user.email3AccessToken
      refreshToken = user.email3RefreshToken
      email = user.email3
      nextSyncToken = user.nextSyncTokenForEmail3
    }
    const events = await fetchGoogleEvents(accessToken, refreshToken, user.id, email, nextSyncToken).catch((error) => {
      failedEmails.push(email)
    }) || []
    // console.log(events)
    const io = getIo()
    const connectedUsers = getConnectedUsers()
    for (const event of events) {
      if(!user.isNotificationDisabled) {
      const createdAt = new Date().toISOString()
      const description = event.type === 'create_event' ? 'New Event Created' : event.type === 'update_event' ? 'Event Updated' : event.type === 'cancel_event' ? 'Event Cancelled' : 'Undefined'
      const eventSource = await dbviews.event_hub_history_view.findOne({ where: { eventId: event.eventId, userId: event.userId, emailAccount: event.emailAccount }, attributes: ['source', 'creatorFlag', 'sourceId'] })
      let openAvailabilityData;
      let initialData = { description, datetime: event.startTime, type: event.type, meetingLink: event.meetingLink, createdAt, creator: eventSource?.creatorFlag, eventId: event.eventId, title: event.title, emailAccount: event.emailAccount, source: eventSource?.source || event.source, openAvailabilityId: eventSource?.sourceId || event.sourceId, eventIdAcrossAllCalendar: event.eventIdAcrossAllCalendar }
      if (initialData?.source === 'open_availabilities') {
        openAvailabilityData = await db.open_availability.findByPk(initialData?.openAvailabilityId, { attributes: ['receiverName', 'receiverEmail', 'comments'] });
      }
      const notification = await db.notification.create({...initialData, userId: event.userId })
      io.to(connectedUsers.get(+event?.userId)).emit('EVENT_NOTIFICATION', {...initialData, id: notification.id  , openAvailabilityData: { receiverName: openAvailabilityData?.receiverName, receiverEmail: openAvailabilityData?.receiverEmail, comments: openAvailabilityData?.comments } })
    }
    else {
      io.to(connectedUsers.get(+event?.userId)).emit('EVENT_NOTIFICATION', {isNotificationDisabled: true})
    }
    }
    return res.status(200).send('OK');
  }
  catch (err) {
    console.log(err)
    throw new Error(err.message)
  }
});

module.exports = router;
