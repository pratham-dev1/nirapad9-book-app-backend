
const MicrosoftGraph = require('@microsoft/microsoft-graph-client');
const db = require("../models/index");
const { refreshTokenMicrosoft } = require('./refreshTokenMicrosoft');

async function cancelMicrosoftEvent(accessToken, refreshToken, eventId, userId, email) {
    return new Promise(async (resolve, reject) => {
        try {
            const client = MicrosoftGraph.Client.init({
                authProvider: (done) => {
                    done(null, accessToken);
                }
            });
            await client.api(`/me/events/${eventId}`).delete();
            resolve();

        } catch (error) {
            console.error('Error cancelling microsoft event:', error);
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
                    cancelMicrosoftEvent(response.access_token, response.refresh_token, eventId, userId, email).then(() => {
                        resolve()
                    })
                }
                catch (err) {
                    console.log('Error in refreshing Microsoft token', err)
                    reject(err)
                }
            }
            else reject(error);
            // throw { statusCode: 500, message: error.message }
        }
    })
}

module.exports = { cancelMicrosoftEvent }