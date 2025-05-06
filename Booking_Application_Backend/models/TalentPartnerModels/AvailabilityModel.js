module.exports = (sequelize, DataTypes) => {
  const Availability = sequelize.define("availability", {
    tpId: {
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
    candidateId: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    interviewStatus: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    booked: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false
    },
    bookedBy: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    formLink: {
      type: DataTypes.TEXT
    },
    meetingLink: {
      type: DataTypes.TEXT
    },
    isCancelled: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    cancelReasonByRecruiter: {
      type: DataTypes.TEXT,
    },
    recordTime: {
      type: DataTypes.INTEGER
    },
    recordTimeComments: {
      type: DataTypes.STRING
    },
    isRecordTimeSubmitted: {
      type: DataTypes.BOOLEAN
    },
    tpCancellationReason: {
      type: DataTypes.TEXT
    },
  }, {
    timestamps: false,
  });

  return Availability;
};
