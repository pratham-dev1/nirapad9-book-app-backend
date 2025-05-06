const axios = require("axios")

async function refreshTokenMicrosoft(refreshToken) {

    const tokenEndpoint = 'https://login.microsoftonline.com/common/oauth2/v2.0/token';
    try {
        const response = await axios.post(tokenEndpoint, new URLSearchParams({
            grant_type: 'refresh_token',
            refresh_token: refreshToken,
            client_id: process.env.MICROSOFT_CLIENT_ID,
            client_secret: process.env.MICROSOFT_CLIENT_SECRET,
        }), {
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
        });

        const data = response.data;
        return data

    }
    catch (error) {
        console.log('Microsot refresh token error:',error)
        throw {error}
    }
}

module.exports = { refreshTokenMicrosoft }