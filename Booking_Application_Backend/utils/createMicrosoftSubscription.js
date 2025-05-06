const MicrosoftGraph = require('@microsoft/microsoft-graph-client');
const { refreshTokenMicrosoft } = require('./refreshTokenMicrosoft');
const db = require("../models/index");
const { v4: uuidv4 } = require('uuid');
const { SERVER_URL } = require('../config/urlsConfig');

async function createMicrosoftSubscription(accessToken, refreshToken, userId, email, subscriptionIdColumnName, expirationColumnName, user) {
    return new Promise(async (resolve, reject) => {
        try {
            const client = MicrosoftGraph.Client.init({
                authProvider: (done) => {
                    done(null, accessToken);
                }
            });
            const response = await client
                .api('/subscriptions')
                .post({
                    changeType: 'created,updated,deleted',
                    notificationUrl: `${SERVER_URL}/api/microsoft/webhook`,
                    notificationUrl: 'https://c73c-2409-40c4-10-4d82-c12d-1861-3518-952a.ngrok-free.app/api/microsoft/webhook', // Your webhook endpoint
                    resource: 'me/events', // Specify the resource to subscribe to (user's calendar events)
                    expirationDateTime: new Date(Date.now() + 4230 * 60 * 1000).toISOString(),
                    clientState: uuidv4(), // Optional: A state to validate notifications
                });
            user[subscriptionIdColumnName] = response.id;
            user[expirationColumnName] = response.expirationDateTime;
            await user.save()
            resolve(response)
        } catch (error) {
            console.error('Error creating microsoft subscription:', error);
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
                    createMicrosoftSubscription(response.access_token, response.refresh_token, userId, email, subscriptionIdColumnName, expirationColumnName, user).then(() => {
                        resolve()
                    })
                }
                catch (err) {
                    console.log('Error in refreshing Microsoft token', err)
                    reject(err)
                }
            }
            else reject(error);
        }
    })
}

module.exports = { createMicrosoftSubscription }