const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'john.smithz231987@gmail.com',
        pass: 'tolz jsii cubt fuvw'
    }
});

function emailNotification(to, subject, content) {
    return new Promise(async (resolve, reject) => {
    try {
        const message = {
            // from: "testNirapad9@outlook.com",
            to: to,
            subject: subject,
            html: content,
        };
        const info = await transporter.sendMail(message);
        const response = {
            msg: "Email sent",
            info: info.messageId,
            // preview: nodemailer.getTestMessageUrl(info)
        };
        resolve(response)
    } catch (error) {
        console.log('Error in sending email', error);
        reject(error)
    }
})
}

module.exports = {emailNotification};