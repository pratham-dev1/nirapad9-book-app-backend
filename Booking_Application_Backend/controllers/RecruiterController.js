const db = require("../models");
const { Op } = require('sequelize');
const Sequelize = require('sequelize');
const { sendGoogleEvent } = require("../utils/sendGoogleEvent");
const { sendMicrosoftEvent } = require("../utils/sendMicrosoftEvent");
const { sendFormLinkThroughGoogle } = require("../utils/sendFormLinkThroughGoogle");
const { sendFormLinkThroughMicrosoft } = require("../utils/sendFormLinkThroughMicrosoft");
const { sendNotification } = require("../utils/mailgun");
const { getIo, getConnectedUsers } = require("../utils/socket");
const { cancelMicrosoftEvent } = require("../utils/cancelMicrosoftEvent");
const { cancelGoogleEvent } = require("../utils/cancelGoogleEvent");
const { fetchEventsForAllEmails } = require("../utils/fetchEventsForAllEmails");
const dayjs = require('dayjs')
const dbviews = require("../dbviews");
const { updateMicrosoftEvent } = require("../utils/updateMicrosoftEvent");
const { updateGoogleEvent } = require("../utils/updateGoogleEvent");
exports.getAvailableSlots = async (req, res) => {
    try {
        const {logicalOperator, startDateFilter, endDateFilter, primarySkillsId, secondarySkillsId, page, pageSize, sortingColumn, sortingOrder, timeZone } = req.query;
        const offset = (page) * (pageSize);
        const now = dayjs().tz(timeZone).toISOString();
        let filter = { booked: false};
        if (startDateFilter && endDateFilter) {
            filter.datetime = {
                [Op.gt]: now,
                [Op.between]: [startDateFilter, endDateFilter],
            };
        }else if (startDateFilter) {
            filter.datetime = {
                [Op.and]: [
                  { [Op.gt]: now },
                  { [Op.gt]: startDateFilter }
                ]
              };            
          }else if (endDateFilter) {
            filter.datetime = {
            //   [Op.lt]: endDateFilter
              [Op.between]: [now, endDateFilter],
            };
          }
          else{
            filter.datetime = {
                [Op.gt]: now,
            }
          }
       
        const skillsCondition = primarySkillsId ? Sequelize.literal(`EXISTS (
            SELECT 1
            FROM "tp_skills" AS "skills->tp_skills"
            INNER JOIN "skills" AS "skills" ON "skills->tp_skills"."skillId" = "skills"."id"
            WHERE "skills->tp_skills"."userId" = "user"."id"
            AND "skills"."id" IN (${primarySkillsId.map(id => `'${id}'`).join(',')})
        )`): null;
       
        const secondarySkillsCondition = secondarySkillsId ? Sequelize.literal(`EXISTS (
            SELECT 1
            FROM "tp_secondary_skills" AS "secondarySkills->tp_secondary_skills"
            INNER JOIN "secondary_skills" AS "secondarySkills" ON "secondarySkills->tp_secondary_skills"."secondarySkillId" = "secondarySkills"."id"
            WHERE "secondarySkills->tp_secondary_skills"."userId" = "user"."id"
            AND "secondarySkills"."id" IN (${secondarySkillsId.map(id => `'${id}'`).join(',')})
        )`) : null;
       
        let userWhereClause = {
            id: { [Op.ne]: null },
            isDeleted: null,
            [Op[logicalOperator.toLowerCase()]]: secondarySkillsCondition ? [skillsCondition, secondarySkillsCondition] : [skillsCondition],
        };
 
        const userInclude = {
            model: db.user,
            attributes: ["username"],
            required: true,
            where: userWhereClause,
            include: [
                {
                    model: db.skill,
                    attributes: ["skillName"],
                    as: "skills",
                    // include where if want matching skills
                    // where: {
                    //     id: primarySkillsId
                    // },
                    required: false,
                }
            ]
        };
       
        // if (secondarySkillsId) {
            userInclude.include.push({
                model: db.secondary_skill,
                attributes: ["secondarySkillName"],
                as: 'secondarySkills',
                // where: {
                //     id: secondarySkillsId
                // },
                required: false,
            });
        // }
 
        const response = await db.availability.findAndCountAll({
            include: [
                userInclude
            ],
            where: filter,
            limit: +pageSize,
            offset: +offset,
            order: [[sortingColumn, sortingOrder]],
       });
        // console.log(response.sql);
        res.status(200).json({ success: true, data: response.rows, totalItems: response.count })
 
    } catch (error) {
        return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
};
 

exports.bookSlot = async (req, res) => {
    try {
        const { id,datetime, candidateEmail, interviewStatus, booked, skills, secondarySkills, zohoFormLink, attachments, sendFormToTP, sendFormToCandidate } = req.body;
        // const { originalName, fileData } = attachments || {};
 
        const availability = await db.availability.findByPk(id, {
            include: {
                model: db.user,
                attributes: ['email', 'fullname']
            }
        }); 
        if (!availability) {
            return res.status(404).json({ error: true, message: 'Availability not found' });
        }
        if(availability.datetime !== datetime){
            return res.status(200).json({ success: true, datetime: availability.datetime});
        }
        if(availability.booked === true){
            return res.status(200).json({ success: true, isBooked: true, message: 'Selected Slot is already booked. Please select another Slot'  });
        }
        // const isEventExistResponse = await db.event.findAll({
        //     where: {
        //         userId: req.user.userId,
        //         updatedAt: {
        //             [Op.eq]: db.sequelize.literal(`(
        //         SELECT MAX("updatedAt")
        //         FROM "events" AS subEvents
        //         WHERE subEvents."eventId" = "event"."eventId"
        //     )`)
        //         }
        //     },
        //     attributes: ['startTime', 'endTime'],
        //     raw: true
        // });
        const isEventExistResponse = await dbviews.event_merge_calendar_view.findAll({
            where: {
              userId: req.user.userId,
            },
            attributes: ['startTime', 'endTime'],
            raw: true
        });
        const existingEvents = []
        isEventExistResponse.forEach(existingEvent => {
            const availabilityStartDateTime = new Date(availability.datetime);
            const availabilityEndTime = new Date(availability.datetime).getTime() + 30 * 60000; // Add 30 minutes to availability datetime
            const availabilityEndDateTime = new Date(availabilityEndTime);
            const existingEventStartDateTime = new Date(existingEvent.startTime);
            const existingEventEndDateTime = new Date(existingEvent.endTime);
            if ((availabilityStartDateTime >= existingEventStartDateTime && availabilityStartDateTime < existingEventEndDateTime) ||
                (availabilityEndDateTime >= existingEventStartDateTime && availabilityEndDateTime < existingEventEndDateTime)
            ) {
                existingEvents.push(existingEvent)
            }  
        });
 
        if (existingEvents.length > 0) {
            return res.status(200).json({ success: true, existingEvents: existingEvents, message: 'You already have an existing event at this Slot' });
        }
        availability.candidateId = candidateEmail;
        availability.interviewStatus = interviewStatus;
        availability.booked = booked;
        availability.bookedBy = req.user.userId;
        availability.formLink = zohoFormLink
        if (skills) {
            await availability.setAvailabilitySkillsSearched(skills)
        }
        if (secondarySkills) {
            await availability.setAvailabilitySecondarySkillsSearched(secondarySkills)
        }
        const allSkills = await db.user.findAll({
            attributes: [],
            include: [
              { model: db.skill, as: 'skills', through: { attributes: [] } },
              { model: db.secondary_skill, as: 'secondarySkills', through: { attributes: [] } },
            ],
            where:{
                id: availability.tpId
            }
        })
        const tpSkills = allSkills.flatMap(entry => entry.skills.map(skill => skill.id));
        const tpAvailabilitySkills = tpSkills.filter(skillId => skills.includes(skillId));
        const tpSecondarySkills = allSkills.flatMap(entry => entry.secondarySkills.map(secondarySkill => secondarySkill.id));
        const tpAvailabilitySecondarySkills = tpSecondarySkills.filter(skillId => secondarySkills.includes(skillId));
        await availability.setSkills(tpAvailabilitySkills);
        await availability.setAvailabilitySecondarySkills(tpAvailabilitySecondarySkills)
       
        const updatedAvailabity = await availability.save();
        const user = await db.user.findByPk(req.user.userId)
        const tpEmail = availability.user.email;
        async function sendNotificationWithZohoLinkOrAttachments(email) {
            let html = ''
            if (zohoFormLink && attachments?.fileData) {
                html = `<b>Zoho form link <br/> <a href=${zohoFormLink}>${zohoFormLink}</a> <br/>Find the attachment below</b>`
                sendNotification(email, 'Zoho Link with attachment', html, attachments)
            }
            else if (zohoFormLink) {
                html = `<b>Zoho form link <br/> <a href=${zohoFormLink}>${zohoFormLink}</a></b>`
                sendNotification(email, 'Zoho Form Link', html)
            }
            else if (attachments?.fileData) {
                html = `<b>Find the attachment below <br/></b>`
                sendNotification(email, 'Interview attachment', html, attachments)
            }
        }
 
        let meetingLink = null
        if (user.emailServiceProvider === 'google') {
            const attendeesForGoogle = [{ email: tpEmail }, { email: candidateEmail }]
            googleResponse = await sendGoogleEvent(user.emailAccessToken, user.emailRefreshToken, updatedAvailabity.datetime, attendeesForGoogle)
            meetingLink = googleResponse?.meetingLink
            if (sendFormToTP) {
                await sendNotificationWithZohoLinkOrAttachments(tpEmail);
            }
            if (sendFormToCandidate) {
                await sendNotificationWithZohoLinkOrAttachments(candidateEmail);            
            }
            // await sendFormLinkThroughGoogle(user.emailAccessToken, user.emailRefreshToken, originalName, fileData,tpEmail, zohoFormLink)
        }
        else if (user.emailServiceProvider === "microsoft") {
            const attendeesForMicrosoft = [{ emailAddress: { address: tpEmail } }, { emailAddress: { address: candidateEmail } }]
            microsoftResponse = await sendMicrosoftEvent(user.emailAccessToken, user.emailRefreshToken, updatedAvailabity.datetime, attendeesForMicrosoft, req.user.userId, user.email)
            meetingLink = microsoftResponse?.meetingLink
            if (sendFormToTP) {
                await sendNotificationWithZohoLinkOrAttachments(tpEmail);
            }
            if (sendFormToCandidate) {
                await sendNotificationWithZohoLinkOrAttachments(candidateEmail);
            }
            // await sendFormLinkThroughMicrosoft(user.emailAccessToken, user.emailRefreshToken, tpEmail, zohoFormLink,fileData,originalName)
        }
        availability.meetingLink = meetingLink;
        await availability.save();
        const userRecord = await db.user.findByPk(availability.tpId)
        if (!userRecord.isNotificationDisabled) {
            const io = getIo()
            const connectedUsers = getConnectedUsers()
            const name = availability?.user?.fullname
            const description = `${name} has Booked your slot for`
            const createdAt = new Date().toISOString()
            const notification = await db.notification.create({userId: availability.tpId, description: description, datetime: availability.datetime, createdAt, type: "create_event", meetingLink: meetingLink})
            io.to(connectedUsers.get(availability.tpId)).emit('SLOT_BOOKED_BY_RECRUITER', { id: notification.id, description: description, datetime: availability.datetime, createdAt, type: "create_event", meetingLink: meetingLink})
        }
        return res.status(200).json({ success: true, message: 'Slot Booked Successfully!!!' });
    } catch (error) {
        return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}
 
exports.getZohoForms = async (req, res) => {
  try {
    const {  primarySkillIds  } = req.query;
    const response = await db.zoho_form.findAll({
    //   attributes: ['id','formName'],
      include: [
        {    
          model: db.skill,
          attributes: [],
          where: {
            id: primarySkillIds  
          },
       },]
    });
    return res.status(200).json({ success: true, data: response });
  } catch (error) {
    return res.status(500).json({ error:true,message: error.message || 'Something went wrong' });
  }
}


exports.getRecruiterHistory = async (req, res) => {
    try {
        const { startDate, endDate, page, pageSize, sortBy, sortOrder,bookedFilter } = req.query;
        const offset = (page) * (pageSize);
        let whereClause = {
            booked: true,
            bookedBy: req.user.userId
        };
        if (bookedFilter) {
            if (bookedFilter === 'cancelled') {
                whereClause.isCancelled = true;
            } else if(bookedFilter === 'cancelRequested') {
                whereClause.tpCancellationReason = {
                    [db.Sequelize.Op.ne]: null 
                  };
                whereClause.isCancelled = false;
            } else if(bookedFilter === 'true'){
                whereClause.booked = bookedFilter;
                whereClause.isCancelled = false;
                whereClause.tpCancellationReason = null; 
            } else {
                whereClause.booked = bookedFilter;
                whereClause.isCancelled = false
            }
        }
        if (startDate && endDate) {
            whereClause.datetime = {
                [Op.between]: [startDate, endDate],
            }
        }
        else if (startDate && !endDate) {
            whereClause.datetime = {
              [db.Sequelize.Op.gte]: startDate // Greater than or equal to startDate
            };
          }
        const availabilities = await db.availability.findAndCountAll({
            include: [
                { model: db.user, attributes: ['username'] },
                { model: db.skill, attributes: ['skillName'], through: { attributes: [] } },
                { model: db.secondary_skill, attributes: ['secondarySkillName'], as: "availabilitySecondarySkills" },
                { model: db.skill, attributes: ['skillName'], through: { attributes: [] }, as: "availabilitySkillsSearched" },
                { model: db.secondary_skill, attributes: ['secondarySkillName'], through: { attributes: [] }, as: "availabilitySecondarySkillsSearched" },
            ],
            where: whereClause,
            limit: +pageSize,
            offset: +offset,
            order: [[sortBy, sortOrder]],
            distinct: true,
        });
        res.status(200).json({ data: availabilities.rows, totalItems: availabilities.count });
    } catch (error) {
        res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
};

exports.getSkillsForBookedSlot = async (req, res) => {
    try {
        const userId = req.user.userId;
        const result = await db.skill.findAll({
            attributes: [
                'skillName',
                [Sequelize.fn('COUNT', Sequelize.col('availabilities.id')), 'count']
            ],
            include: [{
                model: db.availability,
                as: 'availabilities',
                attributes: [],
                where: {
                    bookedBy: userId,
                    booked: true
                },
                through: {
                    attributes: [] // To prevent including intermediate table attributes
                }
            }],
            group: ['skill.id'],
            having: Sequelize.literal('COUNT("availabilities"."id") > 0'),
            order: [[Sequelize.literal('count'), 'DESC']],
            limit: 10,
            raw: true,
            subQuery: false,
        });

        res.status(200).json({ success: true, data: result })
    }
    catch (error) {
        // console.log(error)
        res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.updateSlot = async (req, res) => {
    try {
        const {id, status} = req.body
        const slot = await db.availability.findOne({where:{id: id}})
        slot.interviewStatus = status
        await slot.save()
        res.status(200).json({ success: true, message: "Record updated successfully" })
    } catch (error) {
        res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.cancelEvent = async (req, res) => {
    try {
        const { availabilityIds, reason } = req.body
        const user = await db.user.findByPk(req.user.userId)
        // const failedEmails = await fetchEventsForAllEmails(user)
        // if (failedEmails.length > 0) {
        //     return res.status(400).json({ error: true, message: `Event cancellation failed - Events could not be fetched for emails-`, failedEmails: failedEmails });
        // }
        const event = await db.availability.findAll({
        where: { id: availabilityIds },

        attributes: ['tpId', 'datetime', 'id', 'meetingLink'],
        raw: true
      });
    for (const item of event) {
    //   const eventId = item["events.eventId"];
    const meetingLink = item["meetingLink"]
    const eventsResponse = await dbviews.event_merge_calendar_view.findOne({
        where:{meetingLink: meetingLink}, 
        attributes: ['eventId'],
    })
    const eventId = eventsResponse?.eventId
      const tpId = item['tpId']
      const datetime = item['datetime']
      if (user.emailServiceProvider === 'google') {
        await cancelGoogleEvent(user.emailAccessToken, user.emailRefreshToken, eventId);
      }
      else if (user.emailServiceProvider === "microsoft") {
        await cancelMicrosoftEvent(user.emailAccessToken, user.emailRefreshToken, eventId, req.user.userId);
      }
      await db.availability.update({isCancelled: true, cancelReasonByRecruiter: reason, meetingLink: null}, {where: {id: item.id}})
      const userRecord = await db.user.findByPk(tpId)
      if (!userRecord.isNotificationDisabled) {
          const io = getIo()
          const connectedUsers = getConnectedUsers()
          const name = user?.fullname
          const description = `${name} has Cancelled your Event for`
          const createdAt = new Date().toISOString()
          const notification = await db.notification.create({userId: tpId, description: description, datetime: datetime, createdAt, type: "cancel_event"})
          io.to(connectedUsers.get(tpId)).emit('EVENT_CANCELLED_BY_RECRUITER', { id: notification.id, description: description, datetime: datetime, createdAt, type: "cancel_event"})
      }
    }
      res.status(200).json({ success: true, message: 'Event Cancelled Successfully' })
    } catch (error) {
        res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

exports.bookConfirmedSlot = async (req, res) => {
    try {
        const { id,datetime, candidateEmail, interviewStatus, booked, skills, secondarySkills, zohoFormLink, attachments, sendFormToTP, sendFormToCandidate } = req.body;
        // const { originalName, fileData } = attachments || {};
 
        const availability = await db.availability.findByPk(id, {
            include: {
                model: db.user,
                attributes: ['email', 'fullname']
            }
        });
        if (!availability) {
            return res.status(404).json({ error: true, message: 'Availability not found' });
        }
        if (availability.booked === true) {
            return res.status(404).json({ error: true, message:  'Selected Slot is already booked. Please select another Slot'  });
        }
        //  if(availability.datetime !== datetime){
        //     return res.status(200).json({ success: true, datetime: availability.datetime});
        //  }
 
        availability.candidateId = candidateEmail;
        availability.interviewStatus = interviewStatus;
        availability.booked = booked;
        availability.bookedBy = req.user.userId;
        availability.formLink = zohoFormLink
        if (skills) {
            await availability.setAvailabilitySkillsSearched(skills)
        }
        if (secondarySkills) {
            await availability.setAvailabilitySecondarySkillsSearched(secondarySkills)
        }
        const allSkills = await db.user.findAll({
            attributes: [],
            include: [
              { model: db.skill, as: 'skills', through: { attributes: [] } },
              { model: db.secondary_skill, as: 'secondarySkills', through: { attributes: [] } },
            ],
            where:{
                id: availability.tpId
            }
        })
        const tpSkills = allSkills.flatMap(entry => entry.skills.map(skill => skill.id));
        const tpAvailabilitySkills = tpSkills.filter(skillId => skills.includes(skillId));
        const tpSecondarySkills = allSkills.flatMap(entry => entry.secondarySkills.map(secondarySkill => secondarySkill.id));
        const tpAvailabilitySecondarySkills = tpSecondarySkills.filter(skillId => secondarySkills.includes(skillId));
        await availability.setSkills(tpAvailabilitySkills);
        await availability.setAvailabilitySecondarySkills(tpAvailabilitySecondarySkills)
       
        const updatedAvailabity = await availability.save();
        const user = await db.user.findByPk(req.user.userId)
        const tpEmail = availability.user.email;
        async function sendNotificationWithZohoLinkOrAttachments(email) {
            let html = ''
            if (zohoFormLink && attachments?.fileData) {
                html = `<b>Zoho form link <br/> <a href=${zohoFormLink}>${zohoFormLink}</a> <br/>Find the attachment below</b>`
                sendNotification(email, 'Zoho Link with attachment', html, attachments)
            }
            else if (zohoFormLink) {
                html = `<b>Zoho form link <br/> <a href=${zohoFormLink}>${zohoFormLink}</a></b>`
                sendNotification(email, 'Zoho Form Link', html)
            }
            else if (attachments?.fileData) {
                html = `<b>Find the attachment below <br/></b>`
                sendNotification(email, 'Interview attachment', html, attachments)
            }
        }
 
        let meetingLink = null
        if (user.emailServiceProvider === 'google') {
            const attendeesForGoogle = [{ email: tpEmail }, { email: candidateEmail }]
            googleResponse = await sendGoogleEvent(user.emailAccessToken, user.emailRefreshToken, updatedAvailabity.datetime, attendeesForGoogle)
            meetingLink = googleResponse?.meetingLink
            if (sendFormToTP) {
                await sendNotificationWithZohoLinkOrAttachments(tpEmail);
            }
            if (sendFormToCandidate) {
                await sendNotificationWithZohoLinkOrAttachments(candidateEmail);            
            }
            // await sendFormLinkThroughGoogle(user.emailAccessToken, user.emailRefreshToken, originalName, fileData,tpEmail, zohoFormLink)
        }
        else if (user.emailServiceProvider === "microsoft") {
            const attendeesForMicrosoft = [{ emailAddress: { address: tpEmail } }, { emailAddress: { address: candidateEmail } }]
            microsoftResponse = await sendMicrosoftEvent(user.emailAccessToken, user.emailRefreshToken, updatedAvailabity.datetime, attendeesForMicrosoft, req.user.userId, user.email)
            meetingLink = microsoftResponse?.meetingLink
            if (sendFormToTP) {
                await sendNotificationWithZohoLinkOrAttachments(tpEmail);
            }
            if (sendFormToCandidate) {
                await sendNotificationWithZohoLinkOrAttachments(candidateEmail);
            }
            // await sendFormLinkThroughMicrosoft(user.emailAccessToken, user.emailRefreshToken, tpEmail, zohoFormLink,fileData,originalName)
        }
        availability.meetingLink = meetingLink;
        await availability.save();
        const userRecord = await db.user.findByPk(availability.tpId)
        if (!userRecord.isNotificationDisabled) {
            const io = getIo()
            const connectedUsers = getConnectedUsers()
            const name = availability?.user?.fullname
            const description = `${name} has Booked your slot for`
            const createdAt = new Date().toISOString()
            const notification = await db.notification.create({userId: availability.tpId, description: description, datetime: availability.datetime,type: "create_event", meetingLink: meetingLink, createdAt})
            io.to(connectedUsers.get(availability.tpId)).emit('SLOT_BOOKED_BY_RECRUITER', { id: notification.id, description: description, datetime: availability.datetime,type: "create_event", meetingLink: meetingLink, createdAt})
        }
        return res.status(200).json({ success: true, message: 'Slot Booked Successfully!!!' });
    } catch (error) {
        return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

//   exports.getAvailableSlots = async (req, res) => {
//   try {
//     const {primarySkillsId,secondarySkills,userTypeId } = req.query;
//     // const skillIds = []; // Example array of skill IDs
//     const minCount = primarySkillsId.length
//     const test = await db.tp_skills.findAll({
//       attributes: ['userId'],
//       where: {
//           skillId: primarySkillsId
//       },
//       group: ['userId'],
//       having: Sequelize.literal(`COUNT(DISTINCT "skillId") >= ${minCount}`)
//   })
//      const response = await db.availability.findAll({
//       include: [
//                       {
//                           model: db.user,
//                           attributes: ["username"],
//                           where: {
//                               id: { [Op.ne]: null }
//                           }}],
//       where:{
//         userId: {
//           [Op.in]: test.map(item => item.userId) // Extract userIds from the array
//         }
//       }
//      })


//     res.status(200).json({ success: true ,data: response });
//   } catch (error) {
//     return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
//   }
// }

exports.getSelectedUserAvailableSlots = async (req, res) => {
    try {
        const {tpId} = req.query;
        const response = await db.availability.findAll({
            attributes: ['id', 'datetime'],
            where: {tpId: tpId, booked: false, datetime:{[Op.gt]: new Date().toISOString()}},
            order: [['datetime', 'asc']],
       });
        // console.log(response.sql);
        res.status(200).json({ success: true, data: response })
 
    } catch (error) {
        return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
};

exports.changeBookedSlot = async (req, res) => {
    try {
        const { id,datetime, previousSlotId, cancelSlot } = req.body;    
        const user = await db.user.findByPk(req.user.userId)
        const previousAvailability = await db.availability.findByPk(previousSlotId)
        if (!previousAvailability) {
            return res.status(404).json({ error: true, message: ' Previous Availability not found' });
        }
        // const failedEmails = await fetchEventsForAllEmails(user)
     
        const isEvent = await dbviews.event_merge_calendar_view.findOne({
            attributes: ['eventId','title'],
            where: {
                userId: req.user.userId,
                meetingLink: previousAvailability.meetingLink
            }
        });
        
        if (!isEvent) {
            return res.status(404).json({ error: true, message: 'Event not found for updation' });
        }
        
        const availability = await db.availability.findByPk(id, {
            include: {
                model: db.user,
                attributes: ['email', 'fullname']
            }
        });
        if (!availability) {
            return res.status(404).json({ error: true, message: 'Availability not found' });
        }
         if(availability.datetime !== datetime){
            return res.status(200).json({ success: true, datetime: availability.datetime, message: 'datetime is diffrent'});
         }
        if (availability.booked === true) {
            return res.status(404).json({ error: true, message:  'Selected Slot is already booked. Please select another Slot'  });
        }

        const isEventExistResponse = await dbviews.event_merge_calendar_view.findAll({
            where: {
              userId: req.user.userId,
            },
            attributes: ['startTime', 'endTime'],
            raw: true
        });
        const existingEvents = []
        isEventExistResponse.forEach(existingEvent => {
            const availabilityStartDateTime = new Date(availability.datetime);
            const availabilityEndTime = new Date(availability.datetime).getTime() + 30 * 60000; // Add 30 minutes to availability datetime
            const availabilityEndDateTime = new Date(availabilityEndTime);
            const existingEventStartDateTime = new Date(existingEvent.startTime);
            const existingEventEndDateTime = new Date(existingEvent.endTime);
            if ((availabilityStartDateTime >= existingEventStartDateTime && availabilityStartDateTime < existingEventEndDateTime) ||
                (availabilityEndDateTime >= existingEventStartDateTime && availabilityEndDateTime < existingEventEndDateTime)
            ) {
                existingEvents.push(existingEvent)
            }  
        });
 
        if (existingEvents.length > 0) {
            return res.status(200).json({ success: true, existingEvents: existingEvents, message: 'You already have an existing event at this Slot' });
        }
        availability.candidateId = previousAvailability.candidateId;
        availability.interviewStatus = previousAvailability.interviewStatus;
        availability.booked = true;
        availability.bookedBy = previousAvailability.bookedBy;
        availability.formLink = previousAvailability.formLink
        const previousSkills = await previousAvailability.getAvailabilitySkillsSearched();
        const previousSecondarySkills = await previousAvailability.getAvailabilitySecondarySkillsSearched();

        if (previousSkills) {
            await availability.setAvailabilitySkillsSearched(previousSkills);
        }
        if (previousSecondarySkills) {
            await availability.setAvailabilitySecondarySkillsSearched(previousSecondarySkills);
        }

        const previousMatchedSkills = await previousAvailability.getSkills();
        const previousMatchedSecondarySkills = await previousAvailability.getAvailabilitySecondarySkills();
        await availability.setSkills(previousMatchedSkills);
        await availability.setAvailabilitySecondarySkills(previousMatchedSecondarySkills)
     
        availability.meetingLink = previousAvailability.meetingLink;
        await availability.save();
        if (user.emailServiceProvider === 'google') {
            await updateGoogleEvent(user.emailAccessToken, user.emailRefreshToken, isEvent.eventId, isEvent.title, datetime);
        } else if (user.emailServiceProvider === 'microsoft') {
            await updateMicrosoftEvent(user.emailAccessToken, user.emailRefreshToken,  isEvent.eventId, isEvent.title, datetime, req.user.userId);
        }

        if(cancelSlot){
              await db.availability.update({isCancelled: true, meetingLink: null, }, {where: {id:previousSlotId}})
        }else{
            previousAvailability.booked = false
            previousAvailability.candidateId = null
            previousAvailability.interviewStatus = null
            previousAvailability.bookedBy = null
            previousAvailability.formLink = null
            previousAvailability.meetingLink = null
            previousAvailability.tpCancellationReason = null
            await previousAvailability.setAvailabilitySkillsSearched([]);
            await previousAvailability.setAvailabilitySecondarySkillsSearched([]);
            await previousAvailability.setSkills([]);
            await previousAvailability.setAvailabilitySecondarySkills([])
            await previousAvailability.save()
        }   

        return res.status(200).json({ success: true, message: 'Booked Slot Changed Successfully!!!' });
    } catch (error) {
        return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}