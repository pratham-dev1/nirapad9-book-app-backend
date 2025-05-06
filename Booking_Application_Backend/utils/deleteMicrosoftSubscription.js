
const MicrosoftGraph = require('@microsoft/microsoft-graph-client');
const db = require("../models/index");
const { refreshTokenMicrosoft } = require('./refreshTokenMicrosoft');

async function deleteMicrosoftSubscription(accessToken, refreshToken, userId, email, subscriptionId, subscriptionIdColumn, expirationColumn, user) {
    return new Promise(async (resolve, reject) => {
        try {
            // const user = await db.user.findByPk(userId)
            // let AccessTokenColumn =  email === user.email ? 'emailAccessToken' : email === user.email2 ? 'email2AccessToken' : email === user.email3 ? 'email3AccessToken' : null
            const client = MicrosoftGraph.Client.init({
                authProvider: (done) => {
                    done(null, accessToken);
                }
            });
            // let SubscriptionColumn = email === user.email ? 'microsoftSubscriptionIdEmail1' : email === user.email2 ? 'microsoftSubscriptionIdEmail2' : email === user.email3 ? 'microsoftSubscriptionIdEmail3' : null
            // let SubscriptionExpirationColumn = email === user.email ? 'microsoftSubscriptionExpirationEmail1' : email === user.email2 ? 'microsoftSubscriptionExpirationEmail2' : email === user.email3 ? 'microsoftSubscriptionExpirationEmail3' : null

            // const subscriptionId = user[SubscriptionColumn]
            const subscriptions = await client
            .api('/subscriptions')
            .get();
            console.log('All' , subscriptions)
            
            const response = await client.api(`/subscriptions/${subscriptionId}`).delete();
            console.log('delete microsoft subscription', response)
            user[subscriptionIdColumn] = null;
            user[expirationColumn] = null
            await user.save()
            resolve();

        } catch (error) {
            console.error('Error deleting microsoft subscription:', error);
            console.log('errrrrrrrrr------', error.statusCode)
            if (error.statusCode === 401) {
                try {
                    const user = await db.user.findByPk(userId)
                    const response = await refreshTokenMicrosoft(refreshToken)
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
                    deleteMicrosoftSubscription(accessToken, refreshToken, userId, email, subscriptionId, subscriptionIdColumn, expirationColumn, user).then(() => {
                        resolve()
                    })
                }
                catch (err) {
                    console.log('Error in refreshing Microsoft token', err)
                    reject(err)
                }
            }
            else console.log(error);
            // throw { statusCode: 500, message: error.message }
        }
    })
}

module.exports = { deleteMicrosoftSubscription }