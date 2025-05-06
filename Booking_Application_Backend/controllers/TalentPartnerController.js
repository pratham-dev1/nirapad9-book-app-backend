const db = require("../models");
const { fetchEventsForAllEmails } = require("../utils/fetchEventsForAllEmails");
const { fetchGoogleEvents } = require("../utils/fetchGoogleEvents");
const { fetchMicrosoftEvents } = require("../utils/fetchMicrosoftEvents");
const { getIo, getConnectedUsers } = require("../utils/socket");
const dayjs = require('dayjs');
const dbviews = require("../dbviews");

exports.testFunction = (req, res) => {
  res.json({ message: "test" });
};

// exports.saveSlot = async (req, res) => {
//   try {
//     const { tpId, dateTimeSlots } = req.body;
//     const enteries = dateTimeSlots.map((dateTimeSlot) => ({ tpId: req.user.userId, datetime: dateTimeSlot }));
//     await db.availability.bulkCreate(enteries);
//     res.status(201).json({ success: true, message: 'Slots Saved Successfully' });
//   }
//   catch (error) {
//     res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
//   }
// };

exports.getTalentPartnerHistory = async (req, res) => {
  try {
    const { page , pageSize, sortingOrder,sortingColumn,startDateFilter,endDateFilter, bookedFilter} = req.query;
   
    const offset = page * pageSize;
 
    let filter = {
      tpId: req.user.userId
    };
    if (startDateFilter && endDateFilter) {
      filter.datetime = {
          [db.Sequelize.Op.between]: [startDateFilter, endDateFilter],
        }
    }
    else if (startDateFilter && !endDateFilter) {
      filter.datetime = {
        [db.Sequelize.Op.gte]: startDateFilter // Greater than or equal to startDateFilter
      };
    }
    if (bookedFilter) {
      if (bookedFilter === 'cancelled') {
        filter.isCancelled = true;
      } else if (bookedFilter === 'cancelRequested'){
        filter.tpCancellationReason = {
          [db.Sequelize.Op.ne]: null 
         };
         filter.isCancelled = false;
      } else if (bookedFilter=='true'){
        filter.booked = true;
        filter.tpCancellationReason = null
        filter.isCancelled = false; 
      }else {
        filter.booked = bookedFilter;
      }
    }
    const response = await db.availability.findAndCountAll({
      where: filter,
      limit: +pageSize,
      offset: +offset,
      order: [[sortingColumn, sortingOrder]],
    });
    res.status(200).json({ success: true, data: response.rows, totalCount: response.count });
 
  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};
 

// exports.checkExistingSlots = async (req, res) => {
//   try {
//     const { tpId, dateTimeSlots } = req.body;
//     const slotsResponse = await db.availability.findAll({ where: { tpId: req.user.userId }, attributes: ['datetime'], raw: true });
//     const dateTimeSlotsResponse = slotsResponse.map((item) => item.datetime)
//     const existingSlots = [];
//     const newSlots = [];
//     dateTimeSlots.forEach(slot => {
//       if (dateTimeSlotsResponse.includes(slot)) {
//         existingSlots.push(slot)
//       }
//       else {
//         newSlots.push(slot)
//       }
//     })
//     if (existingSlots.length > 0) {
//       return res.status(200).json({ existingSlots, newSlots, success: true });
//     }
//     const enteries = newSlots.map((dateTimeSlot) => ({ tpId: req.user.userId, datetime: dateTimeSlot }));
//     await db.availability.bulkCreate(enteries)
//     return res.status(200).json({ success: true, message: 'Slots Saved Successfully' });
//   }
//   catch (error) {
//     res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
//   }
// }

// exports.checkExistingSlots = async (req, res) => {
//   try {
//     const { tpId, dateTimeSlots, email } = req.body;
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
//     //     userId: req.user.userId,
//     //     updatedAt: {
//     //       [db.Sequelize.Op.eq]: db.sequelize.literal(`(
//     //           SELECT MAX("updatedAt")
//     //           FROM "events" AS subEvents
//     //           WHERE subEvents."eventId" = "event"."eventId"
//     //       )`)
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
//     endDateTimeSlot.setMinutes(endDateTimeSlot.getMinutes() + 15);
//     // const endDateTimeSlotTime = endDateTimeSlot.getHours() * 3600000 + endDateTimeSlot.getMinutes() * 60000 + 15 * 60000;

//     dateTimeSlots.forEach(newSlot => {
//       let currentSlot = new Date(newSlot);
//       let addToNew = true;
//       dateTimeSlotsResponse.forEach(existingSlot => {
//         const slotDiffInMinutes = Math.abs((currentSlot.getTime() - new Date(existingSlot).getTime()) / (1000 * 60));
//         if (slotDiffInMinutes < 30) {
//           addToNew = false;
//           let withinThirtyMinutesOfNewSlot = false;
//           newSlotsOpenAvailability.forEach(newSlot => {
//             const diffFromNewSlot = Math.abs((currentSlot.getTime() - new Date(newSlot).getTime()) / (1000 * 60));
//             if (diffFromNewSlot < 30) {
//               withinThirtyMinutesOfNewSlot = true;
//             }
//           });
//           if (!withinThirtyMinutesOfNewSlot && !existingOpenSlots.includes(existingSlot)) {
//             existingOpenSlots.push(existingSlot);
//           }
//         }
//       });

//       if (addToNew) {
//         if ((endDateTimeSlot - (currentSlot.getHours() * 3600000 + currentSlot.getMinutes() * 60000)) >= 30 * 60 * 1000) {
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
//       const newSlotEndTime = new Date(slot).getTime() + 30 * 60000; // Add 30 minutes to availability datetime
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
//             if ((!newEventSlots.length || (newSlotStartDateTime.getTime() - new Date(newEventSlots[newEventSlots.length - 1]).getTime()) >= 30 * 60 * 1000)) {
//               newEventSlots.push(newSlotStartDateTime);
//             }
//           }
//         });
//       } else {
//         if ((!newEventSlots.length || (newSlotStartDateTime.getTime() - new Date(newEventSlots[newEventSlots.length - 1]).getTime()) >= 30 * 60 * 1000)) {
//           newEventSlots.push(newSlotStartDateTime);
//         }
//       }
//     })

//     newEventSlots.forEach(slot => {
//       newEventSlotsExpanded.push(slot.toISOString())
//       const shiftedSlot = new Date(slot.getTime() + 15 * 60 * 1000);
//       newEventSlotsExpanded.push(shiftedSlot.toISOString());
//     })


//     const availabilities = await db.availability.findAll({ where: { tpId: req.user.userId }, attributes: ['datetime'], raw: true });
//     const slotsDateTime = availabilities.map((item) => item.datetime);
//     newEventSlotsExpanded.forEach(newSlot => {
//       let currentSlot = new Date(newSlot);
//       let addToNew = true;
//       slotsDateTime.forEach(existingSlot => {
//         const slotDiffInMinutes = Math.abs((currentSlot.getTime() - new Date(existingSlot).getTime()) / (1000 * 60));
//         if (slotDiffInMinutes < 30) {
//           addToNew = false;
//           let withinThirtyMinutesOfNewSlot = false;
//           newSlots.forEach(newSlot => {
//             const diffFromNewSlot = Math.abs((currentSlot.getTime() - new Date(newSlot).getTime()) / (1000 * 60));
//             if (diffFromNewSlot < 30) {
//               withinThirtyMinutesOfNewSlot = true;
//             }
//           });
//           if (!withinThirtyMinutesOfNewSlot && !existingSlots.includes(existingSlot)) {
//             existingSlots.push(existingSlot);
//           }
//         }
//       });

//       if (addToNew) {
//         if ((endDateTimeSlot - (currentSlot.getHours() * 3600000 + currentSlot.getMinutes() * 60000)) >= 30 * 60 * 1000) {
//           slotsDateTime.push(currentSlot?.toISOString());
//           if (!newSlots.length || (currentSlot.getTime() - new Date(newSlots[newSlots.length - 1]).getTime()) >= 30 * 60 * 1000) {
//             newSlots.push(currentSlot.toISOString());
//           }
//         }
//       }
//     })


//     if (existingSlots.length > 0 || existingEvents.length > 0 || existingOpenSlots.length > 0) {
//       return res.status(200).json({ existingEvents, existingSlots, newSlots, existingOpenSlots,success: true });
//     }

//     const entries = newSlots.map((dateTimeSlot) => ({ tpId: req.user.userId, datetime: dateTimeSlot, senderEmail: email, emailServiceProvider: emailServiceProvider }));
//     await db.availability.bulkCreate(entries);
//     return res.status(200).json({ success: true, message: 'Slots Saved Successfully', newSlots: newSlots });
//   }
//   catch (error) {
//     res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
//   }
// }

exports.deleteSingleOrMultipleAvailabilities = async (req, res) => {
  try {
    const { ids } = req.body;

  // Fetch the availabilities to be deleted
  const availabilitiesToDelete = await db.availability.findAll({
    where: { id: ids, booked: false }
  });
  //map the deletableIds 
  const deletableIds = availabilitiesToDelete.map(avail => avail.id);
  
  // Delete the availabilities
  await db.availability.destroy({
   where: { id: deletableIds }
  });

  // Fetch booked availabilities that should not be deleted
  const notDeletedAvailabilities = await db.availability.findAll({
    where: {
      id: ids,
      booked: true
    }
  });
  
  return res.status(201).json({
    success: true,
    message: `${deletableIds.length > 1 ? 'Availabilities' : 'Availability'} deleted successfully`,
    notDeleted: notDeletedAvailabilities
  });

  // await db.availability.destroy({ where: { id: ids, booked: false } });
  // return res.status(201).json({ success: true, message: `${ids.length > 1 ? 'Availabilities' : 'Availability' } deleted successfully` });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.updateExistingSlot = async (req, res) => {
  try {
    const { id, dateTimeSlot } = req.body;
    const givenDateTime = new Date(dateTimeSlot)
    const currentDateTime = new Date()
    if (givenDateTime.getTime() < currentDateTime.getTime()) {
      throw {statusCode: 400, message: "Please give future time only"}
    }
    const exactSlotResponse = await db.availability.findOne({where:{id: id},attributes:['datetime','booked'],raw:true})
    if(dateTimeSlot == exactSlotResponse.datetime){
      return res.status(400).json({ message: 'Slot time is the same as previous datetime', success: false });
    }
    if(exactSlotResponse.booked){
      return res.status(200).json({ isBooked:true, message: 'Slot was just booked', success: true });
    }
    const slotsResponse = await db.availability.findAll({ where: { tpId: req.user.userId,
      id: { [db.Sequelize.Op.ne]: id }  },
      attributes: ['datetime'], raw: true });
    const dateTimeSlotsResponse = slotsResponse.map((item) => item.datetime);
   
    const isExactDuplicate = dateTimeSlotsResponse.includes(dateTimeSlot);
 
    const isInvalidSlot = dateTimeSlotsResponse.some(existingDateTime => {
      const slotDiff = Math.abs(new Date(dateTimeSlot).getTime() - new Date(existingDateTime).getTime());
      return slotDiff < 30 * 60 * 1000;
    });
 
    if (isExactDuplicate) {
      return res.status(400).json({ message: 'Slot time is the same as an existing slot', success: false });
    }
 
    if (isInvalidSlot) {
      return res.status(400).json({ message: 'Slot time is less than 30 minutes of existing slot', success: false });
    }
 
    await db.availability.update({ datetime: dateTimeSlot }, { where: { id: id } });
    return res.status(200).json({ message: 'Slot was updated', success: true });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.updateRecordTime = async (req, res) => {
  try {
    const { id, recordTime, isRecordTimeSubmitted, recordTimeComments } = req.body;
    await db.availability.update({ recordTime: recordTime, isRecordTimeSubmitted: isRecordTimeSubmitted, recordTimeComments: recordTimeComments }, { where: { id: id } });
 
    return res.status(200).json({ message: 'Record Time was updated', success: true });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

exports.slotCancelRequestOrWithdrawnRequest = async (req, res) => {
  try {
    const { id, reason } = req.body;
    const availability = await db.availability.findByPk(id, {
      include: {
          model: db.user,
          attributes: ['fullname']
      }
  });
    availability.tpCancellationReason = reason;
    await availability.save();
    const recruiterId = availability.bookedBy;
    const userRecord = await db.user.findByPk(recruiterId)
    if (!userRecord?.isNotificationDisabled) {
        const io = getIo();
        const connectedUsers = getConnectedUsers();
        const name = availability?.user?.fullname
        const createdAt = new Date().toISOString()
        let description = ""
        if(reason) {
          description = `${name} has raised cancellation request for`
        }
        else {
          description = `${name} has withdrawn cancellation request for`
        }
        const notification = await db.notification.create({userId: recruiterId, description: description, datetime: availability.datetime, createdAt, type: "cancel_request_event"})
        io.to(connectedUsers.get(recruiterId)).emit('EVENT_CANCEL_REQUEST_OR_WITHDRAWN_REQUEST_BY_TP', { id: notification.id, description: description, datetime: availability.datetime, createdAt, type: "cancel_request_event"})
    }
    return res.status(200).json({ message: reason ? 'Cancellation Request Raised' : "Cancellation Request Withdrawn", success: true });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};


exports.checkExistingSlots = async (req, res) => {
  try {
    const { tpId, dateTimeSlots, email } = req.body;
    const userId = req.user.userId;

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
          ]
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


    if (existingSlots.length > 0 || existingEvents.length > 0 || existingOpenSlots.length > 0) {
      return res.status(200).json({ existingEvents, existingSlots, newSlots, existingOpenSlots,success: true });
    }

    const entries = newSlots.map((item) => ({ tpId: req.user.userId, datetime: item.startTime, endtime: item.endTime }));
    await db.availability.bulkCreate(entries);
    return res.status(200).json({ success: true, message: 'Slots Saved Successfully', newSlots: newSlots });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
}


exports.saveSlot = async (req, res) => {
  try {
    const { tpId, dateTimeSlots } = req.body;
    const enteries = dateTimeSlots.map((item) => ({ tpId: req.user.userId, datetime: item.startTime, endtime: item.endTime }));
    await db.availability.bulkCreate(enteries);
    res.status(201).json({ success: true, message: 'Slots Saved Successfully' });
  }
  catch (error) {
    res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};