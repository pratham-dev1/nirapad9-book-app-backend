const MicrosoftGraph = require('@microsoft/microsoft-graph-client');
function sendFormLinkThroughMicrosoft(accessToken, refreshToken, tpEmail, formLink,attachmentBuffer, attachmentFileName) {
    return new Promise(async (resolve, reject) => {
        try {
            const client = MicrosoftGraph.Client.init({
                authProvider: (done) => {
                    done(null, accessToken);
                },
            });

            const attachment = {
                "@odata.type": "#microsoft.graph.FileAttachment",
                name: attachmentFileName,
                contentBytes: attachmentBuffer.toString('base64')
            };

            const email = {
                subject: 'Zoho Form',
                body: {
                    contentType: 'Html',
                    content: `<b>Link to Zoho Form</b><br> ${formLink}`
                },
                toRecipients: [
                    {
                        emailAddress: {
                            address: tpEmail
                        }
                    }
                ],
                attachments: [attachment]
            };


            let res = await client.api('/me/sendMail').post({ message: email })
            // console.log(res)
            resolve()
        }
        catch (error) {
            console.log('Error in sending microsoft mail', error)
            reject(error)
        }
    })
}

module.exports = { sendFormLinkThroughMicrosoft }