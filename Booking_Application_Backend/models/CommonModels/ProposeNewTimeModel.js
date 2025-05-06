module.exports = (sequelize, DataTypes) => {
    const ProposeNewModel = sequelize.define("propose_new_time", {
        eventId: {
            type: DataTypes.STRING,
        },
        userId: {
            type: DataTypes.INTEGER
        },
        email: {
            type: DataTypes.STRING,
        },
        startTime: {
            type: DataTypes.STRING,
        },
        endTime: {
            type: DataTypes.STRING,
        },
        comment: {
            type: DataTypes.STRING
        },
        isRejected: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        eventIdAcrossAllCalendar: {
            type: DataTypes.STRING
        }
    }, {
        timestamps: false
    });

    return ProposeNewModel;
};
