module.exports = (sequelize, DataTypes) => {
  const openAvailability = sequelize.define("open_availability", {
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    datetime: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    endtime: {
      type: DataTypes.STRING,
    },
    booked: {
      type: DataTypes.BOOLEAN,
      allowNull: false, 
      defaultValue: false
    },
    meetingPurpose: {
      type: DataTypes.STRING,
    },
    receiverEmail: {
      type: DataTypes.STRING,
    },
    receiverName: {
      type: DataTypes.STRING,
    },
    receiverPhone: {
      type: DataTypes.STRING,
    },
    eventType: {
      type: DataTypes.STRING,
    },
    senderEmail: {
      type: DataTypes.STRING,
    },
    emailServiceProvider: {
      type: DataTypes.STRING,
    },
    meetingLink: {
      type: DataTypes.TEXT
    },
    tagId: {
      type: DataTypes.INTEGER
    },
    eventId: {
      type: DataTypes.STRING,
    },
    statusId: {
      type: DataTypes.INTEGER, 
      defaultValue: 1
    },
    comments: {
      type: DataTypes.TEXT
    },
    tagTypeId: {
      type: DataTypes.STRING
    },
    isCancelled: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    meetType: {
      type: DataTypes.INTEGER
    },
    guestTimezone : {
      type: DataTypes.STRING
    },
    houseNo: {
      type: DataTypes.STRING
    },
    houseName: {
      type: DataTypes.STRING
    },
    street: {
      type: DataTypes.STRING
    },
    area: {
      type: DataTypes.STRING
    },
    state: {
      type: DataTypes.INTEGER
    },
    city: {
      type: DataTypes.INTEGER
    },
    pincode: {
      type: DataTypes.STRING
    },
    landmark: {
      type: DataTypes.STRING
    },
    mapLink: {
      type: DataTypes.STRING
    },
    isBookedSlotUpdated: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    isAcceptedByOwner: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    bookedAt: {
      type: DataTypes.STRING,
    },
    isEmailReminderSent: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    rescheduleReason: {
      type: DataTypes.STRING
    }
  },{
    timestamps:false,
  });

  return openAvailability;
};
