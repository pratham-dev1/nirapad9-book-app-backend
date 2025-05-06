module.exports = (sequelize, DataTypes) => {
    const Notification = sequelize.define("notification", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        description: {
            type: DataTypes.TEXT
        },
        datetime: {
            type: DataTypes.STRING
        },
        createdAt: {
            type: DataTypes.STRING
        },
        type: {
            type: DataTypes.STRING
        },
        isRead: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        meetingLink: {
            type: DataTypes.STRING
        },
        creator: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        eventId: {
            type: DataTypes.STRING
        }, 
        title: {
            type: DataTypes.STRING
        },
        source: {
            type: DataTypes.STRING
        },
        openAvailabilityId: {
            type: DataTypes.INTEGER
        },
        emailAccount: {
            type: DataTypes.STRING
        },
        eventIdAcrossAllCalendar: {         //unique id for all events across all type of calendar (eg. google, microsoft, etc)
            type: DataTypes.STRING,
        }
    }, {
        timestamps: false
    });

    return Notification;
};
