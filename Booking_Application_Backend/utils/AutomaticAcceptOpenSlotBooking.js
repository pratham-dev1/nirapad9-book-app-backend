const cron = require('node-cron');
const db = require('../models');
const { sendNotification } = require('./mailgun');
const dayjs = require('dayjs');

// Automatic accepting the booking after 1 hour
cron.schedule('* * * * *', async () => {
    try {
        const now = dayjs().utc();
        const oneHourAgo = now.subtract(1, 'hour').toISOString();  // Subtracting 1 hour
        const results = await db.open_availability.findAll({
            where: {
                isAcceptedByOwner: false,
                booked: true,
                isCancelled: false,
                bookedAt: {
                    [db.Sequelize.Op.lte]: oneHourAgo
                },
            }
        });
        for (const item of results) {
            item.statusId = 2
            item.isAcceptedByOwner = true  // updating value in table
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
                
            const content =  `Your booking has been confirmed for the following details: <br/><br/> 
            Date: ${date} <br/> 
            Start Time: ${startTime} <br/> 
            End Time: ${endTime} <br/><br/>
            Location: ${location}`;

            sendNotification(item.receiverEmail, 'Booking Accepted', content, null, item.senderEmail)
        }
    }
    catch (error) {
        console.log('Automatic Slot Accept error -', error)
    }
});