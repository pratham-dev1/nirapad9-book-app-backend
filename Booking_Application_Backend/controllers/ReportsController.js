const db = require("../models");


exports.getEndUserReports = async (req, res) => {
  try {
    const { page, pageSize, sortingOrder, sortingColumn, startDateFilter, endDateFilter, bookedFilter ,tagId} = req.query;

    const offset = page * pageSize;

    let filter = {
      userId: req.user.userId
    };

      if (startDateFilter) {
      const endDate = endDateFilter ? new Date(endDateFilter) : null;

      if (endDate) {
        // Reduce 30 minutes
         endDate.setMinutes(endDate.getMinutes() - 30);
        // Convert back to string
      const newDateString = endDate.toISOString();

        filter.datetime = {
          [db.Sequelize.Op.and]: [

            { [db.Sequelize.Op.gte]: startDateFilter},

            { [db.Sequelize.Op.lte]:newDateString },
         
          ]
        };
      } else {
        filter.datetime = {
          [db.Sequelize.Op.gte]: startDateFilter,
        };
      }
    }

    if(tagId){
      filter.tagId=tagId
    }

    if (bookedFilter) {
      filter.booked = bookedFilter
    }

    const response = await db.open_availability.findAndCountAll({
      where: filter,
      limit: +pageSize,
      offset: +offset,
      order: [[sortingColumn, sortingOrder]],
      distinct: true, 
      include: [
        {
          model: db.open_availability_tags,
          as: 'tagData',
          attributes: ['tagName'], 
        },
        {
          model: db.event,
          attributes: ['attendees'], 
         
        }
      ]
     });

    res.status(200).json({ success: true, data: response.rows, totalCount: response.count });

  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};



exports.getProductOwnerReports = async (req, res) => {
  try {
    const {eventId,organizationId, page, pageSize, sortingOrder, sortingColumn, startDateFilter, endDateFilter, bookedFilter} = req.query;

    const offset = page * pageSize;

    let filter = {
      userId: req.user.userId
    };

    if (startDateFilter) {
      const endDate = endDateFilter ? new Date(endDateFilter) : null;

      if (endDate) {
        // Reduce 30 minutes
         endDate.setMinutes(endDate.getMinutes() - 30);
        // Convert back to string
      const newDateString = endDate.toISOString();

  // Same extraction for newDateString

const startTime = startDateFilter.substring(11, 19); // Extract 'HH:MM:SS' from 'YYYY-MM-DDTHH:MM:SSZ'
const endTime = newDateString.substring(11, 19);     // Extract 'HH:MM:SS' from newDateString

filter.datetime = {
  [db.Sequelize.Op.and]: [
    // Date range condition
    {
      [db.Sequelize.Op.gte]: startDateFilter,
      [db.Sequelize.Op.lte]: newDateString
    },

    // Time-only condition with proper casting to timestamp
    db.Sequelize.where(
      db.Sequelize.fn('TO_CHAR', db.Sequelize.cast(db.Sequelize.col('datetime'), 'timestamp'), 'HH24:MI:SS'),
      { [db.Sequelize.Op.gte]: startTime }
    ),
    db.Sequelize.where(
      db.Sequelize.fn('TO_CHAR', db.Sequelize.cast(db.Sequelize.col('datetime'), 'timestamp'), 'HH24:MI:SS'),
      { [db.Sequelize.Op.lte]: endTime }
    )
  ]
};    
    } else {
      filter.datetime = {
        [db.Sequelize.Op.and]: [
          // Date range condition
          {
            [db.Sequelize.Op.gte]: startDateFilter,
          },
      
          // Time-only condition with proper casting to timestamp
          db.Sequelize.where(
            db.Sequelize.fn('TO_CHAR', db.Sequelize.cast(db.Sequelize.col('datetime'), 'timestamp'), 'HH24:MI:SS'),
            { [db.Sequelize.Op.gte]: startTime }
          ),
          
        ]
      };
      
    }
  }

    if(eventId){
      filter.eventId=eventId
    }

    if (bookedFilter) {
      filter.booked = bookedFilter
    }

    const userFilter = {};

    // Check if organizationId has a value
   if (organizationId) {
     userFilter.organizationId = organizationId; // Add organizationId to the filter if it exists
   }

    const response = await db.open_availability.findAndCountAll({
      where: filter,
      limit: +pageSize,
      offset: +offset,
      order: [[sortingColumn, sortingOrder]],
      distinct: true, 
      include: [
        {
          model: db.open_availability_tags,
          as: 'tagData',
          attributes: ['tagName'], 
        },
        {
        model: db.user,
        attributes:['organizationId'],
        where: userFilter,
        include:[
          {
            model:db.organization,
            attributes:['organization'],
            as: "organization"
          }
         ] 
        },
        {
          model: db.event,
          attributes: ['attendees'], 
        }
      ]
     });

    res.status(200).json({ success: true, data: response.rows, totalCount: response.count });

  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};


exports.getOpenAvailabilityReportsSchema = async (req, res) => {
  try {
   const openAvailabilitySchema = await db.open_availability.describe();
   const openAvailabilityTagsSchema = await db.open_availability_tags.describe();
   const userSchema = await db.user.describe();
   const organizationSchema = await db.organization.describe();
   const eventSchema = await db.event.describe();

   const mapSchema = (schema, tableName) => {
     return Object.keys(schema).map((columnName, index) => ({
       id: index + 1,
       columnName,
       tableName
     }));
   };

   const response = [
     ...mapSchema(openAvailabilitySchema, 'open_availabilities'),
     ...mapSchema(openAvailabilityTagsSchema, 'open_availability_tags'),
     ...mapSchema(userSchema, 'users'),
     ...mapSchema(organizationSchema, 'organizations'),
     ...mapSchema(eventSchema, 'events'),
   ];

    res.status(200).json({ success: true, data: response, totalCount: response.count });

  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};


const updateDateFilters=(modelData)=>{
  if(!modelData.filter) return 

  const {startDateFilter,endDateFilter,startTime,endTime}=modelData.filter
  if (startDateFilter) {
    const endDate = endDateFilter ? new Date(endDateFilter) : null;

    if (endDate) {
      // Reduce 30 minutes
       endDate.setMinutes(endDate.getMinutes() - 30);
      // Convert back to string
    const newDateString = endDate.toISOString();

// Same extraction for newDateString

const modifiedStartTime = startTime ? startTime.substring(11, 19) : startDateFilter.substring(11, 19); // Extract 'HH:MM:SS' from 'YYYY-MM-DDTHH:MM:SSZ'
const modifiedEndTime = endTime ? endTime.substring(11,19):newDateString.substring(11, 19);     // Extract 'HH:MM:SS' from newDateString

modelData.filter.datetime = {
[db.Sequelize.Op.and]: [
  // Date range condition
  {
    [db.Sequelize.Op.gte]: startDateFilter,
    [db.Sequelize.Op.lte]: newDateString
  },

  // Time-only condition with proper casting to timestamp
  db.Sequelize.where(
    db.Sequelize.fn('TO_CHAR', db.Sequelize.cast(db.Sequelize.col('datetime'), 'timestamp'), 'HH24:MI:SS'),
    { [db.Sequelize.Op.gte]: modifiedStartTime }
  ),
  db.Sequelize.where(
    db.Sequelize.fn('TO_CHAR', db.Sequelize.cast(db.Sequelize.col('datetime'), 'timestamp'), 'HH24:MI:SS'),
    { [db.Sequelize.Op.lte]: modifiedEndTime }
  )
]
};    
  } else {
    modelData.filter.datetime = {
      [db.Sequelize.Op.and]: [
        // Date range condition
        {
          [db.Sequelize.Op.gte]: startDateFilter,
        },
    
        // Time-only condition with proper casting to timestamp
        db.Sequelize.where(
          db.Sequelize.fn('TO_CHAR', db.Sequelize.cast(db.Sequelize.col('datetime'), 'timestamp'), 'HH24:MI:SS'),
          { [db.Sequelize.Op.gte]: modifiedStartTime }
        ),
        
      ]
    };
    
  }
}
}


exports.getOpenAvailabilityReports = async (req, res) => {
  try {
    const { page, pageSize, tableData } = req.query;
    const { open_availabilities, open_availability_tags, users, events, organizations } = tableData;

    const offset = page * pageSize;
    
    updateDateFilters(open_availabilities)

    let openAvailabilityFilter = {
      userId: req.user.userId,
      ...open_availabilities?.filter ?? {},
    

    };


    const includeArray = [];

    if (open_availability_tags && Object.keys(open_availability_tags).length > 0) {
      includeArray.push({
        model: db.open_availability_tags,
        as: 'tagData',
        attributes: open_availability_tags.attributes ?? [],
        where: open_availability_tags.filter ?? {}
      });
    }

    if (users && Object.keys(users).length > 0) {
      const userInclude = {
        model: db.user,
        attributes: users.attributes ?? [],
        where: users.filter ?? {},
      };

      if (organizations && Object.keys(organizations).length > 0) {
        userInclude.include = [
          {
            model: db.organization,
            attributes: organizations.attributes ?? [],
            where: organizations.filter ?? {},
            as: "organization"
          }
        ];
      }

      includeArray.push(userInclude);
    }

    if (events && Object.keys(events).length > 0) {
      includeArray.push({
        model: db.event,
        attributes: events.attributes ?? [],
        where: events.filter ?? {}
      });
    }

    const responseData = await db.open_availability.findAndCountAll({
      where: openAvailabilityFilter,
      limit: +pageSize,
      offset: +offset,
      attributes: open_availabilities?.attributes ?? [],
      include: includeArray 
    });

    const getAttendeesCount = (attendees) => attendees.split(",").length;

    const response = responseData.rows.map((eachResponse) => {
      const { tagData, user, events, attendees, ...rest } = eachResponse.toJSON();

      const { organization, ...restUser } = user || {};

      const attendeesCount = attendees ? getAttendeesCount(attendees) : undefined;

      return {
        ...tagData,
        ...restUser,
        ...(organization && { ...organization }),
        ...(events?.[0] && { ...events[0] }),
        ...(eachResponse.booked !== undefined && { booked: eachResponse.booked ? "Booked" : "Not Booked" }),
        ...(attendeesCount !== undefined && { attendeesCount }),
        ...rest,
      };
    });

    res.status(200).json({ success: true, data: response, totalCount: responseData.count });

  } catch (error) {
    return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
  }
};

