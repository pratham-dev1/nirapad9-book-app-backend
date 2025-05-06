const cron = require("node-cron");
const db = require("../models");
const dayjs = require("dayjs");
const utc = require("dayjs/plugin/utc");
const timezone = require("dayjs/plugin/timezone");
const { createGoogleWatch } = require("./createGoogleWatch");
const { stopGoogleWatch } = require("./stopGoogleWatch");
const { deleteMicrosoftSubscription } = require("./deleteMicrosoftSubscription");
const { createMicrosoftSubscription } = require("./createMicrosoftSubscription");

// Extend Day.js with UTC and Timezone plugins
dayjs.extend(utc);
dayjs.extend(timezone);

// Function to handle Google email service provider
async function processGoogleWatch(user, accessToken, refreshToken, channelId, resourceId, resourceIdColumn, channelIdColumn, expirationColumn) {
    if (accessToken && refreshToken && channelId && resourceId) {
        try {
            await stopGoogleWatch(accessToken, refreshToken, channelId, resourceId, resourceIdColumn, channelIdColumn, expirationColumn, user);
            await createGoogleWatch(accessToken, refreshToken, resourceIdColumn, channelIdColumn, expirationColumn, user);
        } catch (error) {
            console.log(`Error in Automatic Google watch renew for user ${user.id}:`, error);
        }
    }
}

// Function to handle Microsoft email service provider
async function processMicrosoftSubscription(user, accessToken, refreshToken, userId, email, subscriptionId, subscriptionIdColumn, expirationColumn) {
    if (accessToken && refreshToken && subscriptionId) {
        try {
            await deleteMicrosoftSubscription(accessToken, refreshToken, userId, email, subscriptionId, subscriptionIdColumn, expirationColumn, user);
            await createMicrosoftSubscription(accessToken, refreshToken, userId, email, subscriptionIdColumn, expirationColumn, user);
        } catch (error) {
            console.log(`Error in Automatic Microsoft subscription renew for user ${user.id}:`, error);
        }
    }
}


// Run cron job every 15 minutes to consider all timezones for 12 am
cron.schedule("*/15 * * * *", async () => {
    try {
        const users = await db.user.findAll({
            attributes: [
                'id', 'emailServiceProvider', 'email2ServiceProvider', 'email3ServiceProvider',
                'emailAccessToken', 'email2AccessToken', 'email3AccessToken',
                'emailRefreshToken', 'email2RefreshToken', 'email3RefreshToken',
                'googleChannelIdEmail1', 'googleResourceIdEmail1',
                'googleChannelIdEmail2', 'googleResourceIdEmail2',
                'googleChannelIdEmail3', 'googleResourceIdEmail3',
                'microsoftSubscriptionIdEmail1', 'microsoftSubscriptionIdEmail2', 'microsoftSubscriptionIdEmail3'
            ],
            include: {
                model: db.timezone,
                as: 'timezone',
            }
        });

        // Collect all async tasks
        const tasks = [];

        for (const user of users) {
            if (user.timezone) {
                const userTimezone = user?.timezone?.value;
                const userLocalTime = dayjs().tz(userTimezone).format("HH:mm"); // Get local time

                if (userLocalTime === "00:00") { // If it's 12:00 AM in their timezone
                    // Add tasks to be executed in parallel
                    if (user.emailServiceProvider === "google") {
                        tasks.push(processGoogleWatch(user, user.emailAccessToken, user.emailRefreshToken, user.googleChannelIdEmail1, user.googleResourceIdEmail1, 'googleResourceIdEmail1', 'googleChannelIdEmail1', 'googleWatchExpirationEmail1'));
                    }
                    else if (user.emailServiceProvider === "microsoft") {
                        tasks.push(processMicrosoftSubscription(user, user.emailAccessToken, user.emailRefreshToken, user.id, user.email, user.microsoftSubscriptionIdEmail1, 'microsoftSubscriptionIdEmail1', 'microsoftSubscriptionExpirationEmail1'))
                    }
                    if (user.email2ServiceProvider === "google") {
                        tasks.push(processGoogleWatch(user, user.email2AccessToken, user.email2RefreshToken, user.googleChannelIdEmail2, user.googleResourceIdEmail2, 'googleResourceIdEmail2', 'googleChannelIdEmail2', 'googleWatchExpirationEmail2'));
                    }
                    else if (user.email2ServiceProvider === "microsoft") {
                        tasks.push(processMicrosoftSubscription(user, user.email2AccessToken, user.email2RefreshToken, user.id, user.email2, user.microsoftSubscriptionIdEmail2, 'microsoftSubscriptionIdEmail2', 'microsoftSubscriptionExpirationEmail2'))
                    }
                    if (user.email3ServiceProvider === "google") {
                        tasks.push(processGoogleWatch(user, user.email3AccessToken, user.email3RefreshToken, user.googleChannelIdEmail3, user.googleResourceIdEmail3, 'googleResourceIdEmail3', 'googleChannelIdEmail3', 'googleWatchExpirationEmail3'));
                    }
                    else if (user.email3ServiceProvider === "microsoft") {
                        tasks.push(processMicrosoftSubscription(user, user.email3AccessToken, user.email3RefreshToken, user.id, user.email3, user.microsoftSubscriptionIdEmail3, 'microsoftSubscriptionIdEmail3', 'microsoftSubscriptionExpirationEmail3'))
                    }
                }
            }
        }

        // Execute all tasks in parallel
        await Promise.allSettled(tasks);
        console.log("Email Webhook renew has been processed for all users");

    } catch (err) {
        console.log("Error in Automatic email webhook renew:-", err);
    }
});
