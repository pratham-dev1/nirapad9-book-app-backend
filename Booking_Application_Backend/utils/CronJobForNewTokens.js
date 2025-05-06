const cron = require('node-cron');
const db = require('../models');
const dayjs = require('dayjs');
const { refreshTokenMicrosoft } = require('./refreshTokenMicrosoft');

const generateTokenForEmails = async (user, emailSyncTimeStampColumn, accessTokenColumn, refreshTokenColumn) => {
    const ninetyDaysMark = dayjs(user[emailSyncTimeStampColumn]).add(90, 'days')             // token expires in 90 days
    const currentDatetime = dayjs()
    const daysLeft = ninetyDaysMark.diff(currentDatetime, 'days')         
    if(daysLeft <= 5) {                                                                      // run cron job on 85th day
       const response = await refreshTokenMicrosoft(user[refreshTokenColumn])
       user[accessTokenColumn] = response.access_token;
       user[refreshTokenColumn] = response.refresh_token;
       user[emailSyncTimeStampColumn] = new Date().toISOString()
       await user.save();
    }
}

cron.schedule('0 0 * * *', async () => {       // Task is running at 12:00 AM every night
    try {
        const users = await db.user.findAll({attributes: ['id','email', 'email2', 'email2', 'emailServiceProvider', 'email2ServiceProvider', 'email3ServiceProvider', 'emailRefreshToken', 'email2RefreshToken', 'email3RefreshToken', 'emailSyncTimeStamp', 'email2SyncTimeStamp', 'email3SyncTimeStamp']})
        for (const user of users) {
            try {
            if(user.emailServiceProvider === 'microsoft' && user?.emailSyncTimeStamp) {
               await generateTokenForEmails(user, 'emailSyncTimeStamp', 'emailAccessToken', 'emailRefreshToken')
            }
            if(user.email2ServiceProvider === 'microsoft' && user?.email2SyncTimeStamp) {
                await generateTokenForEmails(user, 'email2SyncTimeStamp', 'email2AccessToken', 'email2RefreshToken')
            }
            if(user.email3ServiceProvider === 'microsoft' && user?.email3SyncTimeStamp) {
                await generateTokenForEmails(user, 'email3SyncTimeStamp', 'email3AccessToken', 'email3RefreshToken')
            }
        }
        catch(err) {
            console.log(err)
        }
        }
        // console.log('okj')
    }
    catch (error) {
        console.log(error)
    }
});