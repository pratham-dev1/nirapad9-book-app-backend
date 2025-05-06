const { CLIENT_URL, SERVER_URL } = require("../config/urlsConfig");
const db = require("../models");
const { comparePassword, hashPassword } = require("../utils/bcrypt");
const { checkGoogleWatchExpiration } = require("../utils/checkGoogleWatchExpiration");
const { createGoogleWatch } = require("../utils/createGoogleWatch");
const { generateAccessToken } = require("../utils/generateToken");
const { sendNotification } = require("../utils/mailgun");
const crypto = require('crypto');
const geoip = require('geoip-lite')
const { google } = require('googleapis');
const { createMicrosoftSubscription } = require("../utils/createMicrosoftSubscription");
const { checkMicrosoftSubscriptionExpiration } = require("../utils/checkMicrosoftSubscriptionExpiration");
const dayjs = require("dayjs");
const { CreateStripeCustomer } = require("../utils/CreateStripeCustomer");
const {  hashValue} = require("../utils/argon");
const speakeasy = require('speakeasy');
const QRCode = require('qrcode');
const { getIo, getConnectedUsers } = require("../utils/socket");
const { fetchGoogleEvents } = require("../utils/fetchGoogleEvents");
const { fetchMicrosoftEvents } = require("../utils/fetchMicrosoftEvents");
const Applications = require("../constants/Applications");
const { generateRandomPassword } = require("../utils/generateRandomPassword");

const randomString = () => {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < 15; i++) {
      result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result
  };

exports.login = async (req, res) => {
    try {
        let { usernameOrEmail, password } = req.body;
        usernameOrEmail = usernameOrEmail.toLowerCase();
        const conditions = [{ username: usernameOrEmail }, { email: usernameOrEmail }]
        if (+usernameOrEmail > 0) {
            conditions.push({ id: usernameOrEmail })
        }
        const user = await db.user.findOne({
            where: {
                [db.Sequelize.Op.or]: conditions
            },
            include: [
                {
                    model: db.user_type, as: 'usertype'
                },
                {
                    model: db.timezone,
                    as: 'timezone',
                    attributes: ['id', 'timezone', 'value', 'abbreviation']
                },
                { model: db.applications, as: 'appAccess', through: { attributes: [] }}
            ]
            // raw:true
        });
        if (!user) {
            throw { statusCode: 401, message: 'Invalid Credentials' };
        }
        
        if(user.appAccess?.length === 0 && (user.userTypeId !== 3 && user.userTypeId !== 5)) {   // if no app access - not admin - not product owner
          throw { statusCode: 400, message: "You don't have access any of our application - Please contact to admin to assign you role for app" };
        } 
        const isPasswordMatched = await comparePassword(password, user.password);
        if (!isPasswordMatched) {
            throw { statusCode: 401, message: 'Invalid Credentials' };
        }
        if (user?.isDeleted) {
            throw { statusCode: 403, message: 'Your Account has been deleted. Contact to admin' };
        }

        const userVerificationRecord = await db.user_verification.findOne({ where: { userId: user.id, email: user.email } })
        if (userVerificationRecord && !userVerificationRecord.isAccountVerified) {
            return res.status(401).json({ error:true, warning: 'Account Not Verified', userId: user.id, message: 'Your account is not verified' });
        }
        await db.user_login_logs.create({userId: user.id, createdAt: new Date().toISOString(), isCredentialsDisabled: user.isCredentialsDisabled, credentialDisabledTimeStamp: user?.credentialDisabledTimeStamp, credentialEnabledTimeStamp: user?.credentialEnabledTimeStamp, lastLoginTried: new Date().toISOString()})
        if(user.isCredentialsDisabled) {
            return res.status(400).json({ error:true,message: 'Your Credentials are blocked' });
        }
        const accessToken = await generateAccessToken({ userId: user.id, role: user.userTypeId, lastPasswordUpdatedForSecurity: user?.lastPasswordUpdatedForSecurity, subscription: user.subscriptionId, orgId: user.baOrgId})
        const ip = req.ip
        const geoLocation = geoip.lookup(ip);
        await db.user_ip.create({userId: user.id, ip: ip, loggedTime: new Date().toISOString(), ipLocation: `${geoLocation?.city}, ${geoLocation?.country}`})
        user.lastLoginTimeStamp = new Date().toISOString();

        let isFreeTrial = false, isPaidPlan = false;
        if(user?.freeSubscriptionExpiration) {
           isFreeTrial = new Date(user?.freeSubscriptionExpiration) > new Date()
           if(!isFreeTrial) {
            //if plan already expired and user try to login - if we not do this then after login getsession api will fail through verifyAccessToken middleware and it will not hold payment page after login
            user.freeSubscriptionExpiration = null
           }
        }
        if(user.stripeSubscriptionId) {
            isPaidPlan = true
        }
        await user.save();
        let jsonObject = { success: true, message: "Logged In Successfully", userId: user.id, userType: user.userTypeId, isPasswordUpdated: user.isPasswordUpdated, accessToken, userTypeName: user.usertype.userType, profilePicture: user.profilePicture, timezone: user.timezone, theme: user.theme, subscription: user.subscriptionId, orgId: user.baOrgId, isFreeTrial, isPaidPlan ,mfaEnabled:user.mfaEnabled,mfaConfigured:user.mfaConfigured,mfaManditory:user.mfaManditory, appAccess: user.appAccess.map(i => i.id), isUsernameUpdated: user.isUsernameUpdated, isMergeCalendarGuideChecked: user.isMergeCalendarGuideChecked, isFreeTrialOver: user.isFreeTrialOver  }
        res.cookie('accessToken', accessToken, { httpOnly: true, sameSite: false, secure: true, domain: process.env.DOMAIN_NAME});
        res.cookie('isAuthenticated', true, {sameSite: false, secure: true, domain: process.env.DOMAIN_NAME});
        return res.status(200).json(jsonObject)
    }
    catch (error) {
        return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.getSession = async (req, res) => {
    try {
        const user = await db.user.findOne({
            where: { id: req.user.userId },
            include: [
                {
                    model: db.user_type, as: 'usertype'
                },
                {
                    model: db.timezone,
                    as: 'timezone',
                    attributes: ['id', 'timezone', 'value', 'abbreviation']
                },
                { model: db.applications, as: 'appAccess', through: { attributes: [] }}
            ]
        })
        if (!user) {
            throw { statusCode: 404, message: 'User not found' };
        }
        let isFreeTrial = false, isPaidPlan = false;
        if(user?.freeSubscriptionExpiration) {
           isFreeTrial = new Date(user?.freeSubscriptionExpiration) > new Date()
        }
        if(user.stripeSubscriptionId) {
            isPaidPlan = true
        }
        return res.status(200).json({ success: true, isAuthenticated: true, userId: user.id, userType: user.userTypeId, isPasswordUpdated: user.isPasswordUpdated, userTypeName: user.usertype.userType, profilePicture: user.profilePicture, timezone: user.timezone, theme: user.theme, subscription: user.subscriptionId, orgId: user.baOrgId, isFreeTrial, isPaidPlan,mfaEnabled:user.mfaEnabled,mfaConfigured:user.mfaConfigured ,mfaManditory:user.mfaManditory, appAccess: user.appAccess.map(i => i.id), isUsernameUpdated: user.isUsernameUpdated, isMergeCalendarGuideChecked: user.isMergeCalendarGuideChecked, isFreeTrialOver: user.isFreeTrialOver})
    }
    catch (error) {
        return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.logout = async (req, res) => {
    try {
        res.clearCookie('accessToken', { httpOnly: true, sameSite: false, secure: true, domain: process.env.DOMAIN_NAME});
        res.clearCookie('isAuthenticated', {sameSite: false, secure: true, domain: process.env.DOMAIN_NAME});
        res.clearCookie('isMFAAuthenticated', {sameSite: false, secure: true, domain: process.env.DOMAIN_NAME});
        res.clearCookie('isMFASkipped', {sameSite: false, secure: true, domain: process.env.DOMAIN_NAME});
        return res.status(200).json({ success: true, message: "Logged Out Successfully" })
    }
    catch (error) {
        return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.googleLoginResponse = async (req, res) => {
    const userId = req.query?.state
    const userProfile = req.user.profile
    const email = userProfile.emails[0].value.toLowerCase()
    if (userId) {
        try {
            const user = await db.user.findByPk(userId)
            if (user.email === email) {
                user.emailAccessToken = req.user.accessToken
                user.emailRefreshToken = req.user.refreshToken
                user.emailServiceProvider = 'google'
                user.emailSyncTimeStamp = new Date().toISOString()
                if(!user.firstTimeEmailSyncTimeStamp) {
                  user.firstTimeEmailSyncTimeStamp = new Date().toISOString()
                }
                await user.save()
                await checkGoogleWatchExpiration(user, user.googleWatchExpirationEmail1, req.user.accessToken, req.user.refreshToken, 'googleResourceIdEmail1', 'googleChannelIdEmail1', 'googleWatchExpirationEmail1')
                !user.nextSyncTokenForEmail && await fetchGoogleEvents(req.user.accessToken, req.user.refreshToken, userId, email, user.nextSyncTokenForEmail)
            }
            else if (user.email2 === email) {
                    user.email2AccessToken = req.user.accessToken
                    user.email2RefreshToken = req.user.refreshToken
                    user.email2SyncTimeStamp = new Date().toISOString()
                    if(!user.firstTimeEmail2SyncTimeStamp) {
                      user.firstTimeEmail2SyncTimeStamp = new Date().toISOString()
                    }
                    await user.save()      
                    await checkGoogleWatchExpiration(user, user.googleWatchExpirationEmail2, req.user.accessToken, req.user.refreshToken, 'googleResourceIdEmail2', 'googleChannelIdEmail2', 'googleWatchExpirationEmail2')
                    !user.nextSyncTokenForEmail2 && await fetchGoogleEvents(req.user.accessToken, req.user.refreshToken, userId, email, user.nextSyncTokenForEmail2)
            }
            else if (!user.email2) {
                // condition will work when someone delete 1st secondary email and again try to sync the same email
                if (email === user.email3) {
                    user.email3AccessToken = req.user.accessToken
                    user.email3RefreshToken = req.user.refreshToken
                    user.email3SyncTimeStamp = new Date().toISOString()
                    if(!user.firstTimeEmail3SyncTimeStamp) {
                      user.firstTimeEmail3SyncTimeStamp = new Date().toISOString()
                    }
                    await user.save()
                    await checkGoogleWatchExpiration(user, user.googleWatchExpirationEmail3, req.user.accessToken, req.user.refreshToken, 'googleResourceIdEmail3', 'googleChannelIdEmail3', 'googleWatchExpirationEmail3')
                    !user.nextSyncTokenForEmail3 && await fetchGoogleEvents(req.user.accessToken, req.user.refreshToken, userId, email, user.nextSyncTokenForEmail3)
                }
                else {
                user.email2 = email;
                user.email2ServiceProvider = 'google'
                user.email2AccessToken = req.user.accessToken
                user.email2RefreshToken = req.user.refreshToken
                user.eventColorForEmail2 = 2
                user.email2SyncTimeStamp = new Date().toISOString()
                if(!user.firstTimeEmail2SyncTimeStamp) {
                  user.firstTimeEmail2SyncTimeStamp = new Date().toISOString()
                }
                await user.save()
                await db.user_verification.create({isAccountVerified: true, email: email, userId: user.id})
                // await db.open_availability_tags.update({isEmailDeleted: false, isDeleted: null},{where: {defaultEmail: email, userId}})
                // await db.event_draft.update({isEmailDeleted: false},{where: {senderEmail: email, userId}})
                // await db.predefined_event.update({isEmailDeleted: false},{where: {senderEmail: email, userId}})
                await checkGoogleWatchExpiration(user, user.googleWatchExpirationEmail2, req.user.accessToken, req.user.refreshToken, 'googleResourceIdEmail2', 'googleChannelIdEmail2', 'googleWatchExpirationEmail2')
                !user.nextSyncTokenForEmail2 && await fetchGoogleEvents(req.user.accessToken, req.user.refreshToken, userId, email, user.nextSyncTokenForEmail2)
                }
            }
            else if (user.email3  === email) {
                    user.email3AccessToken = req.user.accessToken
                    user.email3RefreshToken = req.user.refreshToken
                    user.email3SyncTimeStamp = new Date().toISOString()
                    if(!user.firstTimeEmail3SyncTimeStamp) {
                      user.firstTimeEmail3SyncTimeStamp = new Date().toISOString()
                    }
                    await user.save()
                    await checkGoogleWatchExpiration(user, user.googleWatchExpirationEmail3, req.user.accessToken, req.user.refreshToken, 'googleResourceIdEmail3', 'googleChannelIdEmail3', 'googleWatchExpirationEmail3')
                    !user.nextSyncTokenForEmail3 && await fetchGoogleEvents(req.user.accessToken, req.user.refreshToken, userId, email, user.nextSyncTokenForEmail3)
            }
            else if (!user.email3) {
                user.email3 = email;
                user.email3ServiceProvider = 'google'
                user.email3AccessToken = req.user.accessToken
                user.email3RefreshToken = req.user.refreshToken
                user.eventColorForEmail3 = 3
                user.email3SyncTimeStamp = new Date().toISOString()
                if(!user.firstTimeEmail3SyncTimeStamp) {
                  user.firstTimeEmail3SyncTimeStamp = new Date().toISOString()
                }
                await user.save()
                await db.user_verification.create({isAccountVerified: true, email: email, userId: user.id})
                // await db.open_availability_tags.update({isEmailDeleted: false, isDeleted: null},{where: {defaultEmail: email, userId}})
                // await db.event_draft.update({isEmailDeleted: false},{where: {senderEmail: email, userId}})
                // await db.predefined_event.update({isEmailDeleted: false},{where: {senderEmail: email, userId}})
                await checkGoogleWatchExpiration(user, user.googleWatchExpirationEmail3, req.user.accessToken, req.user.refreshToken, 'googleResourceIdEmail3', 'googleChannelIdEmail3', 'googleWatchExpirationEmail3')
                !user.nextSyncTokenForEmail3 && await fetchGoogleEvents(req.user.accessToken, req.user.refreshToken, userId, email, user.nextSyncTokenForEmail3)
            }
            else {
                return res.redirect(`${CLIENT_URL}/error?message=Error: You can add maximun 3 calendars`);
            }
            return res.redirect(`${CLIENT_URL}/`);


        } catch (error) {
            return res.redirect(`${CLIENT_URL}/error?message=Something went wrong while adding google calendar`);
        }
    }
    else {

        try {
            const randomPassword = generateRandomPassword()
            const hashedPassword = await hashPassword(randomPassword);
            const [user, created] = await db.user.findOrCreate({
                where: {
                    [db.Sequelize.Op.or]: [
                        { email: email },
                        { email2: email },
                        { email3: email }
                    ]
                },
                defaults: { username: (userProfile.name?.givenName?.split(' ')[0] + '_' +  randomString()), fullname: userProfile.displayName, email: email, userTypeId: 4, password: hashedPassword, emailServiceProvider: 'google', eventColorForEmail: 1, theme: 'thm-blue' },
                include: { model: db.applications, as: 'appAccess', through: { attributes: [] }}
            });

            if(user.appAccess?.length === 0 && (user.userTypeId !== 3 && user.userTypeId !== 5)) {     // if no app access - not admin - not product owner
              throw { statusCode: 400, message: "You don't have access any of our application - Please contact to admin to assign you role for app" };
            }
            if (created) {  
                await db.user_verification.create({isAccountVerified: true, email: user.email, userId: user.id})
                user.createdAt = new Date().toISOString();
                await user.save();
                await user.setAppAccess([Applications.SLOT_BROADCAST])  // providing slot broadcast access by default
            }
            if (user.email2 === email || user.email3 === email) {
                return res.redirect(`${CLIENT_URL}/error?message=Please login with you primary email`);
            }
            if (user?.isDeleted) {
                throw { message: 'Your account has been deleted. Contact to admin' };
            }
            await db.user_login_logs.create({userId: user.id, createdAt: new Date().toISOString(), isCredentialsDisabled: user.isCredentialsDisabled, credentialDisabledTimeStamp: user?.credentialDisabledTimeStamp, credentialEnabledTimeStamp: user?.credentialEnabledTimeStamp, lastLoginTried: new Date().toISOString()})
            if(user.isCredentialsDisabled) {
                throw {message: 'Your Credentials are blocked' };
            }
            let updateObject = { emailAccessToken: req.user.accessToken, emailRefreshToken: req.user.refreshToken, emailServiceProvider: 'google', lastLoginTimeStamp: new Date().toISOString(), emailSyncTimeStamp : new Date().toISOString() }
            if(user.freeSubscriptionExpiration) {
              let isFreeTrial = new Date(user?.freeSubscriptionExpiration) > new Date()
              if(!isFreeTrial) {
               //if plan already expired and user try to login - if we not do this then after login getsession api will fail through verifyAccessToken middleware and it will not hold payment page after login
               updateObject.freeSubscriptionExpiration = null
              }
            }
            if(!user.firstTimeEmailSyncTimeStamp) {
              user.firstTimeEmailSyncTimeStamp = new Date().toISOString()
            }
            await db.user.update(updateObject, { where: { id: user.id } })
            if (!user.stripeCustomerId) {
               await CreateStripeCustomer(user.id)
            }
            await checkGoogleWatchExpiration(user, user.googleWatchExpirationEmail1, req.user.accessToken, req.user.refreshToken, 'googleResourceIdEmail1', 'googleChannelIdEmail1', 'googleWatchExpirationEmail1')
            !user.nextSyncTokenForEmail && await fetchGoogleEvents(req.user.accessToken, req.user.refreshToken, user.id, email, user.nextSyncTokenForEmail)
            const jwtToken = await generateAccessToken({ userId: user.id, role: user.userTypeId, lastPasswordUpdatedForSecurity: user?.lastPasswordUpdatedForSecurity, subscription: user.subscriptionId, orgId: user.baOrgId })
            if(created) {
              const content = `Your Account is Verified. Please find your credentials below <br/> Email: ${email} <br/> Username: ${user.username} <br/> Password: ${randomPassword} <br/> <br/> <b>Use these credentials for existing password field in the next screen.</b>`
              sendNotification(email, 'Account Verified', content)
            }
            res.cookie('accessToken', jwtToken, { httpOnly: true, sameSite: false, secure: true, domain: process.env.DOMAIN_NAME});
            res.cookie('isAuthenticated', true, {sameSite: false, secure: true, domain: process.env.DOMAIN_NAME});
            return res.redirect(`${CLIENT_URL}/`);
        }
        catch (error) {
            console.log(error)
            return res.redirect(`${CLIENT_URL}/error?message=${error.message}`);
        }
    }
}

exports.microsoftLoginResponse = async (req, res) => {
    const userId = req.query?.state
    const userProfile = req.user.profile
    const email = userProfile.emails[0].value.toLowerCase()
    if (userId) {
        try {
            const user = await db.user.findByPk(userId)
            if (user.email === email) {
                user.emailAccessToken = req.user.accessToken
                user.emailRefreshToken = req.user.refreshToken
                user.emailServiceProvider = 'microsoft'
                user.emailSyncTimeStamp = new Date().toISOString()
                user.emailSyncExpiration = dayjs().add(90, 'days').toISOString()
                if(!user.firstTimeEmailSyncTimeStamp) {
                  user.firstTimeEmailSyncTimeStamp = new Date().toISOString()
                }
                await user.save()
                await checkMicrosoftSubscriptionExpiration(user, email, user.microsoftSubscriptionExpirationEmail1, req.user.accessToken, req.user.refreshToken, 'microsoftSubscriptionIdEmail1', 'microsoftSubscriptionExpirationEmail1')
                !user.nextSyncTokenForEmail && await fetchMicrosoftEvents(req.user.accessToken, req.user.refreshToken, userId, email, user.nextSyncTokenForEmail)
            }
            else if (user.email2 === email) {
                    user.email2AccessToken = req.user.accessToken
                    user.email2RefreshToken = req.user.refreshToken
                    user.email2SyncTimeStamp = new Date().toISOString()
                    user.email2SyncExpiration = dayjs().add(90, 'days').toISOString()
                    if(!user.firstTimeEmail2SyncTimeStamp) {
                      user.firstTimeEmail2SyncTimeStamp = new Date().toISOString()
                    }
                    await user.save()      
                    await checkMicrosoftSubscriptionExpiration(user, email, user.microsoftSubscriptionExpirationEmail2, req.user.accessToken, req.user.refreshToken, 'microsoftSubscriptionIdEmail2', 'microsoftSubscriptionExpirationEmail2')
                    !user.nextSyncTokenForEmail2 && await fetchMicrosoftEvents(req.user.accessToken, req.user.refreshToken, userId, email, user.nextSyncTokenForEmail2)
            }
            else if (!user.email2) {
                // condition will work when someone delete 1st secondary email and again try to sync the same email
                if (email === user.email3) {
                    user.email3AccessToken = req.user.accessToken
                    user.email3RefreshToken = req.user.refreshToken
                    user.email3SyncTimeStamp = new Date().toISOString()
                    user.email3SyncExpiration = dayjs().add(90, 'days').toISOString()
                    if(!user.firstTimeEmail3SyncTimeStamp) {
                      user.firstTimeEmail3SyncTimeStamp = new Date().toISOString()
                    }
                    await user.save()
                    await checkMicrosoftSubscriptionExpiration(user, email, user.microsoftSubscriptionExpirationEmail3, req.user.accessToken, req.user.refreshToken, 'microsoftSubscriptionIdEmail3', 'microsoftSubscriptionExpirationEmail3')
                    !user.nextSyncTokenForEmail3 && await fetchMicrosoftEvents(req.user.accessToken, req.user.refreshToken, userId, email, user.nextSyncTokenForEmail3)
                 }
                else {
                user.email2 = email;
                user.email2ServiceProvider = 'microsoft'
                user.email2AccessToken = req.user.accessToken
                user.email2RefreshToken = req.user.refreshToken
                user.eventColorForEmail2 = 2
                user.email2SyncTimeStamp = new Date().toISOString()
                user.email2SyncExpiration = dayjs().add(90, 'days').toISOString()
                if(!user.firstTimeEmail2SyncTimeStamp) {
                  user.firstTimeEmail2SyncTimeStamp = new Date().toISOString()
                }
                await user.save()
                await db.user_verification.create({isAccountVerified: true, email: email, userId: user.id})
                // await db.open_availability_tags.update({isEmailDeleted: false, isDeleted: null},{where: {defaultEmail: email, userId}})
                // await db.event_draft.update({isEmailDeleted: false},{where: {senderEmail: email, userId}})
                // await db.predefined_event.update({isEmailDeleted: false},{where: {senderEmail: email, userId}})
                await checkMicrosoftSubscriptionExpiration(user, email, user.microsoftSubscriptionExpirationEmail2, req.user.accessToken, req.user.refreshToken, 'microsoftSubscriptionIdEmail2', 'microsoftSubscriptionExpirationEmail2')
                !user.nextSyncTokenForEmail2 && await fetchMicrosoftEvents(req.user.accessToken, req.user.refreshToken, userId, email, user.nextSyncTokenForEmail2)
                }
            }
            else if (user.email3  === email) {
                user.email3AccessToken = req.user.accessToken
                user.email3RefreshToken = req.user.refreshToken
                user.email3SyncTimeStamp = new Date().toISOString()
                user.email3SyncExpiration = dayjs().add(90, 'days').toISOString()
                if(!user.firstTimeEmail3SyncTimeStamp) {
                  user.firstTimeEmail3SyncTimeStamp = new Date().toISOString()
                }
                await user.save()
                await checkMicrosoftSubscriptionExpiration(user, email, user.microsoftSubscriptionExpirationEmail3, req.user.accessToken, req.user.refreshToken, 'microsoftSubscriptionIdEmail3', 'microsoftSubscriptionExpirationEmail3')
                !user.nextSyncTokenForEmail3 && await fetchMicrosoftEvents(req.user.accessToken, req.user.refreshToken, userId, email, user.nextSyncTokenForEmail3)
            }
            else if (!user.email3) {
                user.email3 = email;
                user.email3ServiceProvider = 'microsoft'
                user.email3AccessToken = req.user.accessToken
                user.email3RefreshToken = req.user.refreshToken
                user.eventColorForEmail3 = 3
                user.email3SyncTimeStamp = new Date().toISOString()
                user.email3SyncExpiration = dayjs().add(90, 'days').toISOString()
                if(!user.firstTimeEmail3SyncTimeStamp) {
                  user.firstTimeEmail3SyncTimeStamp = new Date().toISOString()
                }
                await user.save()
                await db.user_verification.create({isAccountVerified: true, email: email, userId: user.id})
                // await db.open_availability_tags.update({isEmailDeleted: false, isDeleted: null},{where: {defaultEmail: email, userId}})
                // await db.event_draft.update({isEmailDeleted: false},{where: {senderEmail: email, userId}})
                // await db.predefined_event.update({isEmailDeleted: false},{where: {senderEmail: email, userId}})
                await checkMicrosoftSubscriptionExpiration(user, email, user.microsoftSubscriptionExpirationEmail3, req.user.accessToken, req.user.refreshToken, 'microsoftSubscriptionIdEmail3', 'microsoftSubscriptionExpirationEmail3')
                !user.nextSyncTokenForEmail3 && await fetchMicrosoftEvents(req.user.accessToken, req.user.refreshToken, userId, email, user.nextSyncTokenForEmail3)
            }
            else {
                return res.redirect(`${CLIENT_URL}/error?message=Error: You can add maximun 3 calendars`);
            }
            return res.redirect(`${CLIENT_URL}/dashboard`);


        } catch (error) {
            return res.redirect(`${CLIENT_URL}/error?message=Something went wrong while adding microsoft calendar`);
        }
    }
    else {
        try {
            const randomPassword = generateRandomPassword()
            const hashedPassword = await hashPassword(randomPassword);
            const [user, created] = await db.user.findOrCreate({
                where: {
                    [db.Sequelize.Op.or]: [
                        { email: email },
                        { email2: email },
                        { email3: email }
                    ]
                },
                defaults: { username: (userProfile.name?.givenName?.split(' ')[0] + '_' +  randomString()), fullname: userProfile.displayName, email: email, userTypeId: 4, password: hashedPassword, emailServiceProvider: 'microsoft', eventColorForEmail: 1, theme: 'thm-blue' },
                include: { model: db.applications, as: 'appAccess', through: { attributes: [] }}
            });

            if(user.appAccess?.length === 0 && (user.userTypeId !== 3 && user.userTypeId !== 5)) {             // if no app access - not admin - not product owner
              throw { statusCode: 400, message: "You don't have access any of our application - Please contact to admin to assign you role for app" };
            }
            if (created) {
                await db.user_verification.create({isAccountVerified: true, email: user.email, userId: user.id})
                user.createdAt = new Date().toISOString();
                await user.save();
                await user.setAppAccess([Applications.SLOT_BROADCAST])  // providing slot broadcast access by default
            }
            if (user.email2 === email || user.email3 === email) {
                return res.redirect(`${CLIENT_URL}/error?message=Please login with you primary email`);
            }
            if (user?.isDeleted) {
                throw { message: 'Your account has been deleted. Contact to admin' };
            }
            await db.user_login_logs.create({userId: user.id, createdAt: new Date().toISOString(), isCredentialsDisabled: user.isCredentialsDisabled, credentialDisabledTimeStamp: user?.credentialDisabledTimeStamp, credentialEnabledTimeStamp: user?.credentialEnabledTimeStamp, lastLoginTried: new Date().toISOString()})
            if(user.isCredentialsDisabled) {
                throw {message: 'Your Credentials are blocked' };
            }
            let updateObject = { emailAccessToken: req.user.accessToken, emailRefreshToken: req.user.refreshToken, emailServiceProvider: 'microsoft', lastLoginTimeStamp: new Date().toISOString(), emailSyncTimeStamp: new Date().toISOString(), emailSyncExpiration: dayjs().add(90, 'days').toISOString() }
            if(user.freeSubscriptionExpiration) {
              let isFreeTrial = new Date(user?.freeSubscriptionExpiration) > new Date()
              if(!isFreeTrial) {
               //if plan already expired and user try to login - if we not do this then after login getsession api will fail through verifyAccessToken middleware and it will not hold payment page after login
               updateObject.freeSubscriptionExpiration = null
              }
            }
            if(!user.firstTimeEmailSyncTimeStamp) {
              user.firstTimeEmailSyncTimeStamp = new Date().toISOString()
            }
            await db.user.update(updateObject, { where: { id: user.id } })
            if (!user.stripeCustomerId) {
               await CreateStripeCustomer(user.id)
            }
            await checkMicrosoftSubscriptionExpiration(user, email, user.microsoftSubscriptionExpirationEmail1, req.user.accessToken, req.user.refreshToken, 'microsoftSubscriptionIdEmail1', 'microsoftSubscriptionExpirationEmail1')
            !user.nextSyncTokenForEmail && await fetchMicrosoftEvents(req.user.accessToken, req.user.refreshToken, user.id, email, user.nextSyncTokenForEmail)
            const jwtToken = await generateAccessToken({ userId: user.id, role: user.userTypeId, lastPasswordUpdatedForSecurity: user?.lastPasswordUpdatedForSecurity, subscription: user.subscriptionId, orgId: user.baOrgId })
            if(created) {
              const content = `Your Account is Verified. Please find your credentials below <br/> Email: ${email} <br/> Username: ${user.username} <br/> Password: ${randomPassword} <br/> <br/> <b>Use these credentials for existing password field in the next screen.</b>`
              sendNotification(email, 'Account Verified', content)
            }
            res.cookie('accessToken', jwtToken, { httpOnly: true, sameSite: false, secure: true, domain: process.env.DOMAIN_NAME});
            res.cookie('isAuthenticated', true, {sameSite: false, secure: true, domain: process.env.DOMAIN_NAME});
            return res.redirect(`${CLIENT_URL}/dashboard`);
        }
        catch (error) {
            console.log(error)
            return res.redirect(`${CLIENT_URL}/error?message=${error.message}`);
        }
    }
}

exports.generateOtpForResetPassword = async (req, res) => {
    try {
        const { email } = req.body;
        const formatedEmail = email.toLowerCase()
        const user = await db.user.findOne({ where: { email :formatedEmail } })
        if (!user) {
            throw { statusCode: 401, message: 'User not Found' };
        }
        const otp = Math.floor(100000 + Math.random() * 900000);
        const otpRecord = await db.otp.findOne({ where: { email } })
        if (otpRecord) {
            otpRecord.otp = otp
            await otpRecord.save()
        }
        else {
            await db.otp.create({ email, otp })
        }
        sendNotification(email, 'NEW OTP', `Your otp is ${otp}`)
        // await emailNotification(email, 'NEW OTP', 'Your otp is '+ otp)
        return res.status(200).json({ success: true, otp: otp, message: "Otp Sent Successfully" })
    }
    catch (error) {
        return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.verifyOtpForResetPassword = async (req, res) => {
    try {
        let { email, otp } = req.body;
        email = email.toLowerCase();
        if (isNaN(otp)) {
            throw { statusCode: 401, message: 'Invalid Otp' };
        }
        const otpRecord = await db.otp.findOne({ where: { email, otp } })
        if (!otpRecord) {
            throw { statusCode: 401, message: 'Invalid Otp' };
        }
        return res.status(200).json({ success: true, message: "Otp Verified Successfully" })
    }
    catch (error) {
        return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.resetPassword = async (req, res) => {
    try {
        const { password, confirmPassword, otp, email } = req.body
        const user = await db.user.findOne({ where: { email } });
        if (!user) {
            throw { statusCode: 404, message: 'Email not found' };
        }
        if (password !== confirmPassword) {
            throw { statusCode: 400, message: "Password and confirmed passwords do not match." };
        }
        const otpRecord = await db.otp.findOne({ where: { otp, email } })
        if (!otpRecord) {
            throw { statusCode: 401, message: 'Invalid Otp' };
        }
        const isSameAsLastPassword = await comparePassword(password, user.password)
        if (isSameAsLastPassword) {
            throw { statusCode: 400, error: true, message: 'Password can not be same as Last password' };
        }
        const hashedPassword = await hashPassword(password);

        user.password = hashedPassword;
        user.isPasswordUpdated = true;
        user.passwordUpdatedCount = user.passwordUpdatedCount ? user.passwordUpdatedCount + 1 : 1
        await user.save()
        await db.otp.destroy({ where: { email } })
        const passwordVerificationKey = crypto.randomBytes(40).toString('hex');
        const [record, created] = await db.password_verification_key.findOrCreate({
            where: { userId: user.id }, 
            defaults: { userId: user.id, passwordVerificationKey: passwordVerificationKey } // Values to create if not found
          });
        if (!created) {
            record.passwordVerificationKey = passwordVerificationKey;
            await record.save()
        }
        const ClientUrl = req.headers.origin;
        const content = `
        <p>Your Password has been changed</p>
        <p>If you are not aware about this then please update your password</p>
        <a href="${ClientUrl}/reset-password-for-security/${user.id}/${passwordVerificationKey}"><button>Update Password</button></a>
        `
        sendNotification(user.email, 'Password Updated', content)
        return res.status(201).json({ success: true, message: 'Password Updated Successfully' });
    }
    catch (error) {
        return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.verifyAccountKey = async (req, res) => {
    try {
        const { userId, key } = req.params;
        const user = await db.user.findOne({ where: { id: userId } });
        if (!user) {
            throw { statusCode: 404, message: 'User not found' };
        }
        const record = await db.user_verification.findOne({ where: { userId: userId, accountVerifyKey: key } })
        if (!record) {
            throw { statusCode: 404, message: 'Invalid Key/User' };
        }
        record.isAccountVerified = true
        await record.save()

        if(user.email==record.email){
            const content = `Your Account is Verified. Please find your credentials below <br/> Email: ${user.email} <br/> Username: ${user.username} <br/> Password: ${user.temporaryPassword} <br/> <br/> <b><b>Use these credentials to log in and enter them in the existing password field on the next screen.</b></b>`
            sendNotification(user.email, 'Account Verified', content)
            // await emailNotification(user.email, 'Account Verified', content)
            user.temporaryPassword = null;
            await user.save()
        }
       
        return res.status(200).json({ success: true, message: 'Account Verified Successfully' });

    }
    catch (error) {
        return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.resendVerificationLink = async (req, res) => {
    try {
        const {userId, email} = req.body
        const user = await db.user.findByPk(userId)
        if (!user) {
            throw { statusCode: 404, message: 'User not found' };
        }
        const key = crypto.randomBytes(40).toString('hex');
        const isAlreadyExistRow = await db.user_verification.findOne({
            where: {
                userId: userId,
                email: email || user.email
            }
        });
        if(isAlreadyExistRow?.isAccountVerified == true){
            throw { statusCode: 400, message:'Account is already verified' }
        }
        if(email){
            if (isAlreadyExistRow) { 
                await db.user_verification.update({email: email, accountVerifyKey: key}, {where: {userId: user.id, email:email}})
            } else {
            await db.user_verification.create({email: email, accountVerifyKey: key, userId: user.id})
            }
            const ClientUrl = req.headers.origin;
            const content = `Click on below link to verify your account <br/> <a href=${ClientUrl}/verify-account/${user.id}/${key}>${ClientUrl}/verify-account/${user.id}/${key}</a>`
            sendNotification(email,'Verify Your account', content)
        }else{
        if (isAlreadyExistRow) { 
            await db.user_verification.update({email: user.email, accountVerifyKey: key}, {where: {userId: user.id, email: user.email}})
        } else {
        await db.user_verification.create({email: user.email, accountVerifyKey: key, userId: user.id})
        }
        const ClientUrl = req.headers.origin;
        const content = `Click on below link to verify your account <br/> <a href=${ClientUrl}/verify-account/${user.id}/${key}>${ClientUrl}/verify-account/${user.id}/${key}</a>`
        sendNotification(user.email,'Verify Your account', content)
        }

        return res.status(200).json({ success: true, data: user, message: 'Verification link sent Successfully' }); 
    } 
    catch (error) {
        return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.verifyKeyForUpdatePassword = async (req, res) => {
    try {
        const {userId, key} = req.params;
        const record = await db.password_verification_key.findOne({ where: { userId: userId, passwordVerificationKey: key } })
        if (!record) {
            // throw { statusCode: 404, message: 'Invalid Key/User' };
            throw { statusCode: 404, message: 'link expired' };
        }
     
        return res.status(200).json({ success: true, message: 'Verified' });
    } 
    catch (error) {
        return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.updatePasswordForSecurity = async (req, res) => {
    try {
        const {password, confirmPassword, userId, key} = req.body;
        const user = await db.user.findByPk(userId)
        if (!user) {
            throw { statusCode: 404, error: true, message: 'User not found' };
        }
        const record = await db.password_verification_key.findOne({ where: { userId: userId, passwordVerificationKey: key } })
        if (!record) {
            throw { statusCode: 404, message: 'Invalid Key/User' };
        }
        if (password !== confirmPassword) {
            throw { statusCode: 400, message: "Password and confirmed passwords do not match." };
        }
        const isSameAsLastPassword = await comparePassword(password, user.password)
        if (isSameAsLastPassword) {
            throw { statusCode: 400, error: true, message: 'Password can not be same as Last password' };
        }
        await db.password_verification_key.destroy({ where:{ userId: userId, passwordVerificationKey: key } })
        const hashedPassword = await hashPassword(password)
        user.password = hashedPassword;
        user.lastPasswordUpdatedForSecurity = new Date().toISOString();
        await user.save()
        return res.status(200).json({ success: true, message: 'Password Updated Successfully' });
    } 
    catch (error) {
        return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.googleLoginResponseForTimesheet = async (req, res) => {
    try {
        
    } 
    catch (error) {
        
    }
}

exports.microsoftLoginResponseForTimesheet = async (req, res) => {
    try {

        
    } 
    catch (error) {
        
    }
}

exports.createApiKey = async (req, res) => {
    const { orgId, secretKey, resourceId } = req.body;
  
    if (!orgId || !secretKey || !resourceId) {
      return res.status(400).json({ message: 'Missing required fields from : org id, client secret key, resource id' });
    }
  
    try {
      const existingEntry = await db.organization_resources.findOne({
        where: { resourceId,orgId },
        attributes: { exclude: ['id'] }
      });
  
      if (existingEntry) {
        return res.status(400).json({ message: 'API key is already active for this resourceId' });
      }
  
      const apiKey = crypto.randomBytes(128).toString('hex'); 
      const apiKey256 = apiKey.slice(0, 256);

  
      const hashedApiKey = await hashValue(apiKey256)
      const hashedSecretKey=await hashValue(secretKey);
  
       await db.organization_resources.create({
        orgId,
        apiKey: hashedApiKey,
        orgSecretKey: hashedSecretKey,
        resourceId,
      });

  
      return res.status(201).json({
        message: 'API Key created successfully',
        apiKey: apiKey256, 
      });
      } catch (error) {
      console.error(error);
      return res.status(500).json({ message: 'Server error' });
    }
  };
  
  

exports.getFaqTesting = async (req, res) => {
    try {
      const faq = await db.faq.findAll({order: [['id', 'asc']]});
      return res.status(200).json({ success: true, data: faq });
    }
    catch {
      return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
  }


  exports.getResources = async (req, res) => {
    try {
      const resources = await db.resources.findAll({
        order: [['resourceId', 'ASC']], 
      });
  
      return res.status(200).json({ success: true, data: resources });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ success: false, message: 'Something went wrong' });
    }
  };

exports.regenerateAPIKey= async (req, res) => {
  const { orgId, resourceId,secretKey } = req.body;

  if (!orgId || !secretKey || !resourceId) {
    return res.status(400).json({ message: 'Missing required fields from : org id, client secret key, resource id' });
  }

  try {
    
    const apiKey = crypto.randomBytes(128).toString('hex'); 
    const apiKey256 = apiKey.slice(0, 256);

    const hashedApiKey = await hashValue(apiKey256)
    const hashedSecretKey=await hashValue(secretKey);

    const [updatedRows] = await db.organization_resources.update(
      { apiKey: hashedApiKey,
        orgSecretKey:hashedSecretKey
       },
      {
        where: {
          orgId,
          resourceId,
        },
      }
    );

    if (updatedRows === 0) {
      return res.status(404).json({ message: 'No matching organization/resource found' });
    }

    return res.status(200).json({
      message: 'API Key regenerated successfully',
      apiKey: apiKey256,  
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Server error' });
  }
}

exports.deleteAPIKey = async (req, res) => {
    const { orgId, resourceId } = req.body;
  
    if (!orgId || !resourceId) {
      return res.status(400).json({ message: 'Missing required fields: orgId, resourceId' });
    }
  
    try {
      const resource = await db.organization_resources.findOne({
        where: {
          orgId,
          resourceId,
        },
      });
  
      if (!resource) {
        return res.status(404).json({ message: 'No matching organization/resource found' });
      }
  
      const deletedRows = await db.organization_resources.destroy({
        where: {
          orgId,
          resourceId,
        },
      });
  
      if (deletedRows === 0) {
        return res.status(404).json({ message: 'No matching organization/resource found to delete' });
      }
  
      return res.status(200).json({ message: 'API Key deleted successfully' });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: 'Server error' });
    }
  };


  exports.getMfaQRcode = async (req, res) => {
    const { userId } = req.body;
  
    if (!userId) {
      return res.status(400).json({ message: 'Missing required field: userId' });
    }
  
    try {
      const secret = speakeasy.generateSecret({ length: 20 });

        await db.user.update(
            {
            mfaSecret: secret.base32, 
            },
            {
            where: { id: userId }, 
            }
        );
  
      QRCode.toDataURL(secret.otpauth_url, (err, data_url) => {
        if (err) {
          console.error(err);
          return res.status(500).json({ message: 'Error generating QR code' });
        }
  
        return res.status(200).json({ qrCode: data_url });
      });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: 'Server error' });
    }
  };
  

  exports.updateMFAConfigurationSetup = async (req, res) => {
    const { userId, otp ,isFromHomeRoutePath} = req.body;
  
    if (!userId || !otp) {
      return res.status(400).json({ message: 'Missing required fields: userId, otp' });
    }
  
    try {

        const userResponse = await db.user.findOne({
            where: { id: userId },
            attributes: ['mfaSecret'], 
          });
      
  
      if (!userResponse) {
        return res.status(404).json({ message: 'User not found' });
      }
  
      const isVerified = speakeasy.totp.verify({
        secret: userResponse.mfaSecret,
        encoding: 'base32',
        token:otp, // The code entered by the user
      });
  
      if (isVerified) {

        const [updatedRows] = await db.user.update(
            {
             mfaConfigured:true, 
            },
            {
            where: { id: userId }, 
            }
        );
      
          if (updatedRows === 0) {
            return res.status(404).json({ message: 'User Not found to update Mfa configuration setup' });
          }

          if(isFromHomeRoutePath)
             res.cookie('isMFAAuthenticated', true, {sameSite: false, secure: true, domain: process.env.DOMAIN_NAME});

        return res.status(200).json({ success: true });
      } else {
        return res.status(400).json({ error: 'Invalid OTP Code' });
      }
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: 'Server error' });
    }
  };

  exports.enableMFA = async (req, res) => {
    const { userId, mfaEnabled } = req.body;
  
    if (!userId) {
      return res.status(400).json({ message: 'Missing required fields: userId' });
    }
  
    try {
        const [updatedRows] = await db.user.update(
            {
            mfaEnabled, 
            },
            {
            where: { id: userId }, 
            }
        );
      
          if (updatedRows === 0) {
            return res.status(404).json({ message: 'User Not found to enable Mfa' });
          }
        const message=mfaEnabled ? 'MFA Enabled' : 'MFA Disabled'

        return res.status(200).json({message  });
      } 
    catch (error) {
      console.error(error);
      return res.status(500).json({ message: 'Server error' });
    }
  };


  exports.verifyMFA = async (req, res) => {
    const { userId, otp } = req.body;
  
    if (!userId || !otp) {
      return res.status(400).json({ message: 'Missing required fields: userId, otp, adminUserId' });
    }
  
    try {

      const userResponse = await db.user.findOne({
        where: { id: userId },
        attributes: ['mfaSecret','fullname'],
      });

  
      if (!userResponse) {
        return res.status(404).json({ message: 'User not found' });
      }
  
      const isVerified = speakeasy.totp.verify({
        secret: userResponse.mfaSecret,
        encoding: 'base32',
        token:otp, // The OTP entered by the user
      });
  
      if (isVerified) {
        res.cookie('isMFAAuthenticated', true, {
          sameSite: false,
          secure: true,
          domain: process.env.DOMAIN_NAME,
        });

        const adminUsers = await db.user.findAll({
          where: { userTypeId: 3 }, // Assuming userTypeId = 3 is for admins
          attributes: ['id'], // Only retrieving 'id' of the users
        });
        
        const io = getIo();
        const connectedUsers = getConnectedUsers();
     

        if (adminUsers.length > 0) {
          // Loop through all admins and send notification
          adminUsers.forEach(admin => {
            // Implement your notification logic here
            console.log('Notifying Admin ID:', admin.id);
        
            // Example: Send the notification to the admin (you can customize this part)
            // For instance, emitting a WebSocket event or saving in a notification queue
            io.to(connectedUsers.get(+admin.id)).emit('USER_PASSED_MFA', { message: `User ${userResponse.fullname} has passed Multifactor Authentication.` });
            console.log("passed")
            // Alternatively, you can implement email/SMS or other types of notifications.
          });
        } 
        // Respond with success
        return res.status(200).json({ success: true });
      } else {
        return res.status(400).json({ error: 'Invalid OTP Code' });
      }
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: 'Server error' });
    }
  };

  
  exports.skipMFA = async (req, res) => {
   
    try {
        res.cookie('isMFASkipped', true, {sameSite: false, secure: true, domain: process.env.DOMAIN_NAME});
        return res.status(200).json({success:true  });
      } 
    catch (error) {
      console.error(error);
      return res.status(500).json({ message: 'Server error' });
    }
  };