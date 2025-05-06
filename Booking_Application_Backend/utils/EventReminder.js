const cron = require('node-cron');
const dbviews = require('../dbviews');
const db = require('../models');
const { getIo, getConnectedUsers } = require('./socket');
const dayjs = require('dayjs');

cron.schedule('* * * * *', async () => {
    try {
        const now = dayjs().utc();
        const TenMinutesLater = now.add(10, 'minutes');   // Adding 10 minutes
        const TenMinutesLaterEnd = TenMinutesLater.add(1, 'minute') // Allow a 1-minute range
        const events = await db.event.findAll({
            where: {
                activeFlag: true,
                startTime: {
                    [db.Sequelize.Op.between]: [TenMinutesLater.toISOString(), TenMinutesLaterEnd.toISOString()],
                },
                isReminderSent: false
            },
            include: {
                model: db.user,
                attributes: ['id', 'isNotificationDisabled']
            }
        });
        for (const event of events) {
            event.isReminderSent = true  // updating value in table
            await event.save()

            if (!event?.user?.isNotificationDisabled) {
                const io = getIo()
                const connectedUsers = getConnectedUsers()
                const userId = event.userId
                const description = `Reminder - Your upcoming event is ${event.title}`
                const createdAt = new Date().toISOString()
                const eventSource = await dbviews.event_hub_history_view.findOne({ where: { eventId: event.eventId, userId: event.userId, emailAccount: event.emailAccount }, attributes: ['source', 'creatorFlag', 'sourceId'] })

                let initialData = {
                    userId, 
                    description, 
                    datetime: event.startTime, 
                    type: 'reminder', 
                    meetingLink: event.meetingLink, 
                    createdAt, 
                    creator: eventSource?.creatorFlag, 
                    eventId: event.eventId, 
                    title: event.title, 
                    emailAccount: event.emailAccount, 
                    source: eventSource?.source, 
                    openAvailabilityId: eventSource?.sourceId, 
                    eventIdAcrossAllCalendar: event.eventIdAcrossAllCalendar 
                }
                let openAvailabilityData;
                if (eventSource?.source === 'open_availabilities') {
                    openAvailabilityData = await db.open_availability.findByPk(eventSource?.sourceId, { attributes: ['receiverName', 'receiverEmail'] });
                  }

                const notification = await db.notification.create({ ...initialData })
                io.to(connectedUsers.get(+userId)).emit('OPEN_SLOT_EVENT_BOOKED', {...initialData, id: notification.id, openAvailabilityData: { receiverName: openAvailabilityData?.receiverName, receiverEmail: openAvailabilityData?.receiverEmail } })
            }
        }
    }
    catch (error) {
        console.log('Reminder event error -', error)
    }
});