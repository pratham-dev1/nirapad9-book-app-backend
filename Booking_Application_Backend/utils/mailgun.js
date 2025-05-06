const formData = require('form-data');
const Mailgun = require('mailgun.js');
const mailgun = new Mailgun(formData);
const mg = mailgun.client({ username: 'api', key: process.env.MAILGUN_API_KEY });

function sendNotification(to, subject, html, attachment, from, hideGuestList) {
    return new Promise(async (resolve, reject) => {
        const attendees = Array.isArray(to) ? [...to] : [to];
        let data = {
            from: from || "hr@ba.nirapad9.com",
            to: attendees,
            subject: subject,
            html: html
        }
        if (hideGuestList) {
            data['to'] = ['no-reply@ba.nirapad9.com'],     //if hideGuessList true then we need to send at least one email in 'to' parameter - passing no-reply for temporary
            data['bcc'] = attendees
        }
        if (attachment?.originalName && attachment?.fileData) {
            const attachmentBuffer = Buffer.from(attachment.fileData, 'base64');
            data.attachment = [{ filename: attachment?.originalName, data: attachmentBuffer }];
        }
        try {
            const response = await mg.messages.create('ba.nirapad9.com', data)
            resolve(response)
        }
        catch (error) {
            console.log('Mailgun ERROR - ', error)
            // reject(error)
        }

    })
}

module.exports = { sendNotification }