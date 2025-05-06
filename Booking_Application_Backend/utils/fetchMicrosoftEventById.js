const MicrosoftGraph = require('@microsoft/microsoft-graph-client');
const { refreshTokenMicrosoft } = require('./refreshTokenMicrosoft');
const db = require('../models');


async function fetchMicrosoftEventById(accessToken, refreshToken, userId, email, eventId) {
    return new Promise(async (resolve, reject) => {
        try {
            const client = MicrosoftGraph.Client.init({
                authProvider: (done) => {
                    done(null, accessToken);
                }
            });
            const event = await client.api(`/me/events/${eventId}`).get()

            // console.log('fetchedEvent', event)
            resolve(event)
        }
        catch (error) {
            console.error('Error fetching single microsoft event:', error);
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
                    fetchMicrosoftEventById(response.access_token, response.refresh_token, userId, email, eventId).then((event) => {
                        resolve(event)
                    })
                }
                catch (err) {
                    console.log('Error in refreshing Microsoft token', err)
                    reject(err)
                }
            }
            else reject(error);
        }
    });
}

module.exports = { fetchMicrosoftEventById }