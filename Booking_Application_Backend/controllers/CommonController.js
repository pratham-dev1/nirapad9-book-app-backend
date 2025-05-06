const db = require("../models");
const { hashPassword,comparePassword } = require("../utils/bcrypt");
const { fetchGoogleEvents } = require("../utils/fetchGoogleEvents");
const { fetchMicrosoftEvents } = require("../utils/fetchMicrosoftEvents");
const { sendGoogleEvent } = require("../utils/sendGoogleEvent");
const { sendMicrosoftEvent } = require("../utils/sendMicrosoftEvent");
const { fetchEventsForAllEmails } = require("../utils/fetchEventsForAllEmails");
const { sendNotification } = require("../utils/mailgun");
const fs = require('fs');
const { updateGoogleEvent } = require("../utils/updateGoogleEvent");
const { updateMicrosoftEvent } = require("../utils/updateMicrosoftEvent");
const { cancelGoogleEvent } = require("../utils/cancelGoogleEvent");
const { cancelMicrosoftEvent } = require("../utils/cancelMicrosoftEvent");
const { CLIENT_URL } = require("../config/urlsConfig");
const crypto = require('crypto');
const { getIo, getConnectedUsers } = require("../utils/socket");
const dbviews = require("../dbviews");
const dayjs = require('dayjs')
const axios = require('axios')
const {CheckSubscription} = require("../utils/CheckSubscription")
const { respondGoogleInvite } = require("../utils/respondGoogleInvite");
const { respondMicrosoftInvite } = require("../utils/respondMicrosoftInvite");
const { createMicrosoftRecurringEvent } = require("../utils/createMicrosoftRecurringEvent");
const { createGoogleRecurringEvent } = require("../utils/createGoogleRecurringEvent")
const csv = require('csv-parser')
const { Readable } = require('stream');
const { Op } = require("sequelize");
const { v4: uuidv4 } = require('uuid');
const Applications = require("../constants/Applications");
const redis = require("../config/redisConfig");

exports.createNewPassword = async (req, res) => {
    try {
        const { password, confirmPassword, oldPassword } = req.body
        const userId = req.user.userId
        const user = await db.user.findByPk(userId,{
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
        });
        if (!user) {
            throw { statusCode: 404, error: true, message: 'User not found' };
        }
        const isOldPasswordCorrect = await comparePassword(oldPassword, user.password);
        if (!isOldPasswordCorrect) {
          throw { statusCode: 400, error: true, message: 'Old password is incorrect' };
        }

        if (password !== confirmPassword) {
          throw { statusCode: 400, message: "Password and confirmed passwords do not match." };
      }
        
        const isSameAsLastPassword = await comparePassword(password, user.password)
        if (isSameAsLastPassword) {
            throw { statusCode: 400, error: true, message: 'Password can not be same as Last password' };
        }
        const hashedPassword = await hashPassword(password)

        const [updatedRowsCount, [updatedUser]] = await db.user.update({ password: hashedPassword, isPasswordUpdated: true }, { where: { id: userId }, returning: true });

        if (updatedRowsCount === 0) {
            throw { statusCode: 404, error: true, message: 'User not found' };
        }
        let isFreeTrial = false, isPaidPlan = false;
        if(user?.freeSubscriptionExpiration) {
           isFreeTrial = new Date(user?.freeSubscriptionExpiration) > new Date()
        }
        if(user.stripeSubscriptionId) {
            isPaidPlan = true
        }
        const userData = {userId: updatedUser.id, userType: updatedUser.userTypeId, isPasswordUpdated: updatedUser.isPasswordUpdated, userTypeName: user.usertype.userType, timezone: user.timezone, theme: user.theme, subscription: user.subscriptionId, orgId: user.baOrgId, isFreeTrial, isPaidPlan,mfaEnabled:user.mfaEnabled,mfaConfigured:user.mfaConfigured,mfaManditory:user.mfaManditory, appAccess: user.appAccess.map(i => i.id), isUsernameUpdated: user.isUsernameUpdated, isMergeCalendarGuideChecked: user.isMergeCalendarGuideChecked, isFreeTrialOver: user.isFreeTrialOver }

        if(user.passwordUpdatedCount === 0 && user.isPasswordUpdated === false && user.emailServiceProvider){
          const content = `Your Account is Verified. Please find your credentials below <br/> Email: ${user.email} <br/> Username: ${user.username} <br/> Password: ${password}`
          sendNotification(user.email, 'Account Verified', content)
        }
        return res.status(201).json({ success: true, message: 'Password Updated Successfully', data: userData });
    }
    catch (error) {
        return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}


// exports.getCalendarEvents = async (req, res) => {
//   try {
//       const {emails} = req.query;
//       const userId = req.user.userId;
//       const user = await db.user.findByPk(userId);
//       const failedEmails = await fetchEventsForAllEmails(user)
//       const response = await db.event.findAll({
//           include:[{
//               model: db.user,
//               // attributes: [],
//               attributes: ['email','email2', 'email3'],
//               include:[
//                   {
//                    model: db.event_color,
//                    attributes: ['id','color'],
//                    as: "colorForEmail1"
//                   },
//                   {
//                       model: db.event_color,
//                       attributes: ['id','color'],
//                       as: "colorForEmail2"
//                   },
//                   {
//                       model: db.event_color,
//                       attributes: ['id','color'],
//                       as: "colorForEmail3"
//                   }
//           ]
//           }],
//           where: {
//               userId: req.user.userId,
//               emailAccount: {
//                   [db.Sequelize.Op.in]: emails || []
//               },
//               updatedAt: db.sequelize.where(
//                 db.sequelize.literal(`(
//                     SELECT MAX("updatedAt")
//                     FROM "events" AS subEvents
//                     WHERE subEvents."eventId" = "event"."eventId"
//                 )`),
//                 '=',
//                 db.sequelize.col('updatedAt')
//             ) 
//           }
//       });
//       res.status(200).json({ success: true, data: response, failedEmails: failedEmails })
//   } catch (error) {
//       return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
//   }
// }

exports.getCalendarEvents = async (req, res) => {
  try {
      const {emails, calendars} = req.query;
      const userId = req.user.userId;
      const user = await db.user.findByPk(userId);
      // const failedEmails = await fetchEventsForAllEmails(user)
      const emailAccounts = [];
      if (calendars) {
        if (calendars.includes(user.emailServiceProvider)) {
          emailAccounts.push(user.email);
        }
        if (calendars.includes(user.email2ServiceProvider)) {
          emailAccounts.push(user.email2);
        }
        if (calendars.includes(user.email3ServiceProvider)) {
          emailAccounts.push(user.email3);
        }
      }
      const filteredEmailAccounts = emailAccounts.filter(email => emails.includes(email));

      const response = await dbviews.event_merge_calendar_view.findAll({
          where: {
              userId: req.user.userId,
              // emailAccount: {
              //     [db.Sequelize.Op.in]: emails || []
              // },
              isMicrosoftParentRecurringEvent: false,         // because microsoft recurring event saving two times in db through webhook - so we are filtering that parent event
              emailAccount: {
                [db.Sequelize.Op.in]: filteredEmailAccounts
              },
          }
      });
      res.status(200).json({ success: true, data: response, failedEmails: [] })
  } catch (error) {
      return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getUserEmailList = async (req, res) => {
    try {
        const userId = req.user.userId;
        const response = await db.user.findByPk(userId, {
            attributes: ['email', 'email2', 'email3', 'emailServiceProvider', 'email2ServiceProvider', 'email3ServiceProvider']
        });
        return res.status(200).json({ success: true, data: response })
    }
    catch (error) {
        return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.bookOpenAvailability = async (req, res) => {
  try {
      let { id,datetime, userId, purpose, booked, name, phone, email, tagId, guests = [], comments, tagTypeId, guestTimezone, systemTimezone, slotId, rescheduleReason} = req.body;
      const user = await db.user.findByPk(userId, {
        include: [
          {
            model: db.organization,
            as: 'organization'
          },
          { model: db.applications, as: 'appAccess', through: { attributes: [] }}
        ]
      })
      let slot;
      if(slotId){
        slot = await db.open_availability.findByPk(slotId)
        if(!slot) {
          return res.status(404).json({ error: true, message: 'Invalid slot' });
        }
        else if(!slot.booked) {
          return res.status(404).json({ error: true, isAlreadyRescheduled: true, message: 'The slot is already rescheduled by using this link' });
        }
      }
      email = slot ? slot.receiverEmail : email.toLowerCase()
      const isEmailBlocked = await db.blocked_email_by_slot_broadcaster.findOne({where: {email, tagId, tagOwnerUserId: userId}})
      if(isEmailBlocked) {
        return res.status(400).json({ success: false, message: 'Your Email has been blocked' })
      }
      if (user.isDeleted || user.isCredentialsDisabled) {
        return res.status(200).json({ isTagDeleted: true, message: 'Link Expired' })
      }
      const tag = await db.open_availability_tags.findOne({
        where: {
          userId: userId,
          id: tagId,
        },
        include: [
          {
          model: db.user,
          as: 'tagMembers',
          attributes: ['id', 'fullname', 'email'],
          through:{attributes:[]}
          },
          {
            model: db.states,
            as: 'stateDetails',
          },
          {
            model: db.cities,
            as: 'cityDetails',
          }
      ]
      })
      if (!tag) {
        return res.status(200).json({ success: true, isEmailDeleted: true, isTagDeleted: true, message: 'Link Expired'});
      }
      if (tag.isDeleted) {
        return res.status(200).json({ isTagDeleted: true, message: 'Link Expired', email: tag?.defaultEmail })
      }
      const hasSlotBroadcastAppAcesss = user.appAccess.map(i => i.id).includes(Applications.SLOT_BROADCAST)
      if(tag.isEmailDeleted || !hasSlotBroadcastAppAcesss) {
        return res.status(200).json({ success: true, isTagDeleted: true, email: tag.defaultEmail });
      }
      const isTagLinkTypeExist = await db.tag_link_type.findOne({where: {typeId: tagTypeId}})
      if (!isTagLinkTypeExist) {
        return res.status(400).json({ error: true, message: 'Something wrong with link' });
      }
      async function checkIfBookingAllowed() {
        if(!slotId) {  // if rescheduling
        let BookingAllowInSingleDay = 2, isAllowedByCount = false, isAllowedByDate = false, currentDate = dayjs().tz(systemTimezone), newCountToBeSaved;
        const isRecordExist = await db.open_availability_tag_verification.findOne({ 
          where: { tagId, userId, email, parsedDate: currentDate.format('DD-MM-YY') },
          order: [['id','DESC']]    // to get the latest row
        })
        if (isRecordExist) {
          isAllowedByCount = isRecordExist.count < BookingAllowInSingleDay;
          let existingDate = isRecordExist.parsedDate
          let isSameDate = existingDate === currentDate.format('DD-MM-YY')  // only comparing date but not time
          if (isAllowedByCount) {         // if count is less than BookingAllowInSingleDay
  
            if (isSameDate) {                // if booking on the same day
              newCountToBeSaved = 2
            }
            else {                         // if not on the same day - count make to 1
              newCountToBeSaved = 1
            }
            isAllowedByCount = true
            isAllowedByDate = true
          }
          else {     // means isRecordExist.count = 2
            if (isSameDate) {                  // can't book more than 2 slot with an email in a single day
              isAllowedByCount = false;
              isAllowedByDate = false;
            }
            else {
              newCountToBeSaved = 1
              isAllowedByCount = true
              isAllowedByDate = true
            }
          }
        }
        else {                         // user is coming for the very first time to book slot with particular tag
          isAllowedByCount = true
          isAllowedByDate = true
          newCountToBeSaved = 1
        }
        return { isAllowedByCount, isAllowedByDate, isRecordExist, currentDate, newCountToBeSaved}
      }
      }
      const { isAllowedByCount, isAllowedByDate, isRecordExist, currentDate, newCountToBeSaved } = await checkIfBookingAllowed() || {}
      if (!isAllowedByCount && !isAllowedByDate && !slotId) {
        return res.status(200).json({ success: true, isLimitOverToBookSlot: true, email: tag.defaultEmail });
      }
       
      const openAvailability = await db.open_availability.findByPk(id);
      if (!openAvailability) {
          return res.status(404).json({ error: true, message: 'Availability not found' });
      }
      if(datetime !== openAvailability.datetime){
        return res.status(200).json({ isTimeSlotChanged: true, message: 'Slot Timings were changed. Please select another slot' })
      }
      if (openAvailability.booked === true) {
        return res.status(404).json({ error: true, message: 'Selected Slot is already booked. Please select another Slot' });
      }
      openAvailability.meetingPurpose = slotId ? slot.meetingPurpose : purpose;
      openAvailability.receiverEmail = slotId ? slot.receiverEmail : email;
      openAvailability.receiverName = slotId ? slot.receiverName : name;
      openAvailability.receiverPhone = slotId ? slot.receiverPhone : phone;
      openAvailability.booked = slotId ? slot.booked : booked
      openAvailability.comments = slotId ? slot.comments : comments
      openAvailability.tagTypeId = slotId ? slot.tagTypeId : tagTypeId
      openAvailability.guestTimezone = slotId ? slot.guestTimezone : guestTimezone
      openAvailability.meetType = tag.meetType
      openAvailability.bookedAt = new Date().toISOString()

      if(rescheduleReason) {
        openAvailability.rescheduleReason = rescheduleReason
      }
      if(tag.meetType === 3) {
        openAvailability.houseNo = tag.houseNo
        openAvailability.houseName = tag.houseName
        openAvailability.street = tag.street
        openAvailability.area = tag.area
        openAvailability.state = tag.state
        openAvailability.city = tag.city
        openAvailability.pincode = tag.pincode
        openAvailability.landmark = tag.landmark
        openAvailability.mapLink = tag.mapLink
      }
      // await openAvailability.save();
      const title = tag.title
      const emailServiceProvider = openAvailability.emailServiceProvider;
      let meetingLink, accessToken, refreshToken,googleResponse, microsoftResponse, eventId;
      if (openAvailability.senderEmail === user.email) {
        accessToken = user.emailAccessToken
        refreshToken = user.emailRefreshToken
      }
      else if (openAvailability.senderEmail === user.email2) {
        accessToken = user.email2AccessToken
        refreshToken = user.email2RefreshToken
      }
      else if (openAvailability.senderEmail === user.email3) {
        accessToken = user.email3AccessToken
        refreshToken = user.email3RefreshToken
      }
      const outsideGuests = [...guests, email]
      const insideGuests = tag.tagMembers.map((item) => item.email)
      if (emailServiceProvider === 'google') {
          const attendeesForGoogle = [...outsideGuests, ...insideGuests].map(email => ({email: email}))
          googleResponse = await sendGoogleEvent(accessToken, refreshToken, openAvailability.datetime, attendeesForGoogle, title, openAvailability.endtime, null, null, null, {source: 'open_availabilities', sourceId: id}, tag.meetType)
          meetingLink = googleResponse?.meetingLink
          eventId = googleResponse?.eventId
          
        }  
      else if (emailServiceProvider === "microsoft") {
          const attendeesForMicrosoft = [...outsideGuests, ...insideGuests].map(email => ({ emailAddress: { address: email } }))
          microsoftResponse = await sendMicrosoftEvent(accessToken, refreshToken, openAvailability.datetime, attendeesForMicrosoft, userId, openAvailability.senderEmail, title, openAvailability.endtime, null, null, null, `open_availabilities-${id}`, tag.meetType)
          meetingLink = microsoftResponse?.meetingLink
          eventId = microsoftResponse?.eventId
        }

      if(!eventId && !meetingLink) {
        return res.status(400).json({error: true, message: "Some error occured - Try again"})
      }
 
      openAvailability.meetingLink = meetingLink || null;
      openAvailability.eventId = eventId || null;

      await openAvailability.save();
      // if (!user.isNotificationDisabled) {
      //     const io = getIo()
      //     const connectedUsers = getConnectedUsers()
      //     const description = `${name} has Booked your open slot for`
      //     const createdAt = new Date().toISOString()
      //     const notification = await db.notification.create({userId: userId, description: description, datetime: openAvailability.datetime, type: "create_event", meetingLink: meetingLink, createdAt})
      //     io.to(connectedUsers.get(+userId)).emit('OPEN_SLOT_EVENT_BOOKED', { id: notification.id, description: description, datetime: openAvailability.datetime, type: "create_event", meetingLink: meetingLink, createdAt})
      //   }
      
      const date = dayjs(openAvailability.datetime).tz(guestTimezone)
      const formattedDate = date.format('DD-MM-YYYY');
      const formattedTime = date.format('h:mm A');
      let template = tag.template;
      const subject = 'Your Event Slot is Booked – Welcome!'
      const locationValue = tag.meetType === 3 ? 
          `${tag.houseNo ? tag.houseNo + ", " : ""}${tag.houseName ? tag.houseName + ", " : ""}${
            tag.street ? tag.street + ", " : ""
          }${tag.area ? tag.area + ", " : ""}${tag.cityDetails?.name ? tag.cityDetails.name + ", " : ""}${
            tag.stateDetails?.name ? tag.stateDetails.name + ", " : ""
          }${tag.pincode ? tag.pincode + ", " : ""}${tag.landmark ? tag.landmark + ", " : ""}\n
          ${tag.mapLink ? `Map Link: ${tag.mapLink}` : ""}`
        : meetingLink;

      // If meetType is 3, remove the anchor tag wrapping ${location}
      if (tag.meetType === 3) {
        template = template.replace(
          /<li><strong>Location: <\/strong><a href="\${location}" [^>]*><strong>(.*?)<\/strong><\/a><\/li>/,
          '<li><strong>Location: </strong>${location}</li>'
        );
      }
      const variables = {
        date: formattedDate,
        time: `${formattedTime} (${guestTimezone})`,
        name: name,
        eventProvider: user.fullname || '',
        location: locationValue,
        organization: user?.organization?.organization || '',
        contact: user.primaryPhonenumber || '',
        website: 'http://website'
      }
      const contentForBookie = template.replace(/\${(.*?)}/g, (_, key) => variables[key.trim()]);
      const contentForProvider = `${name} has booked your open slot <br/> <b>Date - ${formattedDate}</b> <br/> <b>Time - ${formattedTime} (${guestTimezone})</b> <br/> <b>Title - ${title}</b>`
      sendNotification(openAvailability.senderEmail, subject, contentForProvider)
      sendNotification(email, subject, contentForBookie, null, openAvailability.senderEmail, false)
      // const failedEmails = await fetchEventsForAllEmails(user)
      // if(isRecordExist){
      //   await db.open_availability_tag_verification.update({datetime: currentDate.toISOString(), count: newCountToBeSaved, parsedDate: currentDate.format('DD-MM-YY')}, {where: {tagId, userId, email}})
      // }
      // else {
      if(!slotId) {    // if rescheduling
        await db.open_availability_tag_verification.create({tagId, userId, email, datetime: currentDate.toISOString(), count: newCountToBeSaved, parsedDate: currentDate.format('DD-MM-YY')})
      }
      const isApplicationUser = await db.user.findOne({
        where: {
          [Op.or]: [
            { email: email },
            { email2: email },
            { email3: email }
          ]
        },
        attributes: ['id']
      });

      // for rescheduling we need to cancel existing booked slot event
      if(slotId) {
        const eventId = slot.eventId
        try {
          if (slot.emailServiceProvider === 'google') {
            if (slot["senderEmail"] == user.email) {
              await cancelGoogleEvent(user.emailAccessToken, user.emailRefreshToken, eventId);
            } else if (slot["senderEmail"] == user.email2) {
              await cancelGoogleEvent(user.email2AccessToken, user.email2RefreshToken, eventId);
            } else if (slot["senderEmail"] == user.email3) {
              await cancelGoogleEvent(user.email3AccessToken, user.email3RefreshToken, eventId);
            }
  
          }
          else if (slot.emailServiceProvider === "microsoft") {
  
            if (slot["senderEmail"] == user.email) {
              await cancelMicrosoftEvent(user.emailAccessToken, user.emailRefreshToken, eventId, userId);
            } else if (slot["senderEmail"] == user.email2) {
              await cancelMicrosoftEvent(user.email2AccessToken, user.email2RefreshToken, eventId, userId);
            } else if (slot["senderEmail"] == user.email3) {
              await cancelMicrosoftEvent(user.email3AccessToken, user.email3RefreshToken, eventId, userId);
            }
          }
          
          slot.booked = false
          slot.receiverEmail = null
          slot.meetingLink = null
          slot.statusId = 1
          await slot.save()
        } catch (error) {
          console.error('Error cancelling event:', error);
          throw { statusCode: 500, message: error.message }
        }
      }
      if(slotId) {      // if reschedule
        const existingQueAns = await db.open_availability_feedback.findAll({where: {openAvailabilityId: id}})
        const queAns = existingQueAns.map(item => ({openAvailabilityId: slotId, question: item.question, answer: item?.answer, type: item.type}));
        await db.open_availability_feedback.bulkCreate(queAns);
        await db.open_availability_feedback.destroy({where:{openAvailabilityId: id}})
      }
      return res.status(200).json({ success: true, message: 'Open Availability Booked Successfully!!!', isApplicationUser : isApplicationUser ? true : false });
  } catch (error) {
      return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getOpenAvailabilityUserData = async (req, res) => {
    try {
      const { userId } = req.query;
      const userData = await db.user.findOne({
        where: { id: userId }, 
        attributes: ['fullname', 'profilePicture']
      });
      res.status(201).json({ success: true, userData: userData });
    } catch (error) {
      res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
  };

exports.getOpenAvailabilitySlots = async (req, res) => {
    try {
      const { userId, startDate, endDate, tagId, key } = req.query;
      const user = await db.user.findByPk(userId, {
        include: [
          {
            model: db.ba_organization,
            as: 'baOrgData'
          },
          { model: db.applications, as: 'appAccess', through: { attributes: [] }}
        ]
      })
      const tag = await db.open_availability_tags.findOne({
        where: {
          userId: userId,
          id: tagId,
          // isDeleted: null
        },
        include: {
          model: db.question,
          as: 'openAvailabilityQuestions',
          through:{attributes:['required']}
        }
      })
      if (!tag) {
        return res.status(200).json({ success: true, isEmailDeleted: true, isTagDeleted: true});
      }
      const hasSlotBroadcastAppAcesss = user.appAccess.map(i => i.id).includes(Applications.SLOT_BROADCAST)
      if (user.isDeleted || user.isCredentialsDisabled || tag.isDeleted || !hasSlotBroadcastAppAcesss) {
        return res.status(200).json({ success: true, isTagDeleted: true, email: tag?.defaultEmail, emailVisibility: tag.emailVisibility });
      }
      let start, end;
      if (startDate && endDate) {
        start = startDate;
        end = endDate
      }
      else {
        const currentDate = new Date();
   
        const firstAvailableSlot = await db.open_availability.findOne({
          where: {
            userId: userId,
            tagId: tagId,
            booked: false,
            isCancelled: false,
            datetime: {
              [db.Sequelize.Op.gt]: currentDate.toISOString()
            }
          },
          order: [['datetime', 'ASC']]
        });
        const datetime = new Date(firstAvailableSlot?.datetime);
        const firstAvailableSlotMonth = datetime.getMonth();
        const firstAvailableSlotYear = datetime.getFullYear();
        start = new Date(firstAvailableSlotYear, firstAvailableSlotMonth);
        end = new Date(firstAvailableSlotYear, firstAvailableSlotMonth + 1, 18, 29, 59, 999);
      }
      const response = await db.open_availability.findAll({
        where: {
          userId: userId,
          tagId: tagId,
          booked: false,
          isCancelled: false,
          datetime: {
            [db.Sequelize.Op.gt]: new Date().toISOString(),
            [db.Sequelize.Op.between]: [start, end]
          }
        },
        include: [{
          model: db.user,
          attributes: ['fullname', 'email']
        }],
        attributes: ['id', 'datetime'],
        order: [
          ['datetime', 'ASC']
        ]
      });
   
      res.status(200).json({ success: true, data: response, isTagDeleted: false, tagName: tag.tagName, openAvailabilityText: tag.openAvailabilityText, isAllowedToAddAttendees: tag.isAllowedToAddAttendees, openAvailabilityQuestions: tag.openAvailabilityQuestions, image: tag.image, isOrgDisabledTagLogo: user.baOrgData.isOrgDisabledTagLogo, showCommentBox: tag.showCommentBox, eventDuration: tag.eventDuration, emailVisibility: tag.emailVisibility });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  };


exports.getOpenAvailabilityHistory = async (req, res) => {
  try {
    const { page , pageSize, sortingOrder,sortingColumn,startDateFilter,endDateFilter, bookedFilter} = req.query;
   
    const offset = page * pageSize;
 
    let filter = {
      userId: req.user.userId
    };
    if (startDateFilter) {
      // const endDate = endDateFilter ? new Date(endDateFilter) : null;

      if (startDateFilter && endDateFilter) {
        // Reduce 30 minutes
        //  endDate.setMinutes(endDate.getMinutes() - 30);
        // Convert back to string
      // const newDateString = endDate.toISOString();

        filter.datetime = {
          [db.Sequelize.Op.and]: [

            { [db.Sequelize.Op.gte]: startDateFilter},

            { [db.Sequelize.Op.lte]: endDateFilter },
         
          ]
        };
      } else {
        filter.datetime = {
          [db.Sequelize.Op.gte]: startDateFilter,
        };
      }
    }
    if(bookedFilter === 'cancelled') {
      filter.isCancelled = true
    }
    else if (bookedFilter) {
      filter.booked = bookedFilter;
      filter.isCancelled = false
    }
    const response = await db.open_availability.findAndCountAll({
      where: filter,
      limit: +pageSize,
      offset: +offset,
      order: [[sortingColumn, sortingOrder]],
      include:[
        {
          model: db.open_availability_tags,
          attributes:['eventDuration', 'title'],
          as: 'tagData'
        },
        {
          model: db.open_availability_feedback,
          // attributes:['eventDuration', 'title'],
          as: 'questionDetails'
        },
        {
          model: db.states,
          as: 'stateDetail'
        },
        {
          model: db.cities,
          as: 'cityDetail'
        },
    ]
      // include: [
      //   {
      //     model: db.event,
      //     as: 'events',
      //     required: false,
      //     attributes: ['title'],
      //     order: [['updatedAt', 'DESC']],
      //     limit: 1
      //   }
      // ]
    });
    res.status(200).json({ success: true, data: response.rows, totalCount: response.count });
 
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.getEventColors = async (req, res) => {
    try {
        const response = await db.event_color.findAll()
        return res.status(200).json({ success: true, data: response });

    } catch (error) {
        return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}


// exports.checkExistingOpenAvailabilityOrSave = async (req, res) => {
//   try {
//     const { tpId, dateTimeSlots, email, tagId, duration } = req.body;
//     const slotsResponse = await db.open_availability.findAll({ where: { userId: req.user.userId }, attributes: ['datetime'], raw: true });
//     const dateTimeSlotsResponse = slotsResponse.map((item) => item.datetime);

//     const user = await db.user.findOne({ where: { id: req.user.userId }, raw: true })
//     let emailServiceProvider;
//     if (email == user.email) {
//       emailServiceProvider = user.emailServiceProvider;
//     } else if (email == user.email2) {
//       emailServiceProvider = user.email2ServiceProvider;
//     } else if (email == user.email3) {
//       emailServiceProvider = user.email3ServiceProvider;
//     }

//     // const failedEmails = await fetchEventsForAllEmails(user)
//     // if (failedEmails.length > 0) {
//     //   return res.status(500).json({ error: true, message: `No slots were saved as events could not be fetched for emails-`, failedEmails: failedEmails });
//     // }

//     // const eventsResponse = await db.event.findAll({
//     //   where: {
//     //     // emailAccount: email,
//     //     userId: req.user.userId,
//     //     updatedAt: {
//     //       [db.Sequelize.Op.eq]: db.sequelize.literal(`(
//     //             SELECT MAX("updatedAt")
//     //             FROM "events" AS subEvents
//     //             WHERE subEvents."eventId" = "event"."eventId"
//     //         )`)
//     //     }
//     //   },
//     //   attributes: ['startTime', 'endTime'],
//     //   raw: true
//     // });
//     const eventsResponse = await dbviews.event_merge_calendar_view.findAll({
//       where: {
//         userId: req.user.userId,
//       },
//       attributes: ['startTime', 'endTime'],
//       raw: true
//   });
//     const existingSlots = [];
//     const existingOpenSlots = [];
//     const existingEvents = [];
//     const newSlots = [];
//     const newSlotsOpenAvailability = [];
//     const newSlotsOpenAvailabilityExpanded = [];
//     const newEventSlots = [];
//     const newEventSlotsExpanded = [];
//     const lastDateTimeSlotString = dateTimeSlots[dateTimeSlots.length - 1];
//     const endDateTimeSlot = new Date(lastDateTimeSlotString);
//     endDateTimeSlot.setMinutes(endDateTimeSlot.getMinutes() + duration);
//     // const endDateTimeSlotTime = endDateTimeSlot.getHours() * 3600000 + endDateTimeSlot.getMinutes() * 60000 + 15 * 60000;

//     dateTimeSlots.forEach(newSlot => {
//       let currentSlot = new Date(newSlot);
//       let addToNew = true;
//       dateTimeSlotsResponse.forEach(existingSlot => {
//         const slotDiffInMinutes = Math.abs((currentSlot.getTime() - new Date(existingSlot).getTime()) / (1000 * 60));
//         if (slotDiffInMinutes < duration) {
//           addToNew = false;
//           let withinThirtyMinutesOfNewSlot = false;
//           newSlotsOpenAvailability.forEach(newSlot => {
//             const diffFromNewSlot = Math.abs((currentSlot.getTime() - new Date(newSlot).getTime()) / (1000 * 60));
//             if (diffFromNewSlot < duration) {
//               withinThirtyMinutesOfNewSlot = true;
//             }
//           });
//           if (!withinThirtyMinutesOfNewSlot && !existingOpenSlots.includes(existingSlot)) {
//             existingOpenSlots.push(existingSlot);
//           }
//         }
//       });

//       if (addToNew) {
//         if ((endDateTimeSlot - (currentSlot.getHours() * 3600000 + currentSlot.getMinutes() * 60000)) >= duration * 60 * 1000) {
//           dateTimeSlotsResponse.push(currentSlot?.toISOString());
//           newSlotsOpenAvailability.push(currentSlot)
//         }
//       }
//     })
//     newSlotsOpenAvailability.forEach(slot => {
//       newSlotsOpenAvailabilityExpanded.push(slot.toISOString())
//       const shiftedSlot = new Date(slot.getTime() + 15 * 60 * 1000);
//       newSlotsOpenAvailabilityExpanded.push(shiftedSlot.toISOString());
//     })

//     newSlotsOpenAvailabilityExpanded.forEach(slot => {
//       let addToNew = true
//       const newSlotStartDateTime = new Date(slot)
//       const newSlotEndTime = new Date(slot).getTime() + duration * 60000; // Add 30 minutes to availability datetime
//       const newSlotEndDateTime = new Date(newSlotEndTime);
//       if (eventsResponse.length > 0) {
//         eventsResponse.forEach(existingEvent => {
//           const existingEventStartDateTime = new Date(existingEvent.startTime);
//           const existingEventEndDateTime = new Date(existingEvent.endTime);
//           if ((newSlotStartDateTime >= existingEventStartDateTime && newSlotStartDateTime < existingEventEndDateTime) ||
//             (newSlotEndDateTime > existingEventStartDateTime && newSlotEndDateTime < existingEventEndDateTime)
//           ) {
//             if (!existingEvents.some(event => event.startTime === existingEvent.startTime && event.endTime === existingEvent.endTime)) {
//               existingEvents.push(existingEvent);
//             }
//             addToNew = false;
//           }

//           if (addToNew) {
//             if (req.user.role == 1 && (!newEventSlots.length || (newSlotStartDateTime.getTime() - new Date(newEventSlots[newEventSlots.length - 1]).getTime()) >= duration * 60 * 1000)) {
//               newEventSlots.push(newSlotStartDateTime);
//             } else if (!(req.user.role == 1) && !newSlots.length || (newSlotStartDateTime.getTime() - new Date(newSlots[newSlots.length - 1]).getTime()) >= duration * 60 * 1000) {
//               newSlots.push(newSlotStartDateTime.toISOString());
//             }
//           }
//         });
//       } else {
//         if (req.user.role == 1 && (!newEventSlots.length || (newSlotStartDateTime.getTime() - new Date(newEventSlots[newEventSlots.length - 1]).getTime()) >= duration * 60 * 1000)) {
//           newEventSlots.push(newSlotStartDateTime);
//         } else if (!newSlots.length || (newSlotStartDateTime.getTime() - new Date(newSlots[newSlots.length - 1]).getTime()) >= duration * 60 * 1000) {
//           newSlots.push(newSlotStartDateTime.toISOString());
//         }
//       }
//     })

//     newEventSlots.forEach(slot => {
//       newEventSlotsExpanded.push(slot.toISOString())
//       const shiftedSlot = new Date(slot.getTime() + 15 * 60 * 1000);
//       newEventSlotsExpanded.push(shiftedSlot.toISOString());
//     })

//     if (req.user.role === 1) {
//       const availabilities = await db.availability.findAll({ where: { tpId: req.user.userId }, attributes: ['datetime'], raw: true });
//       const slotsDateTime = availabilities.map((item) => item.datetime);
//       newEventSlotsExpanded.forEach(newSlot => {
//         let currentSlot = new Date(newSlot);
//         let addToNew = true;
//         slotsDateTime.forEach(existingSlot => {
//           const slotDiffInMinutes = Math.abs((currentSlot.getTime() - new Date(existingSlot).getTime()) / (1000 * 60));
//           if (slotDiffInMinutes < duration) {
//             addToNew = false;
//             let withinThirtyMinutesOfNewSlot = false;
//             newSlots.forEach(newSlot => {
//               const diffFromNewSlot = Math.abs((currentSlot.getTime() - new Date(newSlot).getTime()) / (1000 * 60));
//               if (diffFromNewSlot < duration) {
//                 withinThirtyMinutesOfNewSlot = true;
//               }
//             });
//             if (!withinThirtyMinutesOfNewSlot && !existingSlots.includes(existingSlot)) {
//               existingSlots.push(existingSlot);
//             }
//           }
//         });

//         if (addToNew) {
//           if ((endDateTimeSlot - (currentSlot.getHours() * 3600000 + currentSlot.getMinutes() * 60000)) >= duration * 60 * 1000) {
//             slotsDateTime.push(currentSlot?.toISOString());
//             if (!newSlots.length || (currentSlot.getTime() - new Date(newSlots[newSlots.length - 1]).getTime()) >= duration * 60 * 1000) {
//               newSlots.push(currentSlot.toISOString());
//             }
//           }
//         }
//       })
//     }

//     if (existingSlots.length > 0 || existingEvents.length > 0 || existingOpenSlots.length > 0) {
//       return res.status(200).json({ existingEvents, existingSlots, newSlots, existingOpenSlots, success: true });
//     }

//     const entries = newSlots.map((dateTimeSlot) => ({ userId: req.user.userId, datetime: dateTimeSlot, senderEmail: email, emailServiceProvider: emailServiceProvider, tagId, endtime: dayjs(dateTimeSlot).add(duration, 'minutes').toISOString() }));
//     await db.open_availability.bulkCreate(entries);
//     const tag = await db.open_availability_tags.findByPk(tagId, {
//       include: {
//         model: db.user,
//         as: 'tagMembers',
//         attributes: ['id', 'fullname', 'email', 'emailServiceProvider'],
//         through:{attributes:[]}
//       }
//     })
//     for (const item of tag?.tagMembers) {
//       const entriesForTagMembers = newSlots.map((dateTimeSlot) => ({userId: item.id, datetime: dateTimeSlot, senderEmail: item.email, emailServiceProvider: item?.emailServiceProvider, tagId, endtime: dayjs(dateTimeSlot).add(duration, 'minutes').toISOString() }))
//       await db.open_availability.bulkCreate(entriesForTagMembers);
//     }
//     return res.status(200).json({ success: true, message: 'Slots Saved Successfully', newSlots: newSlots });
//   }
//   catch (error) {
//     res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
//   }
// }

// exports.saveSlotOpenAvailability = async (req, res) => {
//     try {
//       const { tpId, dateTimeSlots, email, tagId, duration } = req.body;
//       const user = await db.user.findOne({where:{id: req.user.userId}, raw:true})
//       let emailServiceProvider;
//       if(email == user.email){
//         emailServiceProvider = user.emailServiceProvider;
//       }else if(email == user.email2){
//         emailServiceProvider = user.email2ServiceProvider;
//       }else if(email == user.email3){
//         emailServiceProvider = user.email3ServiceProvider;
//       }
//       const enteries = dateTimeSlots.map((dateTimeSlot) => ({ userId: req.user.userId, datetime: dateTimeSlot, senderEmail: email, emailServiceProvider:emailServiceProvider, tagId, endtime: dayjs(dateTimeSlot).add(duration, 'minutes').toISOString() }));
//       await db.open_availability.bulkCreate(enteries);
//       const tag = await db.open_availability_tags.findByPk(tagId, {
//         include: {
//           model: db.user,
//           as: 'tagMembers',
//           attributes: ['id', 'fullname', 'email', 'emailServiceProvider'],
//           through:{attributes:[]}
//         }
//       })
//       for (const item of tag?.tagMembers) {
//         const entriesForTagMembers = dateTimeSlots.map((dateTimeSlot) => ({userId: item.id, datetime: dateTimeSlot, senderEmail: item.email, emailServiceProvider: item?.emailServiceProvider, tagId, endtime: dayjs(dateTimeSlot).add(duration, 'minutes').toISOString() }))
//         await db.open_availability.bulkCreate(entriesForTagMembers);
//       }
//       res.status(201).json({ success: true, message: 'Slots Saved Successfully' });
//     }
//     catch (error) {
//       res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
//     }
//   };

  exports.updateExistingOpenAvailability = async (req, res) => {
    try {
      const { id, dateTimeSlot, title, endtime } = req.body;
      const givenDateTime = new Date(dateTimeSlot)
      const currentDateTime = new Date()
      if (givenDateTime.getTime() < currentDateTime.getTime()) {
        throw {statusCode: 400, message: "Please give future time only"}
      }
      const exactSlotResponse = await db.open_availability.findOne({where:{id: id},attributes:['datetime','booked'],raw:true})
      if((dateTimeSlot == exactSlotResponse.datetime)){
        return res.status(400).json({ message: 'Slot time is the same as previous datetime', success: false });
      }
      if(exactSlotResponse.booked){
        return res.status(200).json({
          //  isOpenSlotBooked:true,
           message: 'Your Slot was just booked please retry', success: true });
      }
      const slotsResponse = await db.open_availability.findAll({ where: { userId: req.user.userId,
        id: { [db.Sequelize.Op.ne]: id }  },
        attributes: ['datetime'] ,raw: true});
      const dateTimeSlotsResponse = slotsResponse.map((item) => item.datetime);
      const isExactDuplicate = dateTimeSlotsResponse.includes(dateTimeSlot);
      if (isExactDuplicate) {
        return res.status(400).json({ message: 'Slot time is the same as an existing slot', success: false });
      }
      // const isInvalidSlot = dateTimeSlotsResponse.some(existingDateTime => {
      //   const slotDiff = Math.abs(new Date(dateTimeSlot).getTime() - new Date(existingDateTime).getTime());
      //   return slotDiff < 30 * 60 * 1000;
      // });
      // if (isInvalidSlot) {
      //   return res.status(400).json({ message: 'Slot time is less than 30 minutes of existing slot', success: false });
      // }
      await db.open_availability.update({ datetime: dateTimeSlot, endtime }, { where: { id: id } });
      return res.status(200).json({ message: 'Slot updated Successfully', success: true });
    } catch (error) {
      console.error('Error:', error);
      res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
};

exports.deleteSingleOrMultipleOpenAvailabilities = async (req, res) => {
  try {
    const { ids } = req.body;
    await db.open_availability.destroy({ where: { id: ids } });
    return res.status(201).json({ success: true, message: `${ids.length > 1 ? 'Availabilities' : 'Availability' } deleted successfully` });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.deleteBookedSingleOpenAvailabilities = async (req, res) => {
  try {
    let { id, userId } = req.body;
    userId = (userId || req.user.userId)
    const user = await db.user.findByPk(userId)
    // const failedEmails = await fetchEventsForAllEmails(user)
    // if (failedEmails.length > 0) {
    //     return res.status(400).json({ error: true, message: `Event cancellation failed - Events could not be fetched for emails-`, failedEmails: failedEmails });
    // }
    const eventIdResponse = await db.open_availability.findOne({
      where: { id: id},
      attributes: {exclude: ['id']},
      raw: true,
    })
      // const meetingLink = eventIdResponse?.meetingLink
      // const eventIdFromView = await dbviews.event_merge_calendar_view.findOne({where:{meetingLink:meetingLink}})
      const eventId = eventIdResponse?.eventId; 
      if(eventIdResponse.booked) {
      try {
        if (eventIdResponse.emailServiceProvider === 'google') {
          if (eventIdResponse["senderEmail"] == user.email) {
            await cancelGoogleEvent(user.emailAccessToken, user.emailRefreshToken, eventId);
          } else if (eventIdResponse["senderEmail"] == user.email2) {
            await cancelGoogleEvent(user.email2AccessToken, user.email2RefreshToken, eventId);
          } else if (eventIdResponse["senderEmail"] == user.email3) {
            await cancelGoogleEvent(user.email3AccessToken, user.email3RefreshToken, eventId);
          }

        }
        else if (eventIdResponse.emailServiceProvider === "microsoft") {

          if (eventIdResponse["senderEmail"] == user.email) {
            await cancelMicrosoftEvent(user.emailAccessToken, user.emailRefreshToken, eventId, req.user.userId);
          } else if (eventIdResponse["senderEmail"] == user.email2) {
            await cancelMicrosoftEvent(user.email2AccessToken, user.email2RefreshToken, eventId, req.user.userId);
          } else if (eventIdResponse["senderEmail"] == user.email3) {
            await cancelMicrosoftEvent(user.email3AccessToken, user.email3RefreshToken, eventId, req.user.userId);
          }
        }

      } catch (error) {
        console.error('Error cancelling Microsoft event:', error);
        throw { statusCode: 500, message: error.message }
      }
      await db.open_availability.create({...eventIdResponse, isCancelled: true, meetingLink: null, booked: false})
      await db.open_availability.update({booked: false, meetingLink: null, statusId: 1, isBookedSlotUpdated: false, receiverEmail: null}, {where: {id: id}})
      await db.open_availability_feedback.destroy({where: {openAvailabilityId: id}})
      return res.status(201).json({ success: true, eventIdResponse: eventIdResponse, message: 'Event deleted successfully' });
    }
    else {
      return res.status(404).json({ message: 'This event is already deleted', success: true });
    }
  }
  catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.saveProfilePicture = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).send('No files were uploaded.');
    }
    const user = await db.user.findByPk(req.user.userId)
    user.profilePicture = req.file.filename
    await user.save()
    return res.status(200).json({ success: true, message: 'Profile picture uploaded successfully' });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }

};

exports.getUserDetails = async (req, res) => {
  try {
    const user = await db.user.findByPk(req.user.userId, { attributes: ['id','username','fullname','phonenumber', 'email','email2','email3', 'profilePicture',  'phonenumber2', 'phonenumber3', 'phonenumber4', 'phonenumber5', 'primaryPhonenumber', 'aboutMeText', 'isNotificationDisabled', 'phonenumberCountryCode', 'phonenumber2CountryCode', 'phonenumber3CountryCode', 'phonenumber4CountryCode', 'phonenumber5CountryCode', 'baOrgId', 'business'],
    include: [{
      model: db.timezone,
      as: 'timezone',
      attributes: ['id', 'timezone', 'value', 'abbreviation']
    },
    {
      model: db.user_personality_trait,
      as: 'userPersonalityTrait'
    },
    {
      model: db.designation,
      as: 'designation',
    },
    {
      model: db.organization,
      as: 'organization',
    },
    { 
      model: db.user_verification,
      attributes: ['isAccountVerified','email']
    },
    { 
      model: db.ba_organization,
      as: 'baOrgData'
    },
    ]
     })
    const userCurrentLocation =  await db.user_current_location.findOne({
      where:{
        userId: req.user.userId,
        addedTime: {
          [db.Sequelize.Op.eq]: db.sequelize.literal(`(
                SELECT MAX("addedTime")
                FROM "user_current_location" 
                WHERE "user_current_location"."userId" = ${req.user.userId}
            )`)
        }
      },
      include:[{
        model: db.cities,
        as: 'city',
        include: [
          {
            model: db.states,
            as: 'state',
            include: [
              {
                model: db.countries,
                as: 'country'
              }
            ]
          },
        ],
      },]
    })

    return res.status(200).json({ success: true, userData: user, userCurrentLocation });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.addGeneralSkills = async (req, res) => {
  try {
    let { skills, secondarySkills, skillFreeText, secondarySkillFreeText } = req.body;
    const user = await db.user.findByPk(req.user.userId)
    if (!user) {
      throw { statusCode: 404, message: 'User not found' }
    }
    if (skills) {
      await user.addGeneralSkills(skills); // will create record in relation table (tp_skills) for each skillId
    }
    if (secondarySkills) {
      await user.addGeneralSecondarySkills(secondarySkills)
    }
    if (skillFreeText) {
      const FreeTextSkills = skillFreeText.map(skill => ({ skillName: skill, userId: req.user.userId }))
      await db.user_associated_general_skill.bulkCreate(FreeTextSkills)
    }
 
    if (secondarySkillFreeText) {
      const FreeTextSecondarySkills = secondarySkillFreeText.map(secondarySkill => ({ secondarySkillName: secondarySkill, userId: req.user.userId }))
      await db.user_associated_general_secondary_skill.bulkCreate(FreeTextSecondarySkills)
    }
    res.status(201).json({ success: true, message: 'Skills added successfully' });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.getGeneralSkills = async (req, res) => {
  try {
    // let { skills, secondarySkills } = req.body;
    const response = await db.user.findByPk(req.user.userId, {
      attributes: [],
      include: [
        { model: db.skill, as: "generalSkills" },
        { model: db.secondary_skill, as: "generalSecondarySkills" },
      ],
    });
    const userAssociatedGeneralSkills = await db.user_associated_general_skill.findAll({
      attributes: ["id", "skillName"],
      where: {
        userId: req.user.userId
      }
    })
    const userAssociatedGeneralSecondarySkills = await db.user_associated_general_secondary_skill.findAll({
      attributes: ["id", "secondarySkillName"],
      where: {
        userId: req.user.userId
      }
    })
    res.status(201).json({
      success: true, data: response, userAssociatedGeneralSkills: userAssociatedGeneralSkills,
      userAssociatedGeneralSecondarySkills: userAssociatedGeneralSecondarySkills
    });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.deleteGeneralSkills = async (req, res) => {
  try {
    let { id, userAssociated, primarySkill } = req.body;
    const user = await db.user.findByPk(req.user.userId)
    if (primarySkill && !userAssociated) {
      await user.removeGeneralSkills(id);
    }

    if (!primarySkill && !userAssociated) {
      await user.removeGeneralSecondarySkills(id);
    }

    if (primarySkill && userAssociated) {
      await db.user_associated_general_skill.destroy({
        where: {
          id: id
        }
      });
    }
    if (!primarySkill && userAssociated) {
      await db.user_associated_general_secondary_skill.destroy({
        where: {
          id: id
        }
      });
    }
    res.status(201).json({ success: true, message: 'Skills deleted successfully' });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.editUserDetails = async (req, res) => {
  try {
    let {username, fullname, designation, organization, city, timezone } = req.body;
    username = username?.toLowerCase();
    const user = await db.user.findByPk(req.user.userId);
    if (!user) {
      throw { statusCode: 404, message: 'User not found' }
    }
   
    if (username !== undefined) {
      if (username !== user.username) {
        const existingUser = await db.user.findOne({
          where: {
            username: username
          }
        });
        if(user.usernameUpdatedCount === 1) {
          throw { statusCode: 400, message: 'You can not change username again' };
        }
        if (existingUser && existingUser.userId !== req.user.userId) {
          throw { statusCode: 400, message: 'Username already exists' };
        }
        user.username = username;
        user.usernameUpdatedCount = user.usernameUpdatedCount + 1
        user.isUsernameUpdated = true
      } 
      else if (username == user.username){
        throw { statusCode: 400, message: 'Username is same as previous username' };
      }

    }

    if (fullname !== undefined) {
      user.fullname = fullname;
    }
    if (designation !== undefined) {
      user.designationId = designation;
    }
    if (organization !== undefined) {
      user.organizationId = organization;
    }
    await db.user_current_location.create({
      userId: req.user.userId,
      currentCityId: city
    });
    if (timezone !== undefined) {
      user.timezoneId = timezone;
    }

    await user.save();
    const updatedUser = await db.user.findOne({
      where: { id: req.user.userId },
      attributes:[],
      include: [
          {
              model: db.timezone,
              as: 'timezone',
              attributes: ['id', 'timezone', 'value', 'abbreviation']
          }
      ]
      // raw:true
    });
    await redis.del(`/api/common/get-user-details#userId:${req.user.userId}`)          // invalidating key for redis
    return res.status(200).json({ success: true,timezone: updatedUser.timezone, message: 'User Updated Successfully!!!' });
  } catch (error) {
    return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getNotifications = async (req, res) => {
  try {
    const notifications = await db.notification.findAll({
      where: {userId: req.user.userId},
      include:{
        model: db.open_availability,
        as: 'openAvailabilityData',
        attributes: ['receiverName', 'statusId', 'receiverEmail', 'comments']
      },
      order: [['id', 'desc']],
    });
    return res.status(200).json({ success: true, data: notifications });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.deleteProfilePicture = async (req, res) => {
  try {
    const user = await db.user.findByPk(req.user.userId);
    if (!user.profilePicture) {
      return res.status(404).json({ error: true, message: 'No profile picture found for the user' });
    }
 
    fs.unlinkSync(`./public/images/profilePictures/${user.profilePicture}`);
   
    user.profilePicture = null;
    await user.save();
    return res.status(200).json({ success: true, message: 'Profile picture deleted successfully' });
  } catch (error) {
    return res.status(500).json({ error: true, message: 'Failed to delete profile picture' });
  }
};

exports.saveOpenAvailabilityText = async (req, res) => {
  try {
    let { openAvailabilityText } = req.body;
    const user = await db.user.findByPk(req.user.userId)
    if (!user) {
      throw { statusCode: 404, message: 'User not found' }
    }
    user.openAvailabilityText = openAvailabilityText;
    await user.save();
    res.status(201).json({ success: true, message: 'Open Availability Text Saved Successfully' });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.saveOpenAvailabilityTag = async (req, res) => {
  try {
    const { tagName, defaultEmail, openAvailabilityText, template, membersAddedByAdmin, eventTypeId, isAllowedToAddAttendees, questions, title, showCommentBox, duration, meetType, emailVisibility, isPrimaryEmailTag, houseNo, houseName, street, area, country, state, city, pincode, landmark, mapLink} = req.body;
    const userId = req.user.userId;
    const user = await db.user.findByPk(userId);
    if (!user) {
      throw { statusCode: 404, message: 'User not found' }
    }
    let isEmailSynced = false;
    if (user.email === defaultEmail) {
       isEmailSynced = Boolean(user.emailAccessToken)
    }
    else if(user.email2 === defaultEmail) {
      isEmailSynced = Boolean(user.email2AccessToken)
    }
    else if(user.email3 === defaultEmail) {
      isEmailSynced = Boolean(user.email3AccessToken)
    }
    if(!isEmailSynced) {
      throw {statusCode: 400, message: 'Please Sync your email first'}
    }
    const tags = await db.open_availability_tags.findAll({where: {userId}})
    const { IS_BASIC } = CheckSubscription(user?.subscriptionId)
    if(IS_BASIC && tags.length >= 1) {
      return res.status(400).json({ subscriptionError: true});
    }

    if(isPrimaryEmailTag) {
      const primaryEmailTagCount = await db.open_availability_tags.count({where: {defaultEmail: defaultEmail, userId}})
      if(primaryEmailTagCount === 3) {
        throw {statusCode: 400, message: "You can not create more than 3 tag with primary email"}
      }
      const tagNameExists = await db.open_availability_tags.findOne({
        where: {
          tagName,
          userId: req.user.userId
        }
      });
      if (tagNameExists) {
        let errorMessage = 'TagName already exists';
        throw { statusCode: 404, message: errorMessage }
      }
    }
    else {
    const tagNameOrEmailExists = await db.open_availability_tags.findOne({
      where: {
        [db.Sequelize.Op.or]: [
          { tagName: tagName },
          { defaultEmail: defaultEmail }
        ],
        userId: req.user.userId
      }
    });
    if (tagNameOrEmailExists) {
      let errorMessage = 'TagName already exists';
      if (tagNameOrEmailExists.defaultEmail === defaultEmail) {
        errorMessage = 'Email is already associated with a Tag';
      }
      throw { statusCode: 404, message: errorMessage }
    }
  }
    const openAvailabilityTag = await db.open_availability_tags.create({tagName, defaultEmail, userId, openAvailabilityText, template, eventTypeId, isAllowedToAddAttendees, image: (req?.file?.filename || null), title, showCommentBox, isPrimaryEmailTag, eventDuration: duration, meetType, emailVisibility, houseNo, houseName, street, area, country, state, city, pincode, landmark, mapLink})
    if(Array.isArray(membersAddedByAdmin)) {
      await openAvailabilityTag.setTagMembers(membersAddedByAdmin)
    }
    if(Array.isArray(questions)) {
      for(const item of questions) {
        await db.open_availability_tag_question.create({openAvailabilityTagId: openAvailabilityTag.id, questionId: item.questionId, required: item.required })
      }
    }
    res.status(201).json({ success: true, message: 'Tag Saved Successfully' });
  }
  catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getOpenAvailabilityTag = async (req, res) => {
  try {
    const userId = req.user.userId;
    const tags = await db.open_availability_tags.findAll({
      where: {userId, isEmailDeleted: false},
      include: [
      {
        model: db.user,
        as: 'tagMembers',
        attributes: ['id', 'fullname', 'email'],
        through:{attributes:[]}
      },
      {
        model: db.question,
        as: 'openAvailabilityQuestions',
        through:{attributes:['required']}
      },
      {
        model: db.states,
        as: 'stateDetails',
      },
      {
        model: db.cities,
        as: 'cityDetails',
      },
      {
        model: db.countries,
        as: 'countryDetails',
      }
    ]
    })
    res.status(201).json({ success: true, data: tags });
  } 
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.editOpenAvailabilityTag = async (req, res) => {
  try {
    let { id, tagName, openAvailabilityText, template, membersAddedByAdmin, eventTypeId, isAllowedToAddAttendees, questions, title, showCommentBox, duration, isImageDelete, meetType, emailVisibility, houseNo, houseName, street, area, country, state, city, pincode, landmark, mapLink} = req.body;
    const openAvailabilityTag = await db.open_availability_tags.findByPk(id);
    if (tagName && tagName !== openAvailabilityTag.tagName) {
      const existingTags = await db.open_availability_tags.findAll({
        where: { userId: req.user.userId, tagName: tagName },
      });
      if (existingTags.length > 0) {
        return res.status(400).json({ error: true, message: 'TagName already exists' });
      }
      openAvailabilityTag.tagName = tagName;
    }
    openAvailabilityTag.openAvailabilityText = openAvailabilityText;
    openAvailabilityTag.template = template
    openAvailabilityTag.eventTypeId = eventTypeId
    openAvailabilityTag.isAllowedToAddAttendees = isAllowedToAddAttendees
    openAvailabilityTag.title = title;
    openAvailabilityTag.showCommentBox = showCommentBox;
    openAvailabilityTag.meetType = meetType
    // openAvailabilityTag.address = address
    openAvailabilityTag.emailVisibility = emailVisibility
    openAvailabilityTag.houseNo = houseNo
    openAvailabilityTag.houseName = houseName
    openAvailabilityTag.street = street
    openAvailabilityTag.area = area
    openAvailabilityTag.state = state
    openAvailabilityTag.city = city
    openAvailabilityTag.country = country
    openAvailabilityTag.pincode = pincode
    openAvailabilityTag.landmark = landmark
    openAvailabilityTag.mapLink = mapLink
    if(duration) {
      openAvailabilityTag.eventDuration = duration
    }
    if (req?.file || JSON.parse(isImageDelete)) {
      try {
        openAvailabilityTag?.image && fs.unlinkSync(`./public/images/profilePictures/${openAvailabilityTag?.image}`);
      }
      catch(err) {
        console.log('Error in deleting existing tag image')
      }
      openAvailabilityTag.image = req.file?.filename ? req?.file?.filename : null
    }
    await openAvailabilityTag.save();
    if(Array.isArray(membersAddedByAdmin)) {
      await openAvailabilityTag.setTagMembers(membersAddedByAdmin)
    }
    if(Array.isArray(questions)) {
        await db.open_availability_tag_question.destroy({where: {openAvailabilityTagId:  openAvailabilityTag.id}})
        let questionData = questions.map(i => ({openAvailabilityTagId: openAvailabilityTag.id, questionId: i.questionId, required: i.required}))
        await db.open_availability_tag_question.bulkCreate(questionData)
    }
    else {
        await db.open_availability_tag_question.destroy({where: {openAvailabilityTagId:  openAvailabilityTag.id}})
    }
    res.status(201).json({ success: true, message: 'Tag Edited Successfully' });
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};
 
exports.deleteOpenAvailabilityTag = async (req, res) => {
  try {
    const { id } = req.body;
    const openAvailabilityTag = await db.open_availability_tags.findByPk(id)
    openAvailabilityTag.isDeleted = true;
    await openAvailabilityTag.save()
    res.status(201).json({ success: true, message: 'Tag Deleted Successfully'  });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}
exports.restoreOpenAvailabilityTag = async (req, res) => {
  try {
    const { id } = req.body;
    const openAvailabilityTag = await db.open_availability_tags.findByPk(id)
    openAvailabilityTag.isDeleted = null;
    await openAvailabilityTag.save()
    res.status(201).json({ success: true, message: 'Tag Restored Successfully'  });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.changePassword = async (req, res) => {
  try {
      const { oldPassword, password, confirmPassword } = req.body
      if (password !== confirmPassword) {
          throw { statusCode: 400, message: "Password and confirmed passwords do not match." };
      }
      const userId = req.user.userId
      const user = await db.user.findByPk(userId,{
          include: {
              model: db.user_type, as: 'usertype'
          },
      });
      if (!user) {
          throw { statusCode: 404, error: true, message: 'User not found' };
      }
   
      const hashedPassword = await hashPassword(password)
      const isOldPasswordCorrect = await comparePassword(oldPassword, user.password);
      if (!isOldPasswordCorrect) {
        throw { statusCode: 400, error: true, message: 'Old password is incorrect' };
      }
      const isSameAsLastPassword = await comparePassword(password, user.password)
      if (isSameAsLastPassword) {
          throw { statusCode: 400, error: true, message: 'Password can not be same as Last password' };
      }
      const [updatedRowsCount, [updatedUser]] = await db.user.update({ password: hashedPassword, isPasswordUpdated: true, passwordUpdatedCount: user.passwordUpdatedCount + 1 }, { where: { id: userId }, returning: true });
 
      if (updatedRowsCount === 0) {
          throw { statusCode: 404, error: true, message: 'User not found' };
      }
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
      return res.status(201).json({ success: true, message: 'Password Changed Successfully'});
 
     }
  catch (error) {
      return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.AddPhoneNumbers = async (req, res) => {
  try {
    const { phone, countryCode, primaryNumber } = req.body
    const user = await db.user.findByPk(req.user.userId);
    if (!user) {
      throw { statusCode: 404, message: 'User not found' }
    }
    if (phone && countryCode) {
      let tempVar = true;
      const fields = ['phonenumber','phonenumber2','phonenumber3','phonenumber4','phonenumber5',]
      fields.forEach((key) => {
        if(user[key] === phone && user[`${key}CountryCode`] === countryCode){
          throw { statusCode: 409, message: "Phone number is already exist" }
        }
        if(tempVar && user[key] === null && user[`${key}CountryCode`] === null) {
        user[key] = phone;
        user[`${key}CountryCode`] = countryCode;
        if(!user?.primaryPhonenumber){         // first phone number will be primary
          user.primaryPhonenumber = `${countryCode} ${phone}`;
        }
        tempVar = false
        }
      })
    }
    else if (primaryNumber && countryCode) {
      user.primaryPhonenumber = `${countryCode} ${primaryNumber}`;  
    }
 
    await user.save();
    return res.status(200).json({ success: true, message: 'User Phone Number Updated Successfully!!!' });
  } catch (error) {
    return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}
exports.updateExistingBookedOpenAvailability = async (req, res) => {
  try {
    const { id, dateTimeSlot, title, text, endtime } = req.body;
    // const givenDateTime = new Date(dateTimeSlot)
    // const currentDateTime = new Date()
    // if (givenDateTime.getTime() < currentDateTime.getTime()) {
    //   throw {statusCode: 400, message: "Please give future time only"}
    // }
    const user = await db.user.findByPk(req.user.userId)
   
    const exactSlotResponse = await db.open_availability.findOne({
      where:{id: id},
      attributes:['datetime','booked','emailServiceProvider','senderEmail', 'meetingLink', 'eventId'],
    //   include: [{
    //   model: db.event,
    //   as: 'events',
    //   required: false,
    //   attributes: ['eventId','title'],
    //   duplicating: false,
    //   where: db.sequelize.literal(
    //     '"events"."updatedAt" = (SELECT MAX("updatedAt") FROM "events" AS "events2" WHERE "events2"."eventId" = "events"."eventId")'
    //   )
    // }],
    raw: true
    })
    // const meetingLink = exactSlotResponse?.meetingLink
    
    // const event = await dbviews.event_merge_calendar_view.findOne({where:{meetingLink:meetingLink}, attributes: ['eventId','title'],})
    
    if((dateTimeSlot == exactSlotResponse.datetime) && !exactSlotResponse.booked){
      return res.status(400).json({ message: 'Slot time is the same as previous datetime', success: false });
    }
    // if((dateTimeSlot == exactSlotResponse.datetime) && title == exactSlotResponse["title"] && exactSlotResponse.booked){
    //   return res.status(400).json({ message: 'No Changes provided', success: false });
    // }
   
    const slotsResponse = await db.open_availability.findAll({ where: { userId: req.user.userId,
      id: { [db.Sequelize.Op.ne]: id }  },
      attributes: ['datetime'] ,raw: true});
    const dateTimeSlotsResponse = slotsResponse.map((item) => item.datetime);
   
    const isExactDuplicate = dateTimeSlotsResponse.includes(dateTimeSlot);
    if (isExactDuplicate) {
      return res.status(400).json({ message: 'Slot time is the same as an existing slot', success: false });
    }
 
    // const isInvalidSlot = dateTimeSlotsResponse.some(existingDateTime => {
    //   const slotDiff = Math.abs(new Date(dateTimeSlot).getTime() - new Date(existingDateTime).getTime());
    //   return slotDiff < 30 * 60 * 1000;
    // });
 
    // if (isInvalidSlot) {
    //   return res.status(400).json({ message: 'Slot time is less than 30 minutes of existing slot', success: false });
    // }
    if(exactSlotResponse.booked){
      const eventId = exactSlotResponse["eventId"];
      const senderEmail = exactSlotResponse.senderEmail;
 
      let accessToken, refreshToken;
   
      if (senderEmail === user.email) {
        accessToken = user.emailAccessToken;
        refreshToken = user.emailRefreshToken;
      } else if (senderEmail === user.email2) {
        accessToken = user.email2AccessToken;
        refreshToken = user.email2RefreshToken;
      } else if (senderEmail === user.email3) {
        accessToken = user.email3AccessToken;
        refreshToken = user.email3RefreshToken;
      }
   
      if (exactSlotResponse.emailServiceProvider === 'google') {
        await updateGoogleEvent(accessToken, refreshToken, eventId, '', dateTimeSlot, endtime, null, text);
      } else if (exactSlotResponse.emailServiceProvider === 'microsoft') {
        await updateMicrosoftEvent(accessToken, refreshToken, eventId, '', dateTimeSlot, req.user.userId,endtime,null,null,text);
      }
      await db.open_availability.update({ datetime: dateTimeSlot, title, endtime, isBookedSlotUpdated: true, isAcceptedByOwner: true }, { where: { id: id } });
      // const failedEmails = await fetchEventsForAllEmails(user)
      return res.status(200).json({ message: 'Slot updated Successfully', success: true });
    }
    else {
      return res.status(404).json({ message: 'This event is already deleted', success: true });
    }
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};


exports.getTimezones = async (req, res) => {
  try {
    const data = await db.timezone.findAll({})
    return res.status(200).json({success: true, data: data});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.updateOrCreatePersonalityTraits = async (req, res) => {
  try {
    const sliderValues  = req.body;
    const existingUserTrait = await db.user_personality_trait.findOne({ where: { userId: req.user.userId } });
    if (existingUserTrait) {
      await existingUserTrait.update(sliderValues);
    } else {
      await db.user_personality_trait.create({ userId:req.user.userId, ...sliderValues });
    }
    return res.status(200).json({success: true, messgae: 'User Personality Traits Updated Successfully'});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getLocation = async (req, res) => {
  try {
    const response = await db.location.findAll();
    return res.status(200).json({ success: true, data: response });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}
exports.getOrganization = async (req, res) => {
  try {
    const organizationResponse = await db.organization.findAll();
    const { rows: suggestedOrganizationResponse, count: organizationSuggestedCount }   = await db.userSuggestedOrganization.findAndCountAll({
      where: {
        userId: req.user.userId,
      },
    });
    
    const existingOrganizations = Array.isArray(organizationResponse) ? organizationResponse : [];
    const suggestedOrganizations = Array.isArray(suggestedOrganizationResponse) 
      ? suggestedOrganizationResponse.map(inst => inst.dataValues) 
      : [];

    const updatedOrganizationData = suggestedOrganizations.map((item) => ({
      id: item.id,
      organization: item.organizationName,
      isUserSuggested: true, // Adding flag to indicate user-suggested organizations
    }));
    const combinedData = [
      ...existingOrganizations.map((inst) => ({
        id: inst.id,
        organization: inst.organization,
        isUserSuggested: false, // Existing organizations are not user-suggested
      })),
      ...updatedOrganizationData,
    ];

    return res.status(200).json({ success: true, data: combinedData, organizationSuggestedCount });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}
exports.getDesignation = async (req, res) => {
  try {
    const designationResponse = await db.designation.findAll();

    const { rows: suggestedDesignationResponse, count: designationSuggestedCount }   = await db.userSuggestedDesignation.findAndCountAll({
      where: {
        userId: req.user.userId,
      },
    });
    
    const existingDesignations = Array.isArray(designationResponse) ? designationResponse : [];

    const suggestedDesignations = Array.isArray(suggestedDesignationResponse) 
      ? suggestedDesignationResponse.map(inst => inst.dataValues) 
      : [];

    const updatedDesignationsData = suggestedDesignations.map((item) => ({
      id: item.id,
      designation: item.designation,
      isUserSuggested: true, 
    }));

    const combinedData = [
      ...existingDesignations.map((inst) => ({
        id: inst.id,
        designation: inst.designation,
        isUserSuggested: false, 
      })),
      ...updatedDesignationsData,
    ];

    return res.status(200).json({ success: true, data: combinedData , designationSuggestedCount });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.updateTheme = async (req, res) => {
  try {
    const {newTheme}  = req.body;
    await db.user.update({ theme: newTheme }, { where: { id: req.user.userId } });
    return res.status(200).json({success: true, theme: newTheme});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.createNewEvent = async (req, res) => {
  try {
    const userId = req.user.userId;
    let {title, startDateTime, endDateTime, requiredGuests, optionalGuests, email, template, predefinedEventId, eventTime, meetType, eventTypeId, url, passcode, phone, location, address, timezone, hideGuestList, recurrence, recurrenceRepeat, recurrenceEndDate, recurrenceDays,recurrenceCount, recurrenceNeverEnds,  descriptionCheck, emailCheck} = req.body
    const user = await db.user.findByPk(userId,{
      include: {
        model: db.organization,
        as: 'organization'
      }
    });
    // const failedEmails = await fetchEventsForAllEmails(user)
    // if (failedEmails.length > 0) {
    //   return res.status(400).json({ error: true, message: `Failed to check duplicates as Events could not be fetched for emails-`, failedEmails: failedEmails });
    // }
    const isEventExist = await dbviews.event_merge_calendar_view.findOne({
      where: {
        userId: userId,
        [db.Sequelize.Op.or]: [
            {
                startTime: {
                    [db.Sequelize.Op.lt]: startDateTime  //Checks if the event's startTime is equal to the provided startdatetime
                },
                endTime: {
                    [db.Sequelize.Op.gt]: startDateTime  //Checks if the event's endTime is equal to the provided startdatetime
                }
            },
            {
                startTime: {
                    [db.Sequelize.Op.lt]: endDateTime    //Checks if the event's startTime is equal to the provided enddatetime
                },
                endTime: {
                    [db.Sequelize.Op.gt]: endDateTime    //Checks if the event's endTime is equal to the provided enddatetime
                }
            },
            {
              startTime: {
                  [db.Sequelize.Op.gte]: startDateTime    //Checks if the event's startTime is greater than or equal to the provided startdatetime
              },
              endTime: {
                  [db.Sequelize.Op.lte]: endDateTime      //Checks if the event's endTime is less than or equal to the provided enddatetime 
              }
            }
        ],
      }
    })
    if(isEventExist) throw { statusCode: 409, message: 'Event already exist for the given time range'}
    let emailServiceProvider ,accessToken, refreshToken, meetingLink, eventId, googleResponse, microsoftResponse
      if (email === user.email) {
        accessToken = user.emailAccessToken
        refreshToken = user.emailRefreshToken
        emailServiceProvider = user.emailServiceProvider
      }
      else if (email === user.email2) {
        accessToken = user.email2AccessToken
        refreshToken = user.email2RefreshToken
        emailServiceProvider = user.email2ServiceProvider
      }
      else if (email === user.email3) {
        accessToken = user.email3AccessToken
        refreshToken = user.email3RefreshToken
        emailServiceProvider = user.email3ServiceProvider
      }
      if(!accessToken && !refreshToken && !emailServiceProvider) {
        return res.status(400).json({ error: true, message: `You have not synced your email - You can't create event` });
      }
      const emailSignature = await db.user_email_signature.findOne({where:{userId:userId}, include:[{model: db.organization},]})
 
      const variables = {
        date: dayjs(startDateTime).tz(timezone).format("DD/MM/YYYY"), 
        time: dayjs(startDateTime).tz(timezone).format("h:mm A"),
        name: 'User',
        eventProvider: emailSignature?.fullname || '',
        location: meetingLink,
        organization: emailSignature?.organization?.organization || '',
        contact: emailSignature?.phonenumber || '',
        website: emailSignature?.website,
        url, 
        passcode, 
        phone, 
        location, 
        address,
        timezone
      }
      const attendees = [...requiredGuests, ...optionalGuests]
      const subject = 'Event Created!'
      const content = template?.replace(/\${(.*?)}/g, (_, key) => variables[key.trim()]);
      
      if (emailServiceProvider === 'google') {
        const requiredAttendeesForGoogle = requiredGuests.map((guest) => ({email: guest, comment: "Required"}))
        const optionalAttendeesForGoogle = optionalGuests?.map((guest) => ({email: guest, comment: "Optional"})) || []
        const attendeesForGoogle = [...requiredAttendeesForGoogle, ...optionalAttendeesForGoogle]
        if(recurrence) {
          const initialStartDateTime = startDateTime;
          const initialEndDateTime = endDateTime;
          function setDateToSelectedDayInSameWeek(dateString, targetDayName, addNextWeek) {  
            // Map of weekday names to day numbers (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
            const daysObject = {
                sunday: 0,
                monday: 1,
                tuesday: 2,
                wednesday: 3,
                thursday: 4,
                friday: 5,
                saturday: 6
            };
        
            const targetDayIndex = daysObject[targetDayName];        
            let date = addNextWeek ? dayjs(dateString).tz(timezone).add(1, 'week') : dayjs(dateString).tz(timezone);
            // Adjust the date to the target day within the same week
            return date.day(targetDayIndex).toISOString();
          }

          // startdate should be set to the first selected day - otherwise google will also create event for the startdate day
          for (const day of recurrenceDays) {
            startDateTime = setDateToSelectedDayInSameWeek(startDateTime, day.name)
            endDateTime = setDateToSelectedDayInSameWeek(endDateTime, day.name)
            if(dayjs(startDateTime).tz(timezone).isAfter(dayjs(initialStartDateTime).tz(timezone)) || dayjs(startDateTime).tz(timezone).isSame(dayjs(initialStartDateTime).tz(timezone))) {  // consider only future or current date
              break;
            }
          }
          
          if(dayjs(startDateTime).tz(timezone).isBefore(dayjs(initialStartDateTime).tz(timezone))) {  // consider only future date
            startDateTime = setDateToSelectedDayInSameWeek(initialStartDateTime, 'sunday', true)  // as week start from sunday in dayjs
            endDateTime = setDateToSelectedDayInSameWeek(initialEndDateTime, 'sunday', true)
          }          
          let recurrenceDaysArray = recurrenceDays?.map((item)=> item.googleValue).join(',')
          if(descriptionCheck){
            googleResponse = await createGoogleRecurringEvent(accessToken, refreshToken, startDateTime, attendeesForGoogle, title, endDateTime, url, recurrence, recurrenceRepeat, recurrenceEndDate, recurrenceDaysArray,recurrenceCount, recurrenceNeverEnds,hideGuestList, content, timezone)
          }else{
            googleResponse = await createGoogleRecurringEvent(accessToken, refreshToken, startDateTime, attendeesForGoogle, title, endDateTime, url, recurrence, recurrenceRepeat, recurrenceEndDate, recurrenceDaysArray,recurrenceCount, recurrenceNeverEnds, hideGuestList, null, timezone )
          }
        }
        else {
           if(descriptionCheck){
            googleResponse = await sendGoogleEvent(accessToken, refreshToken, startDateTime, attendeesForGoogle, title, endDateTime, url, hideGuestList, hideGuestList, content)
           }else{
            googleResponse = await sendGoogleEvent(accessToken, refreshToken, startDateTime, attendeesForGoogle, title, endDateTime, url, hideGuestList )
          }
        }
        meetingLink = googleResponse?.meetingLink
        eventId = googleResponse?.eventId
      }  
    else if (emailServiceProvider === "microsoft") {
        const requiredAttendeesForMicrosoft = requiredGuests.map((guest) => ({ emailAddress: { address: guest }, type: "required" }))
        const optionalAttendeesForMicrosoft = optionalGuests?.map((guest) => ({ emailAddress: { address: guest }, type: "optional" })) || []
        const attendeesForMicrosoft = [...requiredAttendeesForMicrosoft, ...optionalAttendeesForMicrosoft]
        if(recurrence) {
          let recurrenceDaysArray = recurrenceDays?.map((item)=> item.microsoftValue)
          if(descriptionCheck){
            microsoftResponse = await createMicrosoftRecurringEvent(accessToken, refreshToken, startDateTime, attendeesForMicrosoft, userId, email, title, endDateTime, url, recurrence, recurrenceRepeat, recurrenceEndDate, recurrenceDaysArray,recurrenceCount, recurrenceNeverEnds, hideGuestList, content, timezone)
          }else{
            microsoftResponse = await createMicrosoftRecurringEvent(accessToken, refreshToken, startDateTime, attendeesForMicrosoft, userId, email, title, endDateTime, url, recurrence, recurrenceRepeat, recurrenceEndDate, recurrenceDaysArray,recurrenceCount, recurrenceNeverEnds, hideGuestList, null, timezone)
          }
        }
        else {
          if(descriptionCheck){
            microsoftResponse = await sendMicrosoftEvent(accessToken, refreshToken, startDateTime, attendeesForMicrosoft, userId, email, title, endDateTime, url, hideGuestList, content)
          }else{
            microsoftResponse = await sendMicrosoftEvent(accessToken, refreshToken, startDateTime, attendeesForMicrosoft, userId, email, title, endDateTime, url, hideGuestList)
          }      
        }
        meetingLink = microsoftResponse?.meetingLink
        eventId = microsoftResponse?.eventId
      }
      // const template = await db.general_template.findByPk(templateId)

      const combinedAttendees = [...requiredGuests, ...optionalGuests];
      const attendeesString = combinedAttendees.join(', ');
      const entry = {
        userId: userId,
        startTime: startDateTime,
        endTime: endDateTime,
        title: title,
        senderEmail: email,
        attendees: attendeesString,
        meetingLink: meetingLink,
        eventId: eventId,
        eventDurationInMinutes: eventTime,
        eventTypeId: eventTypeId,
        emailTemplate: template,
        meetType
      }
      await db.event_hub_events.create(entry)
  
      if(emailCheck){
        sendNotification(attendees, subject, content, null, email, hideGuestList)  // without await - dont want async programming here
      }
      if(predefinedEventId) {
       const predefinedEvent =  await db.predefined_event.findByPk(predefinedEventId);
       predefinedEvent.count = predefinedEvent.count + 1
       await predefinedEvent.save()
      }
      return res.status(200).json({success: true, message: 'Event Created Successfully'});

  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.deletePhoneNumber = async (req, res) => {
  try {
    const { phone, countryCode } = req.body;
    const user = await db.user.findByPk(req.user.userId);
    if (!user) {
      throw { statusCode: 404, message: 'User not found' };
    }
    const fields = ['phonenumber','phonenumber2','phonenumber3','phonenumber4','phonenumber5',]
    fields.forEach((key) => {
      if(user[key] === phone && user[`${key}CountryCode`] === countryCode){
        user[key] = null;
        user[`${key}CountryCode`] = null;
      }
    })
    await user.save();
    return res.status(200).json({success: true, message: 'Phone number deleted Successfully'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.addAboutMeText = async (req, res) => {
  try {
    const { aboutMeText } = req.body;
    const user = await db.user.findByPk(req.user.userId);
    user.aboutMeText = aboutMeText;
    await user.save();
    return res.status(201).json({success: true, message: 'About me Text added successfully'});
  } catch (error) {
    return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.notificationSettings = async (req, res) => {
  try {
    const { isDisabled } = req.body;
    const user = await db.user.findByPk(req.user.userId);
    user.isNotificationDisabled = isDisabled;
    await user.save();
    return res.status(201).json({success: true, message: 'Updated'});
  } catch (error) {
    return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getEducationDetails = async (req, res) => {
  try {
    const response = await db.education_details.findAll({
      where: {
        userId: req.user.userId
      },
      include:[
        {
          model: db.institution,
          as: 'education_detailsInstitution',
        },
        {
          model: db.course,
          as: 'education_detailsCourse',
        },
        {
          model: db.fieldOfStudy,
          as: 'education_detailsFieldOfStudy',
        },
        {
          model: db.educationLevel,
          as: 'education_detailsEducationLevel',
        },
        {
          model: db.userSuggestedInstitution,
          as: 'education_detailsUserSuggestedInsitution',
        },
        {
          model: db.userSuggestedCourse,
          as: 'education_detailsUserSuggestedCourse',
        },
        ]
    });

    return res.status(200).json({ success: true, data: response });

  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.addEducationDetails = async (req, res) => {
  try {
    const { institutionId, courseId, fieldOfStudy, educationLevel, suggestInstitute, suggestCourse, startDate, endDate, isCurrentlyPursuing } = req.body;
    const educationDetailsData = {
      startDate,
      endDate,
      isCurrentlyPursuing,
      userId: req.user.userId
    };
    
    if(institutionId){
      educationDetailsData.institutionId = institutionId
    }else if(suggestInstitute?.isUserSuggested){
      educationDetailsData.userSuggestedInstitutionId = suggestInstitute.id
    }else if(suggestInstitute){
      const suggestedInstitution = await db.userSuggestedInstitution.create({
        institutionName: suggestInstitute.institutionName,
        userId: req.user.userId,
        website: suggestInstitute.website,
        cityId: suggestInstitute.city.id,
        stateId: suggestInstitute.state.id,
        countryId: suggestInstitute.country.id
      })
      educationDetailsData.userSuggestedInstitutionId = suggestedInstitution.id
    }
    if(fieldOfStudy){
      educationDetailsData.courseId = courseId
      educationDetailsData.educationLevelId = educationLevel
      educationDetailsData.fieldOfStudyId = fieldOfStudy
    }else if(suggestCourse?.isUserSuggested){
      educationDetailsData.userSuggestedCourseId = suggestCourse.id
    }else if(suggestCourse){
      const suggestedCourse = await db.userSuggestedCourse.create({
        course: suggestCourse.degree.id,
        userId: req.user.userId,
        fieldOfStudy: suggestCourse.studyField,
        educationLevelId: suggestCourse.level.id
      })
      educationDetailsData.userSuggestedCourseId = suggestedCourse.id
    }
    await db.education_details.create(educationDetailsData);
    res.status(201).json({ success: true, message: 'Education Details added successfully' });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.deleteEducationDetails = async (req, res) => {
  try {
    const rowId = req.body;
    const educationDetail = await db.education_details.findByPk(rowId.id);
    if (!educationDetail) {
      return res.status(404).json({ error: "Education detail not found" });
    }
      // if(educationDetail.userSuggestedInstitutionId){
      //   const userSuggestedInstitution = await db.userSuggestedInstitution.findByPk(educationDetail.userSuggestedInstitutionId)
      //   await userSuggestedInstitution.destroy()
      // }
      // if(educationDetail.userSuggestedCourseId){
      //   const userSuggestedCourse = await db.userSuggestedCourse.findByPk(educationDetail.userSuggestedCourseId)
      //   await userSuggestedCourse.destroy()
      // }

    await educationDetail.destroy();
    res.status(200).json({ message: "Education detail deleted successfully" });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.editEducationDetails = async (req, res) => {
  try {
    const { id, institutionId, courseId, educationLevel, fieldOfStudy, suggestInstitute, suggestCourse, startDate, endDate, isCurrentlyPursuing, userId } = req.body;

    const educationDetail = await db.education_details.findByPk(id);

    if (!educationDetail) {
      return res.status(404).json({ error: "Education detail not found" });
    }

    educationDetail.institutionId = institutionId;

    educationDetail.courseId = courseId;

    educationDetail.educationLevelId = educationLevel;

    educationDetail.fieldOfStudyId = fieldOfStudy

    if(suggestInstitute){
      educationDetail.userSuggestedInstitutionId = suggestInstitute
    }

    if(suggestCourse){
      educationDetail.userSuggestedCourseId = suggestCourse
    }

    educationDetail.startDate = startDate;
    educationDetail.endDate = endDate;
    educationDetail.isCurrentlyPursuing = isCurrentlyPursuing;
    educationDetail.userId = userId;

    await educationDetail.save();

    res.status(200).json({ success: true, message: 'Details edited successfully' });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.getExperienceDetails = async (req, res) => {
  try {
    const response = await db.experience_details.findAll({
      where: {
        userId: req.user.userId
      },
      include:[
      {
        model: db.designation,
        as: 'experience_detailsDesignation',
      },
      {
        model: db.organization,
        as: 'experience_detailsOrganization',
      },
      {
        model: db.userSuggestedDesignation,
        as: 'experience_detailsUserSuggestedDesignation',
      },
      {
        model: db.userSuggestedOrganization,
        as: 'experience_detailsUserSuggestedOrganization',
        include: [
          {
            model: db.cities,  
          },
          {
            model: db.countries,  
          },
        ]
      },
      ]
    });

    return res.status(200).json({ success: true, data: response });

  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.addExperienceDetails = async (req, res) => {
  try {
    const { organizationId, designationId, website, linkedinUrl, city, country, suggestCompany, suggestDesignation, startDate, endDate, isCurrent } = req.body;
    const experienceDetailsData = {
      startDate,
      endDate,
      isCurrent,
      userId: req.user.userId
    };
  
    if(organizationId){
      experienceDetailsData.organizationId = organizationId
    }else if(suggestCompany?.isUserSuggested){
      experienceDetailsData.userSuggestedOrganizationId = suggestCompany.id
    }else if(suggestCompany){
      const organizationData = {
        organizationName: suggestCompany.suggestCompanyName,
        userId: req.user.userId,
        website: suggestCompany.website,
        countryId: suggestCompany.country.id
      }
      if(suggestCompany.linkedinUrl){
        organizationData.linkedinUrl = suggestCompany.linkedinUrl
      }
      if(suggestCompany.state){
        organizationData.stateId = suggestCompany.state.id
      }
      if(suggestCompany.city){
        organizationData.cityId = suggestCompany.city.id
      }
      const companyName = await db.userSuggestedOrganization.create(organizationData)
      experienceDetailsData.userSuggestedOrganizationId = companyName.id
    }
    if(designationId){
      experienceDetailsData.designationId = designationId
    }else if(suggestDesignation?.isUserSuggested){
      experienceDetailsData.userSuggestedDesignationId = suggestDesignation.id
    }else if(suggestDesignation){
      const suggestedCourse = await db.userSuggestedDesignation.create({
        designation: suggestDesignation.suggestDesignation,
        userId: req.user.userId
      })
      experienceDetailsData.userSuggestedDesignationId = suggestedCourse.id
    }
    await db.experience_details.create(experienceDetailsData);
    res.status(201).json({ success: true, message: 'Experience Details added successfully' });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.deleteExperienceDetails = async (req, res) => {
  try {
    const rowId = req.body;
    const experienceDetail = await db.experience_details.findByPk(rowId.id);
    if (!experienceDetail) {
      return res.status(404).json({ error: "Experience detail not found" });
    }
    // if(experienceDetail.userSuggestedOrganizationId){
    //   const userSuggestedOrganization = await db.userSuggestedOrganization.findByPk(experienceDetail.userSuggestedOrganizationId)
    //   await userSuggestedOrganization.destroy()
    // }
    // if(experienceDetail.userSuggestedDesignationId){
    //   const userSuggestedDesignation = await db.userSuggestedDesignation.findByPk(experienceDetail.userSuggestedDesignationId)
    //   await userSuggestedDesignation.destroy()
    // }
    await experienceDetail.destroy();
    res.status(200).json({ message: "Experience detail deleted successfully" });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.editExperienceDetails = async (req, res) => {
  try {
    const { id, organizationId, designationId, suggestCompanyName, suggestDesignation, startDate, endDate, isCurrent, userId } = req.body;

    const experienceDetail = await db.experience_details.findByPk(id);

    if (!experienceDetail) {
      return res.status(404).json({ error: "Experience detail not found" });
    }
    experienceDetail.organizationId = organizationId
    experienceDetail.designationId = designationId
    if(suggestCompanyName){
      experienceDetail.userSuggestedOrganizationId = suggestCompanyName
    }
 
    if(suggestDesignation){
      experienceDetail.userSuggestedDesignationId = suggestDesignation
    }

    experienceDetail.startDate = startDate;
    experienceDetail.endDate = endDate;
    experienceDetail.isCurrent = isCurrent;
    experienceDetail.userId = userId;

    await experienceDetail.save();

    res.status(200).json({ success: true, message: 'Details edited successfully' });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};


exports.addSecondaryEmail = async (req, res) => {
  try {
    let { email2, email3 } = req.body;
    const user = await db.user.findByPk(req.user.userId);
    
    if (!user) {
      throw { statusCode: 404, message: 'User not found' };
    }

    const ClientUrl = req.headers.origin;
    let key = crypto.randomBytes(40).toString('hex');
    const content = `Click on below link to verify your account <br/> <a href=${ClientUrl}/verify-account/${user.id}/${key}>${ClientUrl}/verify-account/${user.id}/${key}</a>`
    if(email2 == user.email || email3 == user.email){
      throw { statusCode: 400, message: 'Primary email cant be used as secondary email' };
    }
    if (email2) {
      if (user.email2 === email2 || user.email3 === email2) {
        throw { statusCode: 400, message: 'This Secondary Email is already linked with the user account' };
      }
      await db.user_verification.create({ email: email2, accountVerifyKey: key, userId: user.id });
      sendNotification(email2, 'Verify Your account', content);
      user.email2 = email2
    }else if (email3) {
      if (user.email2 === email3 || user.email3 === email3) {
        throw { statusCode: 400, message: 'This Secondary Email is already linked with the user account' };
      }
      await db.user_verification.create({ email: email3, accountVerifyKey: key, userId: user.id });
      sendNotification(email3, 'Verify Your account', content);
      user.email3 = email3
    }
    user.save();
    // console.log("true")
    return res.status(200).json({ success: true, message: 'Verification emails sent. Please verify to update your account.' });
  } catch (error) {
    return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};


exports.deleteSecondaryEmail = async (req, res) => {
  try {
    let {email2, email3} = req.body; 
    const userId = req.user.userId;
    const user = await db.user.findByPk(userId);
    if (!user) {
      throw { statusCode: 404, message: 'User not found' }
    }
      if(email2 == null && email3 === undefined){
        if(user.email2ServiceProvider === 'google') {
          user.googleResourceIdEmail2 = null
          user.googleChannelIdEmail2 = null
          user.googleWatchExpirationEmail2 = null
        }
        else if (user.email2ServiceProvider === 'microsoft') {
          user.microsoftSubscriptionIdEmail2 = null;
          user.microsoftSubscriptionExpirationEmail2 = null;
        }
        user.email2ServiceProvider = null
        user.email2AccessToken = null 
        user.email2RefreshToken = null
        user.nextSyncTokenForEmail2 = null
        user.email2SyncTimeStamp = null
        user.firstTimeEmail2SyncTimeStamp = null
        user.email2SyncExpiration = null
        await db.user_verification.destroy({where: {email: user.email2, userId}})
        await db.event.destroy({where: {userId, emailAccount: user.email2}})
        await db.open_availability_tags.destroy({where: {defaultEmail: user.email2, userId}})
        await db.event_draft.destroy({where: {senderEmail: user.email2, userId}})
        await db.predefined_event.destroy({where: {senderEmail: user.email2, userId}})
        await db.open_availability.destroy({where: {userId, senderEmail: user.email2}})
        await db.notification.destroy({where: {userId, emailAccount: user.email2}}) 
        user.email2 = null
      } 
      else if (email3 == null && email2 === undefined){
        if(user.email3ServiceProvider === 'google') {
          user.googleResourceIdEmail3 = null
          user.googleChannelIdEmail3 = null
          user.googleWatchExpirationEmail3 = null
        }
        else if (user.email3ServiceProvider === 'microsoft') {
          user.microsoftSubscriptionIdEmail3 = null;
          user.microsoftSubscriptionExpirationEmail3 = null;
        }
        user.email3ServiceProvider = null
        user.email3AccessToken = null 
        user.email3RefreshToken = null  
        user.nextSyncTokenForEmail3 = null
        user.email3SyncTimeStamp = null
        user.firstTimeEmail3SyncTimeStamp = null
        user.email3SyncExpiration = null
        await db.user_verification.destroy({where: {email: user.email3, userId}})
        await db.event.destroy({where: {userId, emailAccount: user.email3}})
        await db.open_availability_tags.destroy({where: {defaultEmail: user.email3, userId}})
        await db.event_draft.destroy({where: {senderEmail: user.email3, userId}})
        await db.predefined_event.destroy({where: {senderEmail: user.email3, userId}})
        await db.open_availability.destroy({where: {userId, senderEmail: user.email3}})
        await db.notification.destroy({where: {userId, emailAccount: user.email3}})
        user.email3 = null
      }
    await user.save();
    return res.status(200).json({ success: true, message: 'Secondary Email Deleted Successfully!!!' });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.getCourse = async (req, res) => {
  try {
    const response = await db.course.findAll();
    return res.status(200).json({ success: true, data: response });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getInstitution = async (req, res) => {
  try {
    // Fetch existing institutions
    const institutionResponse = await db.institution.findAll();

    // Fetch user-suggested institutions
    const { rows: suggestedInstitutionResponse, count: institutionSuggestedCount } = await db.userSuggestedInstitution.findAndCountAll({
      where: {
        userId: req.user.userId,
      },
    });

    // Ensure institutionResponse is an array
    const existingInstitutions = Array.isArray(institutionResponse) ? institutionResponse : [];

    // Ensure suggestedInstitutionResponse is an array and extract dataValues
    const suggestedInstitutions = Array.isArray(suggestedInstitutionResponse) 
      ? suggestedInstitutionResponse.map(inst => inst.dataValues) 
      : [];

    // Map suggested institutions to the required format
    const updatedInstitutionData = suggestedInstitutions.map((item) => ({
      id: item.id,
      institutionName: item.institutionName,
      isUserSuggested: true, // Adding flag to indicate user-suggested institutions
    }));

    // Combine existing institutions with updated institution data
    const combinedData = [
      ...existingInstitutions.map((inst) => ({
        id: inst.id,
        institutionName: inst.institutionName,
        isUserSuggested: false, // Existing institutions are not user-suggested
      })),
      ...updatedInstitutionData,
    ];

    // Send response with combined data
    return res.status(200).json({ success: true, data: combinedData, institutionSuggestedCount });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.getAllUserList = async (req, res) => {
  try {
    const users = await db.user.findAll({
      where: {
        id: { [db.Sequelize.Op.ne]: req.user.userId },
        isDeleted: null
      }, 
      attributes: ['id', 'fullname', 'email']
    });
    return res.status(200).json({ success: true, data: users});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
} 

exports.createGroup = async (req, res) => {
  try {
    const {name, members, addMe, description, adminName} = req.body;
    const userId = req.user.userId;
    const groups = await db.group.findAll({where: {createdBy:userId}})
    if(groups.length === 10) {
      throw {statusCode: 400, message: 'You can save maximum 10 Groups'}
    }

    const existingGroup = await db.group.findOne({where:{name: {[db.Sequelize.Op.iLike]: name}, createdBy: userId}})
    if (existingGroup) {
      throw { statusCode: 400, message: 'Group with the same name already exists' }
    }

    if (members.length > 50) {
      throw { statusCode: 400, message: 'Group member limit exceeded. A group can have a maximum of 50 members.' };
    }

    const memberIds = members.map(i => i.id).filter((item) => item)
    const manuallyAddedMembers = members?.filter(i => !i.hasOwnProperty('id')).map((j) => ({...j, userId})) || []
    if(manuallyAddedMembers.length > 0) {
      for (const {userId, email} of manuallyAddedMembers) {
        const contact = await db.contact.findOne({where: { userId, email }});
        if(!contact) {  // if contact is not there then create
          const created = await db.contact.create({userId, email}, {returning: true})
          memberIds.push(created.id)
        }
        else {
          memberIds.push(contact.id)
        }
      }
    }

    // if(addMe) {
    //   memberIds.push(userId) // adding creator as a member in group
    // }
    
    const group = await db.group.create({name, createdBy: userId, createdAt: new Date().toISOString(), description, adminName, addMe})
    await group.setGroupMembers(memberIds)
    return res.status(201).json({ success: true, message: "Group Created Successfully"});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.groupListWithMembers = async (req, res) => {
  try {
    const groups = await db.group.findAndCountAll({
      where: {
        createdBy: req.user.userId
      },
      include: {
      model: db.contact,
      as: 'groupMembers',
      through: {attributes: []}
    }})
    return res.status(200).json({ success: true, data: groups.rows, count: groups.count});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.deleteGroup = async (req, res) => {
  try {
    const {groupIds} = req.body
    const group = await db.group.findByPk(groupIds[0]) // for instance to remove relation in group member table
    await db.group.destroy({where: {id: groupIds, createdBy: req.user.userId}});
    group && await group?.removeGroupMembers(groupIds);
    return res.status(200).json({ success: true, message: 'Group Deleted Successfully'});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.editGroup = async (req, res) => {
  try {
    const {id,name, members = [], description, adminName, addMe} = req.body
    const userId = req.user.userId;
    const existingGroup = await db.group.findOne({where:{name: {[db.Sequelize.Op.iLike]: name}, createdBy: userId, id: {
      [Op.ne]: id
    }}})
    if (existingGroup) {
      throw { statusCode: 400, message: 'Group with the same name already exists' }
    }
    
    if (members.length > 50) {
      throw { statusCode: 400, message: 'Group member limit exceeded. A group can have a maximum of 50 members.' };
    }
    
    const memberIds = members.map(i => i.id).filter((item) => item)
    const manuallyAddedMembers = members?.filter(i => !i.hasOwnProperty('id')).map((j) => ({...j, userId})) || []
    if(manuallyAddedMembers.length > 0) {
      for (const {userId, email} of manuallyAddedMembers) {
        const contact = await db.contact.findOne({where: { userId, email }});
        if(!contact) {  // if contact is not there then create
          const created = await db.contact.create({userId, email}, {returning: true})
          memberIds.push(created.id)
        }
        else {
          memberIds.push(contact.id)
        }
      }
    }
    
    const group = await db.group.findOne({where: {id, createdBy: userId}})
    group.name = name
    group.description = description;
    group.adminName = adminName;
    group.addMe = addMe;
    await group.save();
    await group.setGroupMembers(memberIds);
    return res.status(200).json({ success: true, message: 'Group Updated Successfully'});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.getCities = async (req, res) => {
  try {
    const { selectedState } = req.query;
    const whereClause = selectedState ? { stateId: selectedState.id } : {};

    const response = await db.cities.findAll({
      where: whereClause,
      // limit: 10
    });
    return res.status(200).json({ success: true, data: response });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getCountries = async (req, res) => {
  try {
    const response = await db.countries.findAll();
    return res.status(200).json({ success: true, data: response });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.readNotification = async (req, res) => {
  const {ids} = req.body;
  try {
    await db.notification.update({isRead: true}, {where: {id: ids}})
    return res.status(200).json({ success: true });
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.createGroupEvent = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {title, startDateTime, endDateTime, members = [], email,template } = req.body
    const user = await db.user.findByPk(userId,{
      include: {
        model: db.organization,
        as: 'organization'
      }
    });
    // const failedEmails = await fetchEventsForAllEmails(user)
    // if (failedEmails.length > 0) {
    //   return res.status(400).json({ error: true, message: `Failed to check duplicates as Events could not be fetched for emails-`, failedEmails: failedEmails });
    // }
    const isEventExist = await dbviews.event_merge_calendar_view.findOne({
      where: {
        userId: userId,
        [db.Sequelize.Op.or]: [
            {
                startTime: {
                    [db.Sequelize.Op.lt]: startDateTime  //Checks if the event's startTime is equal to the provided startdatetime
                },
                endTime: {
                    [db.Sequelize.Op.gt]: startDateTime  //Checks if the event's endTime is equal to the provided startdatetime
                }
            },
            {
                startTime: {
                    [db.Sequelize.Op.lt]: endDateTime    //Checks if the event's startTime is equal to the provided enddatetime
                },
                endTime: {
                    [db.Sequelize.Op.gt]: endDateTime    //Checks if the event's endTime is equal to the provided enddatetime
                }
            },
            {
              startTime: {
                  [db.Sequelize.Op.gte]: startDateTime    //Checks if the event's startTime is greater than or equal to the provided startdatetime
              },
              endTime: {
                  [db.Sequelize.Op.lte]: endDateTime      //Checks if the event's endTime is less than or equal to the provided enddatetime 
              }
            }
        ],
      }
    })
    if(isEventExist) throw { statusCode: 409, message: 'Event already exist for the given time range'}
    let emailServiceProvider ,accessToken, refreshToken, meetingLink;
      if (email === user.email) {
        accessToken = user.emailAccessToken
        refreshToken = user.emailRefreshToken
        emailServiceProvider = user.emailServiceProvider
      }
      else if (email === user.email2) {
        accessToken = user.email2AccessToken
        refreshToken = user.email2RefreshToken
        emailServiceProvider = user.email2ServiceProvider
      }
      else if (email === user.email3) {
        accessToken = user.email3AccessToken
        refreshToken = user.email3RefreshToken
        emailServiceProvider = user.email3ServiceProvider
      }
      if (emailServiceProvider === 'google') {
          const attendeesForGoogle = members?.map((item) => ({ email: item.email }))
          googleResponse = await sendGoogleEvent(accessToken, refreshToken, startDateTime, attendeesForGoogle, title, endDateTime)
          meetingLink = googleResponse?.meetingLink
        }  
      else if (emailServiceProvider === "microsoft") {
          const attendeesForMicrosoft = members?.map((item) => ({ emailAddress: { address: item.email } }))
          microsoftResponse = await sendMicrosoftEvent(accessToken, refreshToken, startDateTime, attendeesForMicrosoft, userId, email, title, endDateTime)
          meetingLink = microsoftResponse?.meetingLink
        }
      // const template = await db.general_template.findByPk(templateId)
      const variables = {
        date: dayjs(startDateTime).format("DD/MM/YYYY"), 
        time: dayjs(startDateTime).format("h:mm A"),
        name: 'User',
        eventProvider: user.fullname || '',
        location: meetingLink,
        organization: user?.organization?.organization || '',
        contact: user.primaryPhonenumber || '',
        website: 'http://website'
      }
      const subject = 'Group Event Created'
      const content = template.replace(/\${(.*?)}/g, (_, key) => variables[key.trim()]);
      const memberEmails = members.map((item)=> item.email)
      sendNotification(memberEmails, subject, content)  // without await - dont want async programming here
      return res.status(200).json({success: true, message: 'Event Created Successfully'});

  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getGeneralTemplates = async (req, res) => {
  const {type} = req.query
  let whereClause = {}
  if(type) {
    whereClause['type'] = type
  }
  try {
    const templates = await db.general_template.findAll({
      where: whereClause,
      attributes:['id', 'name', 'template', 'type', 'predefinedMeetTypeId'], 
      raw: true
    });
    const userDefinedTemplate = await db.user_defined_email_template.findAll({
      where: {userId: req.user.userId, ...whereClause}, 
      raw: true
    })
    const generalTemplates = templates.map((item) => ({...item, group: 'General Templates'}))
    const userTemplates = userDefinedTemplate.map((item) => ({...item, group: "Your Templates"}))
    return res.status(200).json({success: true, data: [...generalTemplates, ...userTemplates]});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getPowerBIReport = async (req, res) => {
  try {
    const data = {
      grant_type: 'refresh_token',
      client_id: process.env.POWERBI_CLIENT_ID,
      scope: 'https://analysis.windows.net/powerbi/api/.default',
      refresh_token: process.env.POWERBI_REFRESH_TOKEN
    };
    const response = await axios.post(`https://login.microsoftonline.com/${process.env.POWERBI_TENANT_ID}/oauth2/v2.0/token`,new URLSearchParams(data), {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
    });
    const { access_token } = response.data;
    const groupId = process.env.POWERBI_GROUP_ID
    const reportData = await db.powerbi_report.findOne({where: {userTypeId: req.user.role}})
    const user = await db.user.findByPk(req.user.userId)
    const embedTokenResponse = await axios.post(`https://api.powerbi.com/v1.0/myorg/groups/${groupId}/reports/${reportData.reportId}/GenerateToken`, {},
      {
        headers: {
          Authorization: `Bearer ${access_token}`,
          'Content-Type': 'application/json'
        }
      }
    );
    const result = await axios.get(`https://api.powerbi.com/v1.0/myorg/reports/${reportData.reportId}`,{
      headers: {
        Authorization: `Bearer ${access_token}`,
        'Content-Type': 'application/json'
      }
    })
    res.status(200).json({
      accessToken: embedTokenResponse.data.token,
      embedUrl: result.data.embedUrl,
      reportId: reportData.reportId,
      username: user.username,
      parameters: reportData.parameters
    });
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getStates = async (req, res) => {
  try {
    const {selectedCountry} = req.query;
    // console.log(selectedCountry)
    const whereClause = selectedCountry ? { countryId: selectedCountry.id } : {};

    const response = await db.states.findAll({
      where: whereClause,
    });
    return res.status(200).json({ success: true, data: response });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getEducationLevel = async (req, res) => {
  try {
    const response = await db.educationLevel.findAll();
    return res.status(200).json({ success: true, data: response });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getFieldOfStudy = async (req, res) => {
  try {
    const fieldOfStudyResponse = await db.fieldOfStudy.findAll();
    const { rows: suggestedCourseResponse, count: courseSuggestedCount }  = await db.userSuggestedCourse.findAndCountAll({
      where: {
        userId: req.user.userId,
      },
    });
    const existingFieldOfStudy= Array.isArray(fieldOfStudyResponse) ? fieldOfStudyResponse : [];

    // Ensure suggestedCourseResponse is an array and extract dataValues
    const suggestedCourses = Array.isArray(suggestedCourseResponse)
      ? suggestedCourseResponse.map(course => course.dataValues)
      : [];

    const updatedCourseData = suggestedCourses.map((item) => ({
      id: item.id,
      name: item.fieldOfStudy,
      isUserSuggested: true, // Adding flag to indicate user-suggested courses
    }));
    const combinedData = [
      ...existingFieldOfStudy.map((fieldOfStudy) => ({
        id: fieldOfStudy.id,
        name: fieldOfStudy.name,
        isUserSuggested: false, // Existing courses are not user-suggested
      })),
      ...updatedCourseData,
    ];

    return res.status(200).json({ success: true, data: combinedData, courseSuggestedCount  });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.getUpcomingEvents = async (req, res) => {
  try {
    const { default_timeZone } = req.query;
    const user = await db.user.findOne({
      where: { id: req.user.userId },
      // attributes:["email","email2","email3"],
      // include: [
      //     {
      //         model: db.timezone,
      //         as: 'timezone',
      //         attributes: ['id', 'timezone', 'value', 'abbreviation']
      //     }
      // ]
      // raw:true
    });
    if (!user) {
      throw { statusCode: 404, message: 'User not found' }
    }
    // const failedEmails = await fetchEventsForAllEmails(user)
    const userEmails = [user.email];
    if(user.email2){
      userEmails.push(user.email2)
    }
    if(user.email3){
      userEmails.push(user.email3)
    }

    // const timezoneValue = user.timezone ? user.timezone.value : 'UTC';
    //  console.log(timezoneValue)
    // const startOfDay = dayjs().tz(timezoneValue).startOf('day').toISOString();
    const oneMonthFromNow  = dayjs().tz(default_timeZone).add(1, 'month').toISOString();
    const now = dayjs().tz(default_timeZone).toISOString();
    const response = await dbviews.event_hub_history_view.findAll({
        where: {
            userId: req.user.userId,
            startTime: { 
              [db.Sequelize.Op.between]: [now, oneMonthFromNow]
            },
            isCancelled: false,
            isDeleted: false,
            emailAccount: {
              [db.Sequelize.Op.in]: userEmails
            },
        },
        order: [
          ['startTime', 'ASC'] 
        ],
        limit: 5
    });
    return res.status(200).json({ success: true, data: response, failedEmails: [] });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}
exports.saveEventDraft = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id, title, requiredGuests = [], optionalGuests = [], date, startTime, eventTime, senderEmail, template, eventTypeId, recurrence, recurrenceRepeat, recurrenceEndDate, recurrenceDays,recurrenceCount, recurrenceNeverEnds, predefinedMeetId, descriptionCheck, emailCheck, hideGuestList } = req.body;
    // console.log(requiredGuests)
    // Update existing draft
    if (id) {
      const existingDraft = await db.event_draft.findByPk(id);
      if (existingDraft) {
        existingDraft.draftName = title;
        existingDraft.title = title;
        existingDraft.requiredGuests = requiredGuests.join(',');
        existingDraft.optionalGuests = optionalGuests.join(',');
        existingDraft.date = date;
        existingDraft.startTime = startTime;
        existingDraft.eventTime = eventTime;
        existingDraft.senderEmail = senderEmail;
        existingDraft.template = template;
        existingDraft.eventTypeId = eventTypeId;
        existingDraft.recurrence = recurrence;
        existingDraft.recurrenceRepeat = recurrenceRepeat;
        existingDraft.recurrenceEndDate = recurrenceEndDate;
        existingDraft.recurrenceDays = recurrenceDays;
        existingDraft.recurrenceCount = recurrenceCount;
        existingDraft.recurrenceNeverEnds = recurrenceNeverEnds;
        existingDraft.predefinedMeetId = predefinedMeetId;
        existingDraft.descriptionCheck = descriptionCheck;
        existingDraft.emailCheck = emailCheck;
        existingDraft.hideGuestList = hideGuestList;
        await existingDraft.save();
        return res.status(200).json({ success: true, message: 'Event draft updated' });
      } else {
        throw { statusCode: 404, message: 'Draft not found' };
      }
    } else {
      // Check for duplicate title
      const existingDraftByTitle = await db.event_draft.findOne({ where: { userId, title } });
      if (existingDraftByTitle) {
        // throw { statusCode: 400, message: 'Draft title already exists - Choose another title' };
        return res.status(200).json({ success: true, titleExists: true});
      }

      // Check draft limit
      const drafts = await db.event_draft.count({ where: { userId } });
      if (drafts >= 5) {
        throw { statusCode: 400, message: 'You can save a maximum of 5 drafts' };
      }

      // Create new draft
      const newEntry = await db.event_draft.create({
        draftName: title,
        title,
        requiredGuests: requiredGuests.join(','),
        optionalGuests: optionalGuests.join(','),
        date,
        startTime,
        eventTime,
        senderEmail,
        template,
        eventTypeId,
        userId,
        predefinedMeetId,
        descriptionCheck,
        emailCheck,
        hideGuestList,
        recurrence, recurrenceRepeat, recurrenceEndDate, recurrenceDays,recurrenceCount, recurrenceNeverEnds
      });
      return res.status(201).json({ success: true, newEntry, message: 'Event saved as draft' });
    }
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.getEventDrafts = async (req, res) => {
  try {
      const draftEvents = await db.event_draft.findAll({where: {userId: req.user.userId, isEmailDeleted: false}, include: { model: db.predefined_meet }})
      return res.status(200).json({success: true, data: draftEvents});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.createEmailTemplate = async (req, res) => {
  try {
    const {name, template, type, meetType} = req.body;
    const userId = req.user.userId;
    const emailTemplates = await db.user_defined_email_template.findAll({where: {userId}})
    if(emailTemplates.length >= 10) {
      throw {statusCode: 400, message: 'You can save maximum 10 email template'}
    }

    await db.user_defined_email_template.create({name, userId, template, type, predefinedMeetTypeId: meetType})

    return res.status(201).json({ success: true, message: "Template Created Successfully"});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getUserEmailTemplates = async (req, res) => {
  try {
    const templates = await db.user_defined_email_template.findAll({
      where: {userId: req.user.userId},
      include: [
        { model: db.predefined_meet_type },
      ],
    });
    return res.status(200).json({success: true, data: templates});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.deleteEmailTemplate = async (req, res) => {
  try {
    const {templateId} = req.body
    await db.user_defined_email_template.destroy({where: {id: templateId, userId: req.user.userId}});
    return res.status(200).json({ success: true, message: 'Template Deleted Successfully'});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.editEmailTemplate = async (req, res) => {
  try {
    const {templateId, template, name, type, meetType} = req.body;
    const userId = req.user.userId;
    await db.user_defined_email_template.update({template, name, type, predefinedMeetTypeId: meetType},{where: {id: templateId, userId}})
    return res.status(200).json({ success: true, message: 'Template Updated Successfully'});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.createEventTemplate = async (req, res) => {
  try {
    const {title, requiredGuests, optionalGuests, date, startTime, eventTime, senderEmail, template, eventTypeId, groupId, predefinedMeetId} = req.body;
    const userId = req.user.userId;
    const user = await db.user.findByPk(userId);
    if (!user) {
      throw { statusCode: 404, message: 'User not found' }
    }
    const predefinedEvents = await db.predefined_event.findAll({where: {userId}})
    const { IS_BASIC } = CheckSubscription(user?.subscriptionId)
    if(IS_BASIC && predefinedEvents.length >= 2) {
      return res.status(400).json({ subscriptionError: true});
    }
    if(predefinedEvents.length >= 5) {
      throw {statusCode: 400, message: 'You can save maximum 5 event template'}
    }
    await db.predefined_event.create({title, requiredGuests: requiredGuests.join(','), optionalGuests: optionalGuests.join(','), date, startTime, eventTime, senderEmail, template, eventTypeId, userId, groupId: groupId?.join(','),predefinedMeetId: predefinedMeetId })
    return res.status(201).json({ success: true, message: "Event Template Created Successfully"});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getEventTemplates = async (req, res) => {
  try {
    const eventTemplates = await db.predefined_event.findAll({
      where: {userId: req.user.userId, isEmailDeleted: false}, 
      include: [
        {
            model: db.predefined_meet
        },
      ],
      order: [['id', 'asc']]
    });
    return res.status(200).json({success: true, data: eventTemplates});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.deleteEventTemplate = async (req, res) => {
  try {
    const {eventTemplateId} = req.body
    await db.predefined_event.destroy({where: {id: eventTemplateId, userId: req.user.userId}});
    return res.status(200).json({ success: true, message: 'Event Template Deleted Successfully'});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.editEventTemplate = async (req, res) => {
  try {
    const {id,title, requiredGuests, optionalGuests, date, startTime, eventTime, senderEmail, template, eventTypeId, groupId, predefinedMeetId} = req.body;
    const userId = req.user.userId;
    await db.predefined_event.update({title, requiredGuests: requiredGuests.join(','), optionalGuests: optionalGuests.join(','), date, startTime, eventTime, senderEmail, template, eventTypeId, groupId: groupId?.join(','), predefinedMeetId},{where: {id: id, userId}})
    return res.status(200).json({ success: true, message: 'Event Template Updated Successfully'});
  } catch (error) {
    console.log(error)
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.previewTemplate = async (req, res) => {
  try {
    const {template, date, time, url, passcode, phone, location, address, timezone } = req.body
    const user = await db.user.findByPk(req.user.userId)
    const emailSignature = await db.user_email_signature.findOne({where:{userId: req.user.userId}, include:[{model: db.organization},]})

    const variables = {
      date: date,
      time: time,
      name: 'User',
      eventProvider:  emailSignature?.fullname || '',
      location: 'location',
      organization: emailSignature?.organization?.organization || '',
      contact: emailSignature?.phonenumber || '',
      website:emailSignature?.website,
      url,
      passcode,
      phone,
      location,
      address,
      timezone
    }
    const content = template?.replace(/\${(.*?)}/g, (_, key) => variables[key.trim()]);
    return res.status(200).json({ success: true, data: content || ''});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.frequentlyUsedEvents = async (req, res) => {
  try {
    const data = await db.predefined_event.findAll({where: {userId: req.user.userId}, order: [['count', 'desc']],});
    return res.status(200).json({success: true, data: data});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getSubscriptionDetails = async (req, res) => {
  try {
    const data = await db.subscription.findAll({order: [['id', 'asc']]});
    return res.status(200).json({success: true, data: data});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getFeaturesList = async (req, res) => {
  try {
    const data = await db.feature_list.findAll({
      include: {
        model: db.subscription_feature,
        order: [['featureId', 'asc']],
      },
    });
    return res.status(200).json({success: true, data: data});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getOrgTabNames = async (req, res) => {
  const orgId = req.user.orgId;
  const {userTypeId} = req.params;
  try {
    const data = await db.org_tabs.findAll({
      where: {orgId}, 
      attributes: ['id','tabId','tabNameOrgGiven'],
      order: [['tabId', 'asc']],
      include: {
        model: db.tabs,
        where: {userTypeId},
        attributes: []
      }
    });
    return res.status(200).json({success: true, data: data});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getEventTypes = async (req, res) => {
  try {
    const response = await db.event_types.findAll({order: [['id', 'asc']]});
    return res.status(200).json({ success: true, data: response });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getEventHubHistory = async (req, res) => {
  try {
    const user = await db.user.findByPk(req.user.userId)
    // const failedEmails = await fetchEventsForAllEmails(user)
    const { page , pageSize, sortingOrder,sortingColumn,startDateFilter,endDateFilter, bookedFilter, eventTypeFilter} = req.query;
    const offset = page * pageSize;

    // const user = await db.user.findOne({
    //   where: { id: req.user.userId },
    //   attributes:["email","email2","email3"],
    // });
    // if (!user) {
    //   throw { statusCode: 404, message: 'User not found' }
    // }
    // const userEmails = [user.email];
    // if(user.email2){
    //   userEmails.push(user.email2)
    // }
    // if(user.email3){
    //   userEmails.push(user.email3)
    // }

    let filter = {
      userId: req.user.userId,
      // senderEmail: {
      //   [db.Sequelize.Op.in]: userEmails
      // },
    };

    if (startDateFilter && endDateFilter) {
      filter.startTime = {
          [db.Sequelize.Op.between]: [startDateFilter, endDateFilter],
        }
    }
    else if (startDateFilter && !endDateFilter) {
      filter.startTime = {
        [db.Sequelize.Op.gte]: startDateFilter // Greater than or equal to startDateFilter
      };
    }
    if (bookedFilter) {
      if (bookedFilter === 'cancelled') {
        filter[db.Sequelize.Op.or] = [
          { isCancelled: true },
          { isDeleted: true }
        ];
      }
    }
    if(eventTypeFilter && eventTypeFilter !== 'All') {
      filter.eventTypeValue = eventTypeFilter
    }

    // const response = await db.event_hub_events.findAndCountAll({where:{
    //   userId: req.user.userId
    // }});
    const response = await dbviews.event_hub_history_view.findAndCountAll({
      where: filter,
      limit: +pageSize,
      offset: +offset,
      order: [[sortingColumn, sortingOrder]],
    });
    return res.status(200).json({ success: true, data: response.rows,  totalCount: response.count  });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.createPredefinedMeet = async (req, res) => {
  try {
    const userId = req.user.userId
    await db.predefined_meet.create({...req.body, userId});
    return res.status(200).json({ success: true, message: 'Record saved Successfully' });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getPredefinedMeets = async (req, res) => {
  try {
    const userId = req.user.userId
    const predefinedMeets = await db.predefined_meet.findAll({where: {userId}, order: [['id', 'asc']]});
    return res.status(200).json({success: true, data: predefinedMeets});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.deletePredefinedMeet = async (req, res) => {
  try {
    const {id} = req.body
    const userId = req.user.userId
    await db.predefined_meet.destroy({where: {id, userId}});
    return res.status(200).json({ success: true, message: 'Predefined Meet Deleted Successfully'});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.editPredefinedMeet = async (req, res) => {
  try {
    const {id, ...rest} = req.body;
    const userId = req.user.userId;
    await db.predefined_meet.update(rest,{where: {id: id, userId}})
    return res.status(200).json({ success: true, message: 'Predefined Meet Updated Successfully'});
  } catch (error) {
    console.log(error)
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getPredefinedMeetLocation = async (req, res) => {
  try {
    const predefinedMeetLocation = await db.predefined_meet_location.findAll({order: [['id', 'asc']]});
    return res.status(200).json({success: true, data: predefinedMeetLocation});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getPredefinedMeetType = async (req, res) => {
  try {
    const predefinedMeetType = await db.predefined_meet_type.findAll({order: [['id', 'asc']]});
    return res.status(200).json({success: true, data: predefinedMeetType});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.deleteEventHubEvent = async (req, res) => {
  try {
    let { eventId, senderEmail, senderEmailServiceProvider } = req.body;
    const user = await db.user.findByPk(req.user.userId)
      try {
        senderEmail = senderEmail.toLowerCase()
        if(senderEmail == user.email){
          if(senderEmailServiceProvider === 'google'){
            try {
            await cancelGoogleEvent(user.emailAccessToken, user.emailRefreshToken, eventId);
            }
            catch(err) {
              throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
            }
            // await cancelMicrosoftEvent(user.emailAccessToken, user.emailRefreshToken, eventId, req.user.userId);
          }else if(senderEmailServiceProvider === 'microsoft'){
            try {
            await cancelMicrosoftEvent(user.emailAccessToken, user.emailRefreshToken, eventId, req.user.userId, senderEmail);
            }
            catch(err) {
              throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
            }
          }
        }else if(senderEmail == user.email2){
          if(senderEmailServiceProvider === 'google'){
            try {
            await cancelGoogleEvent(user.email2AccessToken, user.email2RefreshToken, eventId);
            }
            catch(err) {
              throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
            }
            // await cancelMicrosoftEvent(user.email2AccessToken, user.email2RefreshToken, eventId, req.user.userId);
          }else if(senderEmailServiceProvider === 'microsoft'){
            try {
            await cancelMicrosoftEvent(user.email2AccessToken, user.email2RefreshToken, eventId, req.user.userId, senderEmail);
            }
            catch(err) {
              throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
            }
          }
        }else if(senderEmail == user.email3){
          if(senderEmailServiceProvider === 'google'){
            try {
            await cancelGoogleEvent(user.email3AccessToken, user.email3RefreshToken, eventId);
            }
            catch(err) {
              throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
            }
            // await cancelMicrosoftEvent(user.email3AccessToken, user.email3RefreshToken, eventId, req.user.userId);
          }else if(senderEmailServiceProvider === 'microsoft'){
            try {
            await cancelMicrosoftEvent(user.email3AccessToken, user.email3RefreshToken, eventId, req.user.userId, senderEmail);
            }
            catch(err) {
              throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
            }
          }
        }
        
      } catch (error) {
        console.error('Error cancelling event:', error);
        throw { statusCode: 500, message: error.message }
      }
      // eventHubEvent.isCancelled = true
      // await eventHubEvent.save()
      return res.status(201).json({ success: true, message: 'Event cancelled successfully'});
  }
  catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.updateEventHubEvent = async (req, res) => {
  try {
    let { id, startTimeSlot, title, guests, endTimeSlot, eventId, emailAccount, senderEmailServiceProvider, senderEmail, rejectedEmails } = req.body;
    const givenDateTime = new Date(startTimeSlot)
    const currentDateTime = new Date()
    if (givenDateTime.getTime() < currentDateTime.getTime()) {
      throw {statusCode: 400, message: "Please give future time only"}
    }
    const userId = req.user.userId
    const user = await db.user.findByPk(userId)
    const attendeesString = guests.join(',');
      
    const exactEventResponse = await dbviews.event_hub_history_view.findOne({where:{eventId, emailAccount, userId}})
    if((startTimeSlot == exactEventResponse?.startTime) && (endTimeSlot == exactEventResponse?.endTime) && title == exactEventResponse["title"] && attendeesString == exactEventResponse["attendees"]){
      return res.status(400).json({ message: 'No Changes provided', success: false });
    }
    if(startTimeSlot !== exactEventResponse?.startTime) {
    const isEventExist = await dbviews.event_merge_calendar_view.findOne({
      where: {
        userId: req.user.userId,
        [db.Sequelize.Op.or]: [
            {
                startTime: {
                    [db.Sequelize.Op.lt]: startTimeSlot  //Checks if the event's startTime is equal to the provided startdatetime
                },
                endTime: {
                    [db.Sequelize.Op.gt]: startTimeSlot  //Checks if the event's endTime is equal to the provided startdatetime
                }
            },
            {
                startTime: {
                    [db.Sequelize.Op.lt]: endTimeSlot    //Checks if the event's startTime is equal to the provided enddatetime
                },
                endTime: {
                    [db.Sequelize.Op.gt]: endTimeSlot    //Checks if the event's endTime is equal to the provided enddatetime
                }
            },
            {
              startTime: {
                  [db.Sequelize.Op.gte]: startTimeSlot    //Checks if the event's startTime is greater than or equal to the provided startdatetime
              },
              endTime: {
                  [db.Sequelize.Op.lte]: endTimeSlot      //Checks if the event's endTime is less than or equal to the provided enddatetime 
              }
            }
        ],
      }
    })
    if(isEventExist) throw { statusCode: 409, message: 'Event already exist for the given time range'}
  }
      const attendeesForGoogle = guests.map(email => ({email: email}))
      const attendeesForMicrosoft = guests.map((guest) => ({ emailAddress: { address: guest }, type: "required" }))
      senderEmail = senderEmail.toLowerCase();
      if(senderEmail == user.email){
        if(senderEmailServiceProvider === 'google'){
          try {
          await updateGoogleEvent(user?.emailAccessToken, user?.emailRefreshToken, eventId, title, startTimeSlot, endTimeSlot, attendeesForGoogle );
          }
          catch(err) {
            throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
          }
        }else if(senderEmailServiceProvider === 'microsoft'){
          try {
          await updateMicrosoftEvent(user?.emailAccessToken, user?.emailRefreshToken, eventId, title, startTimeSlot, req.user.userId, endTimeSlot, attendeesForMicrosoft, senderEmail);
          }
          catch(err) {
            throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
          }
        }
      }else if(senderEmail == user?.email2){
        if(senderEmailServiceProvider === 'google'){
          try{
          await updateGoogleEvent(user?.email2AccessToken, user.email2RefreshToken, eventId, title, startTimeSlot, endTimeSlot, attendeesForGoogle );
        }
        catch(err) {
          throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
        }
        
        }else if(senderEmailServiceProvider === 'microsoft'){
        try {
          await updateMicrosoftEvent(user?.email2AccessToken, user?.email2RefreshToken, eventId, title, startTimeSlot, req.user.userId, endTimeSlot, attendeesForMicrosoft, senderEmail);
        }
        catch(err) {
          throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
        }
        }
      }else if(senderEmail == user?.email3){
        if(senderEmailServiceProvider === 'google'){
          try {
          await updateGoogleEvent(user?.email3AccessToken, user.email3RefreshToken, eventId, title, startTimeSlot, endTimeSlot, attendeesForGoogle );
        }
        catch(err) {
          throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
        }
        }else if(senderEmailServiceProvider === 'microsoft'){
        try {
          await updateMicrosoftEvent(user?.email3AccessToken, user?.email3RefreshToken, eventId, title, startTimeSlot, req.user.userId, endTimeSlot, attendeesForMicrosoft, senderEmail);
        }
        catch(err) {
          throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
        }
        }
      }
      for (const email of rejectedEmails) {
        await db.propose_new_time.update({isRejected: true}, {where: {eventId, email}})
      }
    // await db.event_hub_events.update({ title: title, startTime: startTimeSlot, attendees: attendeesString }, { where: { id: id } });
    // const failedEmails = await fetchEventsForAllEmails(user)
    return res.status(200).json({ message: 'Event updated Successfully', success: true });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.respondEventInvite = async (req, res) => {
  try {
    const {date, startTime, endTime, text, senderEmail, emailAccount ,senderEmailServiceProvider, eventId, status, datetimeUTC, eventTitle, isProposingNewtime, startDateTime, endDateTime, eventIdAcrossAllCalendar, eventDate, eventStartTime, eventEndTime, title} = req.body
    const userId = req.user.userId;
    const user = await db.user.findByPk(userId);
    let message; 
    if(isProposingNewtime) {
      const isAlreadyProposedTime = await db.propose_new_time.findOne({where: {eventId, email: emailAccount}})
      if (isAlreadyProposedTime) {
        return res.status(400).json({error: true, message: 'You Already proposed a new time for this event'})
      }
      const content = `Existing Event Details - <br/><br/> ${title} <br/> Date: ${eventDate} <br/> StartTime: ${eventStartTime} <br/> EndTime: ${eventEndTime} <br/><br/> New Proposed Time - <br/><br/> ${text} <br/><br/> Date: ${date} <br> StartTime: ${startTime} <br/> EndTime : ${endTime}`
      sendNotification(senderEmail, 'Proposing new time', content, null, emailAccount)
      const senderIds = await db.user.findAll({  // user might have multiple accounts with same email
        where: {
          [Op.or]: [
            { email: senderEmail },
            { email2: senderEmail },
            { email3: senderEmail }
          ]
        },
        attributes: ['id', 'isNotificationDisabled'],
        raw: true
      });
      await db.propose_new_time.create({eventIdAcrossAllCalendar, eventId, email: emailAccount, startTime: startDateTime, endTime: endDateTime, comment: text, userId})
      const io = getIo()
      const connectedUsers = getConnectedUsers()
      const description = `I am ${user.fullname} - ${text}`
      for (const senderId of senderIds) {
        if(!senderId.isNotificationDisabled) {
          const createdAt = new Date().toISOString()
          const notification = await db.notification.create({userId: senderId.id, description: description, datetime: datetimeUTC, type: "propose_new_time", createdAt, title: eventTitle})
          io.to(connectedUsers.get(+senderId.id)).emit('PROPOSE_NEW_TIME', { id: notification.id, description: description, datetime: datetimeUTC, type: "propose_new_time", createdAt, title: eventTitle})
        }
      }
      message = "Success"
    }
    else {
      let accessToken, refreshToken, emailServiceProvider;
      if(emailAccount === user.email) {
        accessToken = user.emailAccessToken
        refreshToken = user.emailRefreshToken
        emailServiceProvider = user.emailServiceProvider
      }
      else if (emailAccount === user.email2) {
        accessToken = user.email2AccessToken
        refreshToken = user.email2RefreshToken
        emailServiceProvider = user.email2ServiceProvider
      }
      else if (emailAccount === user.email3) {
        accessToken = user.email3AccessToken
        refreshToken = user.email3RefreshToken
        emailServiceProvider = user.email3ServiceProvider
      }
      if(emailServiceProvider === 'microsoft') {
        try { 
      await respondMicrosoftInvite(accessToken, refreshToken, eventId, emailAccount, status, userId) 
        }
      catch(err) {
        throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
      }
      }
      else if(emailServiceProvider === 'google') {
        try {
      await respondGoogleInvite(accessToken, refreshToken, eventId, emailAccount, status)
        }
      catch(err) {
        throw { statusCode: err.statusCode, message: err.statusCode === 404 ? 'This event is already deleted' : err.message}
      }
      }
      message = "Event updated Successfully"
    }
    return res.status(200).json({ message: message, success: true });
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.frequentlyMetPeople = async (req, res) => {
  try {
    // const data = await dbviews.frequently_met_people_view.findAll({
    //   where: {userId: req.user.userId},
    //   order: [['count', 'desc']],
    //   attributes: ['attendee', 'userId', 'count', 'rank'],
    //   limit: 5 
    // });
    const data = await dbviews.frequently_met_people_tags_view.findAll({
      where: {userId: req.user.userId},
      order: [['count', 'desc']],
      attributes: ['attendee', 'userId', 'emailAccount', 'count', 'rank', 'tagName'],
      limit: 5 
    });
    return res.status(200).json({success: true, data: data});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.deleteEventDraft = async (req, res) => {
  try {
    // Retrieve the draft ID from the request body
    const { id } = req.body;

    // Ensure the ID is provided
    if (!id) {
      throw { statusCode: 400, message: 'Draft ID is required' };
    }

    // Check if the draft exists
    const draft = await db.event_draft.findOne({ where: { id, userId: req.user.userId } });

    if (!draft) {
      throw { statusCode: 404, message: 'Draft not found' };
    }

    // Delete the draft
    await db.event_draft.destroy({ where: { id, userId: req.user.userId } });

    return res.status(200).json({ success: true, message: 'Draft deleted successfully' });
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.getContacts = async (req, res) => {
  try {
    const userId = req.user.userId;
    const contacts = await db.contact.findAll({where: { userId }, order: [['id', 'asc']]});
    return res.status(200).json({success: true, data: contacts});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.addContact = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {email} = req.body;
    const contact = await db.contact.findOne({where: { userId, email }});
    if(contact) {
      throw {statusCode: 400, message: 'This contact is already in your list'}
    }
    await db.contact.create({...req.body, userId});
    return res.status(201).json({success: true, message: 'Contact Saved Successfully'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.editContact = async (req, res) => {
  try {
    const {id, ...rest} = req.body
    const userId = req.user.userId;
    const contact = await db.contact.findOne({where: { userId, email: rest.email, id: {
      [Op.ne]: id
    } }});
    if(contact) {
      throw {statusCode: 400, message: 'This contact is already in your list'}
    }
    await db.contact.update({...rest}, {where: {userId, id}});
    return res.status(200).json({success: true, message: 'Contact Updated Successfully'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.deleteContact = async (req, res) => {
  try {
    const {id} = req.body
    const userId = req.user.userId;
    await db.contact.destroy({where: {userId, id}});
    return res.status(200).json({success: true, message: 'Contact deleted Successfully'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.addBulkContacts = async (req, res) => {
  try {
    const { csvFileBase64Data } = req.body;
    const csvData = Buffer.from(csvFileBase64Data, 'base64').toString('utf-8');
    const results = [];
    const stream = Readable.from(csvData.split('\n'));
    stream.pipe(csv()).on('data', (data) => {
      results.push(data);
    }).on('end', async () => {
      try {
    let failedRecords = []
    let savedRecords = []
    const transaction = await db.sequelize.transaction();
    const existingContacts = await db.contact.findAll({where: { userId: req.user.userId, email: results.map(item => item.email) }, attributes: ['email']});
    const existingEmails = existingContacts.map(contact => contact.email);    
    for (const item of results) {
      if (existingEmails.includes(item.email)) {
        failedRecords.push({ contactData: item, message: 'Duplicate email error' });
      }
      else {
        try {
          const createdContact = await db.contact.create({ ...item, userId: req.user.userId },{ transaction });
          savedRecords.push(createdContact);
        } catch (error) {
          failedRecords.push({ contactData: item, message: error.message });
        }
      }
    }
    await transaction.commit();
    if (failedRecords.length > 0) {
      return res.status(200).json({ warning: true, message: 'Some records were not saved', failedRecords: failedRecords });
    }
    return res.status(200).json({ success: true, message: 'Contacts Added successfully' })
      }
      catch (error) {
        if (transaction) await transaction.rollback();
          console.error('Error:', error);
          return res.status(500).json({error: true, message: 'Failed to add contacts'});
      }
    })
      .on('error', (error) => {
        console.error('Error parsing CSV:', error);
        return res.status(500).json({ error: true, message: 'Error parsing CSV' }); // Send error status
      });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getQuestions = async (req, res) => {
  try {
    const userId = req.user.userId;
    const questions = await db.question.findAll({where: { userId }, order: [['id', 'asc']]});
    return res.status(200).json({success: true, data: questions});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.addQuestion = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {question} = req.body;
    const total = await db.question.findAll({where: { userId }});
    if(total.length === 20) {
      throw {statusCode: 400, message: 'You can save maximum 20 Questions'}
    }
    const result = await db.question.findOne({where: { userId, question }});
    if(result) {
      throw {statusCode: 400, message: 'This Question is already in use'}
    }
    await db.question.create({...req.body, userId});
    return res.status(201).json({success: true, message: 'Question Saved Successfully'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.editQuestion = async (req, res) => {
  try {
    const {id, ...rest} = req.body
    const userId = req.user.userId;
    const result = await db.question.findOne({where: { userId, question: rest.question, id: {
      [Op.ne]: id
    } }});
    if(result) {
      throw {statusCode: 400, message: 'This question is already in use'}
    }
    await db.question.update({...rest}, {where: {userId, id}});
    return res.status(200).json({success: true, message: 'Question Updated Successfully'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.deleteQuestion = async (req, res) => {
  try {
    const {id} = req.body
    const userId = req.user.userId;
    await db.question.destroy({where: {userId, id}});
    return res.status(200).json({success: true, message: 'Question deleted Successfully'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.submitOpenAvailabilityFeedback = async (req, res) => {
  try {
    const {availabilityId, questions} = req.body;
    const queAns = questions.map(item => ({openAvailabilityId: availabilityId, question: item.question, answer: Array.isArray(item?.answer) ? item?.answer?.join(',') : item.answer, type: item.type}));
    await db.open_availability_feedback.bulkCreate(queAns);
    return res.status(201).json({success: true, message: 'Feedback Submitted Successfully'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.saveMultipleContacts = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {contacts} = req.body;
    for (const item of contacts) {
      let failedRecords = []
      const contact = await db.contact.findOne({where: { userId, email: item.email }});
      if(contact) {
        failedRecords.push({email, message: 'This contact is already in your list'})
      }
      else {
        await db.contact.create({email: item.email, userId});
      }
    }
    return res.status(201).json({success: true, message: 'Contact Saved Successfully'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.createEmailSignature = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {title, fullname, phonenumber, organization, website} = req.body;

    const existingEmailSignature = await db.user_email_signature.findOne({where:{userId:userId}})

    if(existingEmailSignature){
      // update existing email signature
      existingEmailSignature.title = title;
      existingEmailSignature.fullname = fullname;
      existingEmailSignature.phonenumber = phonenumber;
      existingEmailSignature.organizationId = organization;
      existingEmailSignature.website = website;
      await existingEmailSignature.save()
    }else{
      //create new email signature
       await db.user_email_signature.create({userId: userId, title, fullname, phonenumber, organizationId: organization, website})
    }
   
    return res.status(201).json({success: true, message: existingEmailSignature? 'Email Signature Updated Successfully' : 'Email Signature Created Successfully'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getEmailSignature = async (req, res) => {
  try {
    const userId = req.user.userId;
    const response = await db.user_email_signature.findOne({where:{userId:userId}, include:[{model: db.organization},]})
    return res.status(201).json({success: true, data: response});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.createEventTemplateDuplicate = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {id} = req.body;
    const eventTemplates = await db.predefined_event.findAll({where: {userId}})
    if(eventTemplates.length >= 5) {
      throw {statusCode: 400, message: 'You can save maximum 5 event template'}
    }
    const eventTemplate = await db.predefined_event.findOne({where:{id:id}})
    if (!eventTemplate) {
      return res.status(404).json({ success: false, message: 'Event template not found' });
    }

    const existingTemplates = await db.predefined_event.findAll({
      where: {
        // type: eventTemplate.type,  // Assuming 'type' is a property of eventTemplate
        title: {
          [db.Sequelize.Op.like]: `${eventTemplate.title}%`  // Check for similar titles
        }
      }
    });
      // Generate a unique title for the duplicate
      let newTitle = `${eventTemplate.title} #Duplicate`;
      let suffix = 1;
      while (existingTemplates.some(template => template.title === newTitle)) {
        newTitle = `${eventTemplate.title} #Duplicate${suffix}`;
        suffix++;
      }

    // Create the new event template with the unique title
    const newEventTemplate = await db.predefined_event.create({
      userId: userId,
      title: newTitle,
      requiredGuests : eventTemplate?.requiredGuests,
      optionalGuests : eventTemplate?.optionalGuests,
      startTime: eventTemplate?.startTime,
      eventTime: eventTemplate?.eventTime,
      senderEmail : eventTemplate?.senderEmail,
      template: eventTemplate?.template,
      eventTypeId:eventTemplate?.eventTypeId,
      groupId:eventTemplate?.groupId,
      predefinedMeetId:eventTemplate?.predefinedMeetId
    });

    return res.status(201).json({success: true, message: 'Duplicate Created'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.sendInviteOnEmail = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {title, date, startTime, endTime, guests, email, template, eventTime, timezone, timezone_abbr, hideGuestList} = req.body
    const emailSignature = await db.user_email_signature.findOne({where:{userId:userId}, include:[{model: db.organization},]})
      const variables = {
        date: date,
        time: `${startTime} ${timezone_abbr}`,
        name: 'User',
        eventProvider: emailSignature?.fullname || '',
        location: 'NA',
        organization: emailSignature?.organization?.organization || '',
        contact: emailSignature?.phonenumber || '',
        website: emailSignature?.website,
        timezone
      }
      const attendees = [...guests, email]
      const subject = title
      const content = template.replace(/\${(.*?)}/g, (_, key) => variables[key.trim()]);
      sendNotification(attendees, subject, content, null, email, hideGuestList)
      return res.status(201).json({success: true, message: 'Invite Send Successfully'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.createEmailTemplateDuplicate = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {id} = req.body;
    const emailTemplates = await db.user_defined_email_template.findAll({where: {userId}})
    if(emailTemplates.length >= 10) {
      throw {statusCode: 400, message: 'You can save maximum 10 email template'}
    }
    const emailTemplate = await db.user_defined_email_template.findOne({where:{id:id}})
    if (!emailTemplate) {
      return res.status(404).json({ success: false, message: 'Email template not found' });
    }
    const existingTemplates = await db.user_defined_email_template.findAll({
      where: {
        name: {
          [db.Sequelize.Op.like]: `${emailTemplate.name}%`  // Check for similar names
        }
      }
    });
      // Generate a unique name for the duplicate
      let newName = `${emailTemplate.name} #Duplicate`;
      let suffix = 1;
      while (existingTemplates.some(template => template.name === newName)) {
        newName = `${emailTemplate.name} #Duplicate${suffix}`;
        suffix++;
      }

    // Create the new email template with the unique name
    const newEmailTemplate = await db.user_defined_email_template.create({
      userId: userId,
      name: newName,
      template: emailTemplate?.template,
      type : emailTemplate?.type,
      predefinedMeetTypeId: emailTemplate?.predefinedMeetTypeId
    });

    return res.status(201).json({success: true, message: 'Duplicate Created'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.createGroupDuplicate = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {id} = req.body;
    const groups = await db.group.findAll({where: {createdBy: userId}})
    if(groups.length >= 10) {
      throw {statusCode: 400, message: 'You can save maximum 10 Groups'}
    }

    const group = await db.group.findOne({
      where: { id: id },
      include: [
        {
          model: db.contact,      // The model representing the group members
          as: 'groupMembers'      // Alias as defined in your associations
        }
      ]
    });
    if (!group) {
      return res.status(404).json({ success: false, message: 'Event template not found' });
    }
    const existingGroups = await db.group.findAll({
      where: {
        name: {
          [db.Sequelize.Op.like]: `${group.name}%`  // Check for similar titles
        }
      }
    });
      // Generate a unique title for the duplicate
      let newName = `${group.name} #Duplicate`;
      let suffix = 1;
      while (existingGroups.some(group => group.name === newName)) {
        newName = `${group.name} #Duplicate${suffix}`;
        suffix++;
      }
      const memberIds = group.groupMembers.map(member => member.id); // Assuming `id` is the identifier for members

    // Create the new event template with the unique title
    const newGroup = await db.group.create({
      createdBy: userId,
      name: newName,
      createdAt: new Date().toISOString(),
      description : group?.description,
      adminName: group?.adminName,
      addMe: group?.addMe
    });
    await newGroup.setGroupMembers(memberIds);
    return res.status(201).json({success: true, message: 'Duplicate Created'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}
exports.respondAvailabilityAccept = async (req, res) => {
  try {
    const {id,receiverEmail, date, startTime, endTime} = req.body
    const userId = req.user.userId;
    const user = await db.user.findByPk(userId);
    const openAvailability = await db.open_availability.findByPk(id)
    if(!openAvailability.booked) {
      return res.status(404).json({ message: 'This event is already deleted.', success: false });
    }
    openAvailability.statusId = 2
    openAvailability.isAcceptedByOwner = true
    await openAvailability.save()
    const location =
      openAvailability.meetType === 3
        ? `${openAvailability.houseNo ? openAvailability.houseNo + ", " : ""}${
            openAvailability.houseName ? openAvailability.houseName + ", " : ""
          }${openAvailability.street ? openAvailability.street + ", " : ""}${
            openAvailability.area ? openAvailability.area + ", " : ""
          }${openAvailability.cityDetails?.name ? openAvailability.cityDetails.name + ", " : ""}${
            openAvailability.stateDetails?.name ? openAvailability.stateDetails.name + ", " : ""
          }${openAvailability.pincode ? openAvailability.pincode + ", " : ""}${
            openAvailability.landmark ? openAvailability.landmark + ", " : ""
          }<br/>
          ${
            openAvailability.mapLink
              ? `Map Link: <a href="${openAvailability.mapLink}" target="_blank">Click here</a>`
              : ""
          }`
        : `<a href="${openAvailability.meetingLink}" target="_blank">Join Meeting</a>`;
    const content =  `Your booking has been confirmed for the following details: <br/><br/> 
    Date: ${date} <br/> 
    Start Time: ${startTime} <br/> 
    End Time: ${endTime} <br/><br/>
    Location: ${location}`;
    sendNotification(receiverEmail, 'Booking Accepted', content, null, openAvailability.senderEmail)

    return res.status(200).json({ message: 'Slot Accepted', success: true });
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getEventDetails = async (req, res) => {
  try {
    const {eventId} = req.params;
    const userId = req.user.userId;
    const event = await dbviews.event_hub_history_view.findOne({where: {eventId, userId}, attributes: ['senderEmail', 'senderEmailServiceProvider', 'emailAccount', 'attendees', 'startTime', 'eventDurationInMinutes', 'endTime']})
    return res.status(200).json({ success: true, data: event });
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getAllUpcomingEvents = async (req, res) => {
  try {
    const user = await db.user.findByPk(req.user.userId)
    // const failedEmails = await fetchEventsForAllEmails(user)
    const { page , pageSize, sortingOrder,sortingColumn,startDateFilter,endDateFilter, bookedFilter, eventTypeFilter} = req.query;
    const offset = page * pageSize;
    let filter = {
      userId: req.user.userId,
      startTime: {[db.Sequelize.Op.gte]: startDateFilter}
    };

    if (startDateFilter && endDateFilter) {
      filter.startTime = {
          [db.Sequelize.Op.between]: [startDateFilter, endDateFilter],
        }
      filter.endTime = {
          [db.Sequelize.Op.between]: [startDateFilter, endDateFilter],
        }
    }
    else if (startDateFilter && !endDateFilter) {
      filter.startTime = {
        [db.Sequelize.Op.gte]: startDateFilter // Greater than or equal to startDateFilter
      };
    }
    if (bookedFilter) {
      if (bookedFilter === 'cancelled') {
        // filter.isDeleted = true;
        filter[db.Sequelize.Op.or] = [
          { isCancelled: true },
          { isDeleted: true }
        ];
      }
    }
    if(eventTypeFilter && eventTypeFilter !== 'All') {
      filter.eventTypeValue = eventTypeFilter
    }
    const response = await dbviews.event_hub_history_view.findAndCountAll({
      where: filter,
      limit: +pageSize,
      offset: +offset,
      order: [[sortingColumn, sortingOrder]],
    });
    return res.status(200).json({ success: true, data: response.rows,  totalCount: response.count  });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getFaq = async (req, res) => {
  try {
    const faq = await db.faq.findAll({order: [['id', 'asc']]});
    return res.status(200).json({ success: true, data: faq });
  }
  catch {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.shareOpenAvailabilityLinkViaEmail = async (req, res) => {
  try {
    const {from, to, subject, emailBody: content} = req.body;
    sendNotification(to, subject, content, null, from);
    return res.status(201).json({ success: true, message: 'Link Shared Successfully'});
  }
  catch {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getDashboardSearchOptions = async (req, res) => {
  try {
    const response = await db.dashboard_search_options.findAll();
    return res.status(200).json({ success: true, data: response });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.checkAvailabilityForAdvancedEvent = async (req, res) => {
  try {
    let {title, email, guests, eventDuration, bufferTime, startDateTimeRange, endDateTimeRange, newTemplate, timezone, excludeAvailabilityRange } = req.body
    let NotAvailableEmails = [];
    let AvailableEmails = [];
    const incrementMinutes = 30;
    let emailServiceProvider ,accessToken, refreshToken;
    const userId = req.user.userId
    const user = await db.user.findByPk(userId)
      if (email === user.email) {
        accessToken = user.emailAccessToken
        refreshToken = user.emailRefreshToken
        emailServiceProvider = user.emailServiceProvider
      }
      else if (email === user.email2) {
        accessToken = user.email2AccessToken
        refreshToken = user.email2RefreshToken
        emailServiceProvider = user.email2ServiceProvider
      }
      else if (email === user.email3) {
        accessToken = user.email3AccessToken
        refreshToken = user.email3RefreshToken
        emailServiceProvider = user.email3ServiceProvider
      }
    if(!accessToken && !refreshToken && !emailServiceProvider) {
      return res.status(400).json({ error: true, message: `You have not synced your email - You can't create event` });
    }
    async function checkExistingEvent(emailAccount) {
      let startDateTime = dayjs(startDateTimeRange).tz(timezone);
      let endDateTime = startDateTime.add(eventDuration, 'minutes');
    
      while (startDateTime.isBefore(dayjs(endDateTimeRange).tz(timezone))) {         // find the slot until record not found for each guest
        const existingEvent = await dbviews.event_merge_calendar_view.findOne({
          where: {
            emailAccount,
            [db.Sequelize.Op.or]: [
              {
                startTime: {
                  [db.Sequelize.Op.lt]: startDateTime.toISOString()        //Checks if the event's startTime is equal to the provided startdatetime
                },
                endTime: {
                  [db.Sequelize.Op.gt]: startDateTime.toISOString()        //Checks if the event's endTime is equal to the provided startdatetime
                }
              },
              {
                startTime: {
                  [db.Sequelize.Op.lt]: endDateTime.toISOString()           //Checks if the event's startTime is equal to the provided enddatetime
                },
                endTime: {
                  [db.Sequelize.Op.gt]: endDateTime.toISOString()           //Checks if the event's endTime is equal to the provided enddatetime
                }
              },
              {
                startTime: {
                  [db.Sequelize.Op.gte]: startDateTime.toISOString()        //Checks if the event's startTime is greater than or equal to the provided startdatetime
                },
                endTime: {
                  [db.Sequelize.Op.lte]: endDateTime.toISOString()          //Checks if the event's endTime is less than or equal to the provided enddatetime
                }
              }
            ]
          }
        });
    
        if (!existingEvent) {
          if(excludeAvailabilityRange) {
          const existingSlot = await db.open_availability.findOne({
            where: {
              senderEmail: emailAccount,
              [db.Sequelize.Op.or]: [
                {
                  //datetime refers to starttime
                  datetime: {
                    [db.Sequelize.Op.lt]: startDateTime.toISOString()        //Checks if the event's datetime is equal to the provided startdatetime
                  },
                  endtime: {
                    [db.Sequelize.Op.gt]: startDateTime.toISOString()        //Checks if the event's endtime is equal to the provided startdatetime
                  }
                },
                {
                  datetime: {
                    [db.Sequelize.Op.lt]: endDateTime.toISOString()           //Checks if the event's datetime is equal to the provided enddatetime
                  },
                  endtime: {
                    [db.Sequelize.Op.gt]: endDateTime.toISOString()           //Checks if the event's endtime is equal to the provided enddatetime
                  }
                },
                {
                  datetime: {
                    [db.Sequelize.Op.gte]: startDateTime.toISOString()        //Checks if the event's datetime is greater than or equal to the provided startdatetime
                  },
                  endtime: {
                    [db.Sequelize.Op.lte]: endDateTime.toISOString()          //Checks if the event's endtime is less than or equal to the provided enddatetime
                  }
                }
              ]
            }
          });
          if(!existingSlot) {
            return {
              emailAccount,
              startTime: startDateTime.toISOString(),
              endTime: endDateTime.toISOString()
            };
          }
        }
        else {
            return {
              emailAccount,
              startTime: startDateTime.toISOString(),
              endTime: endDateTime.toISOString()
            };
          }
        }
    
        // Increment the time
        
        startDateTime = startDateTime.add(incrementMinutes, 'minutes');
        endDateTime = startDateTime.add(eventDuration, 'minutes');
      }
    
      // Return null if no slot is found within the range
      return null;
    }
    

    for (const emailAccount of guests) {
    const availableSlot = await checkExistingEvent(emailAccount);
    if (availableSlot) {
      AvailableEmails.push(availableSlot);
      if (!dayjs(startDateTimeRange).tz(timezone).isAfter(dayjs(endDateTimeRange).tz(timezone)) || !dayjs(startDateTimeRange).tz(timezone).isSame(dayjs(endDateTimeRange).tz(timezone))) {
        startDateTimeRange = dayjs(availableSlot?.startTime).add((eventDuration + bufferTime), 'minutes').tz(timezone).toISOString();
      }
    } else {
      NotAvailableEmails.push(emailAccount);
    }
  }

  if(NotAvailableEmails.length > 0) {
    return res.status(201).json({success: true, warning: true, message: 'Some Attendees are not available', NotAvailableEmails: NotAvailableEmails, AvailableEmails});
  }
  
  for (const item of AvailableEmails) {
    // const availableSlot = await checkSlot(emailAccount);
    // const endDateTime = dayjs(availableSlot?.datetime).add(eventDuration, 'minutes').tz(timezone).toISOString();
    // const startDateTime = availableSlot?.datetime
    // startDateTimeRange = dayjs(availableSlot?.datetime).add((eventDuration + bufferTime), 'minutes').tz(timezone).toISOString();
    let googleResponse, microsoftResponse, meetingLink, eventId;
    if (emailServiceProvider === 'google') {
      const attendeesForGoogle =[{ email: item.emailAccount }]
      googleResponse = await sendGoogleEvent(accessToken, refreshToken, item.startTime, attendeesForGoogle, title, item.endTime)
      meetingLink = googleResponse?.meetingLink;
      eventId = googleResponse?.eventId
    }  
  else if (emailServiceProvider === "microsoft") {
      const attendeesForMicrosoft = [{ emailAddress: { address: item.emailAccount }}]
        microsoftResponse =  await sendMicrosoftEvent(accessToken, refreshToken, item.startTime, attendeesForMicrosoft, userId, email, title, item.endTime)
        meetingLink = microsoftResponse?.meetingLink
        eventId = microsoftResponse?.eventId
    }
    const entry = {
      userId: userId,
      startTime: item.startTime,
      endTime: item.endTime,
      title: title,
      senderEmail: email,
      attendees: item.emailAccount,
      meetingLink: meetingLink,
      eventId: eventId,
      eventDurationInMinutes: eventDuration,
      eventTypeId: 5,           // advanced event
      emailTemplate: newTemplate,
    }
    await db.event_hub_events.create(entry)
    // await db.open_availability.update({booked: true, title, meetingLink, eventId}, {where: {id: availableSlot.id}})
  }
    return res.status(201).json({success: true, message: 'Event Created Successfully'});
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.createAdvancedEvent = async (req, res) => {
  try {
    let {title, email, guests, eventDuration, bufferTime, startDateTimeRange, endDateTimeRange, newTemplate, timezone, AvailableEmails} = req.body
    let emailServiceProvider ,accessToken, refreshToken;
    const userId = req.user.userId
    const user = await db.user.findByPk(userId)
      if (email === user.email) {
        accessToken = user.emailAccessToken
        refreshToken = user.emailRefreshToken
        emailServiceProvider = user.emailServiceProvider
      }
      else if (email === user.email2) {
        accessToken = user.email2AccessToken
        refreshToken = user.email2RefreshToken
        emailServiceProvider = user.email2ServiceProvider
      }
      else if (email === user.email3) {
        accessToken = user.email3AccessToken
        refreshToken = user.email3RefreshToken
        emailServiceProvider = user.email3ServiceProvider
      }

    for (const item of AvailableEmails) {
      let googleResponse, microsoftResponse, meetingLink, eventId;
      if (emailServiceProvider === 'google') {
        const attendeesForGoogle =[{ email: item.emailAccount }]
        googleResponse = await sendGoogleEvent(accessToken, refreshToken, item.startTime, attendeesForGoogle, title, item.endTime)
        meetingLink = googleResponse?.meetingLink;
        eventId = googleResponse?.eventId;
      }  
    else if (emailServiceProvider === "microsoft") {
        const attendeesForMicrosoft = [{ emailAddress: { address: item.emailAccount }}]
          microsoftResponse =  await sendMicrosoftEvent(accessToken, refreshToken, item.startTime, attendeesForMicrosoft, userId, email, title, item.endTime)
          meetingLink = microsoftResponse?.meetingLink
          eventId = microsoftResponse?.eventId
      }
      const entry = {
        userId: userId,
        startTime: item.startTime,
        endTime: item.endTime,
        title: title,
        senderEmail: email,
        attendees: item.emailAccount,
        meetingLink: meetingLink,
        eventId: eventId,
        eventDurationInMinutes: eventDuration,
        eventTypeId: 5,           // advanced event
        emailTemplate: newTemplate,
      }
      await db.event_hub_events.create(entry)
      // await db.open_availability.update({booked: true, title, meetingLink, eventId}, {where: {id: availableSlot.id}})
  }
    let message = 'Event Created Successfully' 
    return res.status(201).json({success: true, message});
  } 
  catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.createAdvancedEventWithoutCheckingAvailability = async (req, res) => {
  try {
    let {title, email, guests, eventDuration, bufferTime, startDateTimeRange, newTemplate, timezone} = req.body
    let emailServiceProvider ,accessToken, refreshToken;
    const userId = req.user.userId
    const user = await db.user.findByPk(userId)
      if (email === user.email) {
        accessToken = user.emailAccessToken
        refreshToken = user.emailRefreshToken
        emailServiceProvider = user.emailServiceProvider
      }
      else if (email === user.email2) {
        accessToken = user.email2AccessToken
        refreshToken = user.email2RefreshToken
        emailServiceProvider = user.email2ServiceProvider
      }
      else if (email === user.email3) {
        accessToken = user.email3AccessToken
        refreshToken = user.email3RefreshToken
        emailServiceProvider = user.email3ServiceProvider
      }
      if(!accessToken && !refreshToken && !emailServiceProvider) {
        return res.status(400).json({ error: true, message: `You have not synced your email - You can't create event` });
      }
      for (const emailAccount of guests) {
      let googleResponse, microsoftResponse, meetingLink, eventId;
      const endDateTime = dayjs(startDateTimeRange).add(eventDuration, 'minutes').tz(timezone).toISOString();
      const startDateTime = startDateTimeRange
      if (emailServiceProvider === 'google') {
        const attendeesForGoogle =[{ email: emailAccount }]
        googleResponse = await sendGoogleEvent(accessToken, refreshToken, startDateTime, attendeesForGoogle, title, endDateTime)
        meetingLink = googleResponse?.meetingLink;
        eventId = googleResponse?.eventId;
      }  
      else if (emailServiceProvider === "microsoft") {
        const attendeesForMicrosoft = [{ emailAddress: { address: emailAccount }}]
        microsoftResponse = await sendMicrosoftEvent(accessToken, refreshToken, startDateTime, attendeesForMicrosoft, userId, email, title, endDateTime)
        meetingLink = microsoftResponse?.meetingLink
        eventId = microsoftResponse?.eventId
      }
      startDateTimeRange = dayjs(startDateTimeRange).add((eventDuration + bufferTime), 'minutes').tz(timezone).toISOString();
      const entry = {
        userId: userId,
        startTime: startDateTime,
        endTime: endDateTime,
        title: title,
        senderEmail: email,
        attendees: emailAccount,
        meetingLink: meetingLink,
        eventId: eventId,
        eventDurationInMinutes: eventDuration,
        eventTypeId: 5,           // advanced event
        emailTemplate: newTemplate,
      }
      await db.event_hub_events.create(entry)
    }
    return res.status(201).json({success: true, message: 'Event Created Successfully'});
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' }); 
  }
}



exports.updateUserTabActivity = async (req, res) => {
  const { userId, tabId, startTime } = req.body;

  if (!userId || !tabId || !startTime) {
    return res.status(400).json({ message: 'Missing required fields: user id, tab id, start time' });
  } 

  try {
    const lastActivity = await db.user_tab_activities.findOne({
      where: { userId, endTime: null }, 
      order: [['startTime', 'DESC']], 
    });

    if (lastActivity) {
      await lastActivity.update({
        endTime:startTime, 
      });
    }

    const newActivity = await db.user_tab_activities.create({
      userId,
      tabId,
      startTime
    });

    return res.status(201).json({success: true});
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Server error' });
  }
};



exports.getTabs = async (req, res) => {
  try {
    const data = await db.booking_application_tabs.findAll({
      attributes: ['id','tabName']
    });
    return res.status(200).json({success: true, data: data});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}
exports.getTagLinkTypes = async (req, res) => {
  try {
    const data = await db.tag_link_type.findAll({order: [['id', 'asc']]});
    return res.status(200).json({success: true, data});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getEmailSupportCategory = async (req, res) => {
  try {
    const data = await db.email_support_category.findAll({order: [['id', 'asc']]});
    return res.status(200).json({success: true, data});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.emailSupport = async (req, res) => {
  try {
    const userId = req.user.userId;
    await db.email_support.create({...req.body, userId});
    return res.status(201).json({success: true, message: 'Success'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.duplicateQuestion = async (req, res) => {
  try {
    const userId = req.user.userId;
    let {id, question, ...rest} = req.body
    const existingQuestions = await db.question.findAll({where: { userId }});
    if(existingQuestions.length === 20) {
      throw {statusCode: 400, message: 'You can save maximum 20 Questions'}
    }
 
    let newQuestion = `${question} #Duplicate`
    let suffix = 1;
    while (existingQuestions.some(item => item.question === newQuestion)) {
      newQuestion = `${question} #Duplicate${suffix}`;
      suffix++;
    }
    await db.question.create({...rest, question: newQuestion, userId});
    return res.status(201).json({success: true, message: 'Question Saved Successfully'});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getEmailSupportHistoryByUserId = async (req, res) => {
  try {
    const data = await db.email_support.findAll({
      where: {
        userId: req.user.userId
      },
      include: [
        {
          model: db.email_support_category,
          attributes: ['name'],
          as: 'category'
        }
      ],
      order: [['id', 'desc']]
    });
    return res.status(200).json({success: true, data});
  } catch (error) {
    res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.checkAvailabilityForAdvancedEventRoundRobin = async (req, res) => {
  try {
    let { title, email, guests, eventDuration, bufferTime, startDateTimeRange, endDateTimeRange, newTemplate, timezone } = req.body
    let finalSlotsToBeBooked = []
    async function getSlots() {
      return await db.open_availability.findAll({
        where: {
          senderEmail: guests, //fetch for all guest
          booked: false,
          datetime: {
            [Op.gte]: startDateTimeRange, // datetime should be greater than or equal to startDatetimeRange
            [Op.lt]: endDateTimeRange     // datetime should be strictly less than endDatetimeRange
          }
        },
        attributes: ['datetime', 'senderEmail', 'id'],
        raw: true
      })
    }
    let AllSlots = await getSlots()
    if (AllSlots.length === 0) {
      return res.status(404).json({ error: true, message: 'No one is available for the given range' });
    }
    let sortedSlots = AllSlots.sort((a, b) => {
      return dayjs(a.datetime).tz(timezone).isBefore(dayjs(b.datetime).tz(timezone)) ? -1 : 1;
    });
    const earliestSlot = sortedSlots[0]              // checking earliest to book first
    finalSlotsToBeBooked.push(earliestSlot)
    sortedSlots = sortedSlots.filter(i => i.senderEmail !== earliestSlot.senderEmail)       // removing all the slots for which we got earliest slot to check for others
    let newDatetime = dayjs(earliestSlot.datetime).add((eventDuration + bufferTime), 'minutes').tz(timezone).toISOString()
    for (let i = 0; i < sortedSlots.length;) {  // want more control for indexing that's why using old for loop
      const item = sortedSlots[i];

      if (dayjs(item.datetime).tz(timezone).isAfter(dayjs(newDatetime).tz(timezone)) || dayjs(item.datetime).tz(timezone).isSame(dayjs(newDatetime).tz(timezone))) {
        finalSlotsToBeBooked.push(item);
        // Update sortedSlots by filtering out items with the same senderEmail
        sortedSlots = sortedSlots.filter(slot => slot.senderEmail !== item.senderEmail);
        newDatetime = dayjs(item.datetime).add((eventDuration + bufferTime), 'minutes').tz(timezone).toISOString();
        // Reset the loop index to start over with updated sortedSlots and newDatetime
        i = 0;
      } else {
        // Increment the index only if no update was made
        i++;
      }
    }

    const NotAvailableEmails = guests.filter(guestEmail => !finalSlotsToBeBooked.some(slot => slot.senderEmail === guestEmail));

    if (NotAvailableEmails.length > 0) {
      return res.status(201).json({ success: true, warning: true, message: 'Some Attendees are not available', NotAvailableEmails: NotAvailableEmails, finalSlotsToBeBooked });
    }
    let emailServiceProvider, accessToken, refreshToken;
    const userId = req.user.userId
    const user = await db.user.findByPk(userId)
    if (email === user.email) {
      accessToken = user.emailAccessToken
      refreshToken = user.emailRefreshToken
      emailServiceProvider = user.emailServiceProvider
    }
    else if (email === user.email2) {
      accessToken = user.email2AccessToken
      refreshToken = user.email2RefreshToken
      emailServiceProvider = user.email2ServiceProvider
    }
    else if (email === user.email3) {
      accessToken = user.email3AccessToken
      refreshToken = user.email3RefreshToken
      emailServiceProvider = user.email3ServiceProvider
    }
    for (const item of finalSlotsToBeBooked) {
      const endDateTime = dayjs(item?.datetime).add(eventDuration, 'minutes').tz(timezone).toISOString();
      const startDateTime = item?.datetime
      let googleResponse, microsoftResponse, meetingLink, eventId;
      if (emailServiceProvider === 'google') {
        const attendeesForGoogle = [{ email: item.senderEmail }]
        googleResponse = await sendGoogleEvent(accessToken, refreshToken, startDateTime, attendeesForGoogle, title, endDateTime)
        meetingLink = googleResponse?.meetingLink;
        eventId = googleResponse?.eventId
      }
      else if (emailServiceProvider === "microsoft") {
        const attendeesForMicrosoft = [{ emailAddress: { address: item.senderEmail } }]
        microsoftResponse = await sendMicrosoftEvent(accessToken, refreshToken, startDateTime, attendeesForMicrosoft, userId, email, title, endDateTime)
        meetingLink = microsoftResponse?.meetingLink
        eventId = microsoftResponse?.eventId
      }
      // await db.open_availability.update({ booked: true, title, meetingLink, eventId }, { where: { id: item.id } })
    }
    return res.status(201).json({ success: true, message: 'Event Created Successfully' });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.createAdvancedEventRoundRobin = async (req, res) => {
  try {
    let { title, email, guests, eventDuration, timezone, finalSlotsBookingForRoundRobin } = req.body
    if (finalSlotsBookingForRoundRobin.length === 0) {
      return res.status(200).json({ success: true, warning: true, message: "No event has been created as all the attendees are not available" });
    }
    let emailServiceProvider, accessToken, refreshToken;
    const userId = req.user.userId
    const user = await db.user.findByPk(userId)
    if (email === user.email) {
      accessToken = user.emailAccessToken
      refreshToken = user.emailRefreshToken
      emailServiceProvider = user.emailServiceProvider
    }
    else if (email === user.email2) {
      accessToken = user.email2AccessToken
      refreshToken = user.email2RefreshToken
      emailServiceProvider = user.email2ServiceProvider
    }
    else if (email === user.email3) {
      accessToken = user.email3AccessToken
      refreshToken = user.email3RefreshToken
      emailServiceProvider = user.email3ServiceProvider
    }
    for (const item of finalSlotsBookingForRoundRobin) {
      const endDateTime = dayjs(item?.datetime).add(eventDuration, 'minutes').tz(timezone).toISOString();
      const startDateTime = item?.datetime
      let googleResponse, microsoftResponse, meetingLink, eventId;
      if (emailServiceProvider === 'google') {
        const attendeesForGoogle = [{ email: item.senderEmail }]
        googleResponse = await sendGoogleEvent(accessToken, refreshToken, startDateTime, attendeesForGoogle, title, endDateTime)
        meetingLink = googleResponse?.meetingLink;
        eventId = googleResponse?.eventId
      }
      else if (emailServiceProvider === "microsoft") {
        const attendeesForMicrosoft = [{ emailAddress: { address: item.senderEmail } }]
        microsoftResponse = await sendMicrosoftEvent(accessToken, refreshToken, startDateTime, attendeesForMicrosoft, userId, email, title, endDateTime)
        meetingLink = microsoftResponse?.meetingLink
        eventId = microsoftResponse?.eventId
      }
      // await db.open_availability.update({ booked: true, title, meetingLink, eventId }, { where: { id: item.id } })
    }
    return res.status(201).json({ success: true, message: 'Event Created Successfully' });
  }
  catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getProposeNewTime = async (req, res) => {
  try {
    const {eventIdAcrossAllCalendar, userId} = req.params;
    let whereClause = {eventIdAcrossAllCalendar: eventIdAcrossAllCalendar}
    if(userId) {
      whereClause.userId = userId
    }
    const data = await db.propose_new_time.findAll({where : whereClause})
    return res.status(200).json({ success: true, data });
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.saveBlockEmailForBookingSlot = async (req, res) => {
  try {
    let {tagId, email} = req.body;
    email = email.toLowerCase()
    const isEmailAlreadyExist = await db.blocked_email_by_slot_broadcaster.findOne({where: {email, tagId}})
    if(isEmailAlreadyExist) {
      return res.status(400).json({ error: true, message: 'This email is already blocked for this tag' });
    }
    await db.blocked_email_by_slot_broadcaster.create({email, tagId, tagOwnerUserId: req.user.userId})
    return res.status(201).json({ success: true, message: 'Record Added Successfully' });
  } catch (error) {
     return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.checkExistingOpenAvailabilityOrSave = async (req, res) => {
  try {
    const { tpId, dateTimeSlots, email, tagId } = req.body;
    const userId = req.user.userId;
    const user = await db.user.findOne({ where: { id: userId }, raw: true })
    let emailServiceProvider;
    if (email == user.email) {
      emailServiceProvider = user.emailServiceProvider;
    } else if (email == user.email2) {
      emailServiceProvider = user.email2ServiceProvider;
    } else if (email == user.email3) {
      emailServiceProvider = user.email3ServiceProvider;
    }


    const existingSlots = [];
    const existingOpenSlots = [];
    const existingEvents = [];
    const remainingOpenSlots = [];
    const remainingEvents = [];
    let newSlots = [];

    for (const item of dateTimeSlots) {
      const existingOpenSlot = await db.open_availability.findOne({
        where: {
          userId: userId,
          [db.Sequelize.Op.or]: [
            {
              //datetime refers to starttime
              datetime: {
                [db.Sequelize.Op.lt]: item.startTime        //Checks if the event's datetime is equal to the provided startdatetime
              },
              endtime: {
                [db.Sequelize.Op.gt]: item.startTime        //Checks if the event's endtime is equal to the provided startdatetime
              }
            },
            {
              datetime: {
                [db.Sequelize.Op.lt]: item.endTime           //Checks if the event's datetime is equal to the provided enddatetime
              },
              endtime: {
                [db.Sequelize.Op.gt]: item.endTime           //Checks if the event's endtime is equal to the provided enddatetime
              }
            },
            {
              datetime: {
                [db.Sequelize.Op.gte]: item.startTime        //Checks if the event's datetime is greater than or equal to the provided startdatetime
              },
              endtime: {
                [db.Sequelize.Op.lte]: item.endTime          //Checks if the event's endtime is less than or equal to the provided enddatetime
              }
            }
          ],
          isCancelled: false,
        }
      });
      if(existingOpenSlot) {
        existingOpenSlots.push(item)
      }
      else {
        newSlots.push(item)
        remainingOpenSlots.push(item)
      }
    }
   
    for (const item of remainingOpenSlots) {
      const isEventExist = await dbviews.event_merge_calendar_view.findOne({
        where: {
          userId: userId,
          [db.Sequelize.Op.or]: [
              {
                  startTime: {
                      [db.Sequelize.Op.lt]: item.startTime  //Checks if the event's startTime is equal to the provided startdatetime
                  },
                  endTime: {
                      [db.Sequelize.Op.gt]: item.startTime  //Checks if the event's endTime is equal to the provided startdatetime
                  }
              },
              {
                  startTime: {
                      [db.Sequelize.Op.lt]: item.endTime    //Checks if the event's startTime is equal to the provided enddatetime
                  },
                  endTime: {
                      [db.Sequelize.Op.gt]: item.endTime    //Checks if the event's endTime is equal to the provided enddatetime
                  }
              },
              {
                startTime: {
                    [db.Sequelize.Op.gte]: item.startTime    //Checks if the event's startTime is greater than or equal to the provided startdatetime
                },
                endTime: {
                    [db.Sequelize.Op.lte]: item.endTime      //Checks if the event's endTime is less than or equal to the provided enddatetime 
                }
              }
          ],
          isCancelled: false,
          isDeleted: false,
        }
      })

      if(isEventExist) {
        existingEvents.push(item)
        newSlots = newSlots.filter(i => i.startTime !== item.startTime)
      }
      else {
        remainingEvents.push(item)
      }
    }
     // if the user is Talent partner
    if (req.user.role === 1) {
      for (const item of remainingEvents) {
        const existingSlot = await db.availability.findOne({
        where: {
          tpId: userId,
          [db.Sequelize.Op.or]: [
            {
              //datetime refers to starttime
              datetime: {
                [db.Sequelize.Op.lt]: item.startTime        //Checks if the event's datetime is equal to the provided startdatetime
              },
              endtime: {
                [db.Sequelize.Op.gt]: item.startTime        //Checks if the event's endtime is equal to the provided startdatetime
              }
            },
            {
              datetime: {
                [db.Sequelize.Op.lt]: item.endTime           //Checks if the event's datetime is equal to the provided enddatetime
              },
              endtime: {
                [db.Sequelize.Op.gt]: item.endTime           //Checks if the event's endtime is equal to the provided enddatetime
              }
            },
            {
              datetime: {
                [db.Sequelize.Op.gte]: item.startTime        //Checks if the event's datetime is greater than or equal to the provided startdatetime
              },
              endtime: {
                [db.Sequelize.Op.lte]: item.endTime          //Checks if the event's endtime is less than or equal to the provided enddatetime
              }
            }
          ]
        }
        });

        if(existingSlot) {
          existingSlots.push(item)
          newSlots = newSlots.filter(i => i.startTime !== item.startTime)
        }
      }
    }

    if (existingSlots.length > 0 || existingEvents.length > 0 || existingOpenSlots.length > 0) {
      return res.status(200).json({ existingEvents, existingSlots, newSlots, existingOpenSlots, success: true });
    }

    const entries = newSlots.map((item) => ({ userId: req.user.userId, datetime: item.startTime, senderEmail: email, emailServiceProvider: emailServiceProvider, tagId, endtime: item.endTime }));
    await db.open_availability.bulkCreate(entries);
    const tag = await db.open_availability_tags.findByPk(tagId, {
      include: {
        model: db.user,
        as: 'tagMembers',
        attributes: ['id', 'fullname', 'email', 'emailServiceProvider'],
        through:{attributes:[]}
      }
    })
    for (const item of tag?.tagMembers) {
      const entriesForTagMembers = newSlots.map((el) => ({userId: item.id, datetime: el.startTime, senderEmail: item.email, emailServiceProvider: item?.emailServiceProvider, tagId, endtime: el.endTime }))
      await db.open_availability.bulkCreate(entriesForTagMembers);
    }
    return res.status(200).json({ success: true, message: 'Slots Saved Successfully', newSlots: newSlots });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.saveSlotOpenAvailability = async (req, res) => {
    try {
      const { tpId, dateTimeSlots, email, tagId } = req.body;
      const user = await db.user.findOne({where:{id: req.user.userId}, raw:true})
      let emailServiceProvider;
      if(email == user.email){
        emailServiceProvider = user.emailServiceProvider;
      }else if(email == user.email2){
        emailServiceProvider = user.email2ServiceProvider;
      }else if(email == user.email3){
        emailServiceProvider = user.email3ServiceProvider;
      }
      const enteries = dateTimeSlots.map((item) => ({ userId: req.user.userId, datetime: item.startTime, senderEmail: email, emailServiceProvider:emailServiceProvider, tagId, endtime: item.endTime }));
      await db.open_availability.bulkCreate(enteries);
      const tag = await db.open_availability_tags.findByPk(tagId, {
        include: {
          model: db.user,
          as: 'tagMembers',
          attributes: ['id', 'fullname', 'email', 'emailServiceProvider'],
          through:{attributes:[]}
        }
      })
      for (const item of tag?.tagMembers) {
        const entriesForTagMembers = dateTimeSlots.map((el) => ({userId: item.id, datetime: el.startTime, senderEmail: item.email, emailServiceProvider: item?.emailServiceProvider, tagId, endtime: el.endTime }))
        await db.open_availability.bulkCreate(entriesForTagMembers);
      }
      res.status(201).json({ success: true, message: 'Slots Saved Successfully' });
    }
    catch (error) {
      res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
  };


exports.getBlockedEmailForSlots = async (req, res) => {
  try {
    const data = await db.blocked_email_by_slot_broadcaster.findAll({
      where: {tagOwnerUserId: req.user.userId}, 
      include: {
        model: db.open_availability_tags,
        as: 'tagDetails',
        attributes: ['tagName']
      }
    })
    return res.status(200).json({ success: true, data});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.deleteBlockedEmailForSlot = async (req, res) => {
  try {
    const {email, tagId} = req.body
    await db.blocked_email_by_slot_broadcaster.destroy({where: {email, tagId}})
    return res.status(201).json({ success: true, message: 'Email Deleted Successfully'});
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.updateUsernameFlag = async (req, res) => {
   try {
    await db.user.update({isUsernameUpdated: true}, {where: {id: req.user.userId}})
    return res.status(201).json({ success: true });
   } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
   }
} 


exports.getOpenAvailabilityQuestionAnswer = async (req, res) => {
  try {
    const {openAvailabilityId} = req.query
    const data = await db.open_availability_feedback.findAll({where: {openAvailabilityId}})
    return res.status(200).json({ success: true, data });
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getIndustries = async (req, res) => {
  try {
    const data = await db.industry.findAll({})
    return res.status(200).json({ success: true, data });
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.activateFreeTrial = async (req, res) => {
  try {
    const user = await db.user.findByPk(req.user.userId)
    if (user.isFreeTrialOver) {
      throw { statusCode: 400, error: true, message: 'You already used free services' };
    }
    user.freeSubscriptionExpiration = dayjs().add(5, 'days').toISOString()
    await user.save()
    return res.status(201).json({ success: true, message: 'Free Trial Activated' });
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getOpenAvailabilityByTagId = async (req, res) => {
  try {
    const {tagId, startDate, endDate} = req.query;
    const userId = req.user.userId;
    let start, end;
    if (startDate && endDate) {
      start = startDate;
      end = endDate
    }
    else {
      const currentDate = dayjs();
  
      const firstAvailableSlot = await db.open_availability.findOne({
        where: {
          userId: userId,
          tagId: tagId,
          // booked: false,
          isCancelled: false,
          datetime: {
            [db.Sequelize.Op.gt]: currentDate.toISOString()
          }
        },
        attributes: ['datetime'],
        order: [['datetime', 'ASC']]
      });
      const datetime = dayjs(firstAvailableSlot?.datetime)
      start = dayjs(datetime).toISOString()
      end = dayjs(datetime).endOf('month').toISOString();
    }
    const data = await db.open_availability.findAll({
      where: {
        userId: userId,
        tagId: tagId,
        // booked: false,
        isCancelled: false,
        datetime: {
          [db.Sequelize.Op.gt]: dayjs().toISOString(),
          [db.Sequelize.Op.between]: [start, end]
        }
      },
      // attributes: ['id', 'datetime', 'endtime', 'booked'],
      order: [['datetime', 'ASC']],
      include:[
        {
          model: db.open_availability_tags,
          attributes:['eventDuration', 'title'],
          as: 'tagData'
        },
        {
          model: db.open_availability_feedback,
          // attributes:['eventDuration', 'title'],
          as: 'questionDetails'
        },
    ]
    });
    return res.status(200).json({ success: true, data: data });
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.updateAppGuide = async (req, res) => {
  const key = Object.keys(req.body)[0]
  const value = Object.values(req.body)[0]
  try {
    await db.user.update({[key]: value}, {where: {id: req.user.userId}})
    return res.status(201).json({ success: true });
  } catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}

exports.getPersonalBookings = async (req, res) => {
  try {
    const { page , pageSize, sortingOrder,sortingColumn,startDateFilter, endDateFilter, appliedFilter} = req.query;
   
    const offset = page * pageSize;
 
    const user = await db.user.findByPk(req.user.userId, {attributes: ['email', 'email2', 'email3']})
    const emailList = [user.email, user.email2, user.email3].filter(Boolean)
    let filter = {
      receiverEmail: {
        [db.Sequelize.Op.in]: emailList
      }
    };
    if (startDateFilter) {
      if (startDateFilter && endDateFilter) {
        filter.datetime = {
          [db.Sequelize.Op.and]: [

            { [db.Sequelize.Op.gte]: startDateFilter},

            { [db.Sequelize.Op.lte]: endDateFilter },
         
          ]
        };
      } else {
        filter.datetime = {
          [db.Sequelize.Op.gte]: startDateFilter,
        };
      }
    }
    if(appliedFilter === 'cancelled') {
      filter.isCancelled = true
    }
    else {
      filter.isCancelled = false
    }
    const response = await db.open_availability.findAndCountAll({
      where: filter,
      limit: +pageSize,
      offset: +offset,
      order: [[sortingColumn, sortingOrder]],
      include: {
        model: db.open_availability_tags,
        attributes: ['tagName', 'eventDuration'],
        as: 'tagData'
      }
    });
    res.status(200).json({ success: true, data: response.rows, totalCount: response.count });
 
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}