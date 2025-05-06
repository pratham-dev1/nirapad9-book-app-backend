const cron = require('node-cron');
const db = require('../models');
const { sendNotification } = require('./mailgun');
const dayjs = require('dayjs');

// Email reminder before 24 hours of booked slot
cron.schedule('* * * * *', async () => {
    try {
        const now = dayjs().utc(); 
        const twentyFourHoursLater = now.add(24, 'hour');; // Exactly 24 hours from now
        const twentyFourHoursLaterEnd = twentyFourHoursLater.add(1, 'minute'); // Allow a 1-minute range

        const results = await db.open_availability.findAll({
            where: {
                booked: true,
                isEmailReminderSent: false,
                isCancelled: false,
                datetime: {
                    [db.Sequelize.Op.between]: [twentyFourHoursLater.toISOString(), twentyFourHoursLaterEnd.toISOString()]   // Finds events exactly 24 hours from now (within a 1-minute range)
                }
            }
        });
        for (const item of results) {
            item.isEmailReminderSent = true
            await item.save()
            const date = dayjs(item.datetime).tz(item.guestTimezone).format("DD-MM-YYYY")
            const startTime = dayjs(item.datetime).tz(item.guestTimezone).format("h:mm A")
            const endTime = dayjs(item.endtime).tz(item.guestTimezone).format("h:mm A")
            const location = item.meetType === 3 ? 
                  `${item.houseNo ? item.houseNo + ", " : ""}${item.houseName ? item.houseName + ", " : ""}${
                    item.street ? item.street + ", " : ""
                  }${item.area ? item.area + ", " : ""}${item.cityDetails?.name ? item.cityDetails.name + ", " : ""}${
                    item.stateDetails?.name ? item.stateDetails.name + ", " : ""
                  }${item.pincode ? item.pincode + ", " : ""}${item.landmark ? item.landmark + ", " : ""}<br/>
                  ${
                    item.mapLink
                      ? `Map Link: <a href="${item.mapLink}" target="_blank">Click here</a>`
                      : ""
                  }`
                : `<a href="${item.meetingLink}" target="_blank">Join Meeting</a>`;
                
            const content =  `Your Upcoming Event : <br/><br/> 
            Date: ${date} <br/> 
            Start Time: ${startTime} <br/> 
            End Time: ${endTime} <br/><br/>
            Location: ${location}`;

            sendNotification(item.receiverEmail, 'Event Reminder', content, null)
        }
    }
    catch (error) {
        console.log('Booked slot event reminder -', error)
    }
});