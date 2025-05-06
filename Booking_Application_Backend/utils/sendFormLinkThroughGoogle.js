const { google } = require('googleapis');

function sendFormLinkThroughGoogle(accessToken, refreshToken, originalname, buffer,tpEmail,zohoFormLink) {
    return new Promise(async (resolve, reject) => {
    try {
        const oAuth2Client = new google.auth.OAuth2({
            clientId: process.env.GOOGLE_CLIENT_ID,
            clientSecret: process.env.GOOGLE_CLIENT_SECRET,
            redirectUri: `/auth/google/callback`,
        });
        oAuth2Client.setCredentials({
            access_token: accessToken,
            refresh_token: refreshToken,
        });
        const gmail = google.gmail({ version: 'v1', auth: oAuth2Client });

        const messageParts = [
            `To: ${tpEmail}`,
            `Subject: Zoho Form`,
            'Content-Type: multipart/mixed; boundary="foo_bar_baz"', 
            '',
            `<b>Link to Form</b>`,
            '',
            '--foo_bar_baz',
            `Content-Disposition: attachment; filename="${originalname}"`, // Use the original name of the uploaded file
            `Content-Transfer-Encoding: base64`,
            '',
            buffer,
            '',
            '--foo_bar_baz--'
          ];
        const message = messageParts.join('\n');

        const encodedMessage = Buffer.from(message).toString('base64');

        const response = await gmail.users.messages.send({
            userId: 'me',
            requestBody: {
                raw: encodedMessage
            }
        })
        resolve()
    }
    catch (error) {
        console.error('Error in sending google mail', error);
        reject(error)
        // throw { statusCode: error.status || 500, message: error.message }
    }
})
}

module.exports = {sendFormLinkThroughGoogle}