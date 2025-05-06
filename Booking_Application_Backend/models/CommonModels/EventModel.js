module.exports = (sequelize, DataTypes) => {
    const Event = sequelize.define("event", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        eventId: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        startTime: {
            type: DataTypes.STRING,
            allowNull: true,            // for non-time events
        },
        endTime: {
            type: DataTypes.STRING,
            allowNull: true,
        },
        sender: {
            type: DataTypes.STRING,
            // allowNull: false,
        },
        title: {
            type: DataTypes.STRING,
        },
        attendees: {
            type: DataTypes.TEXT,
        },
        meetingLink: {
            type: DataTypes.TEXT
        },
        emailAccount: {
            type: DataTypes.STRING,
        },
        seriesMasterId:{
            type: DataTypes.TEXT
        },
        updatedAt: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        isCancelled: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        isDeleted: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        activeFlag: {
            type: DataTypes.BOOLEAN,
        },
        eventColorId: {
            type: DataTypes.INTEGER,
        },
        eventColor: {
            type: DataTypes.STRING,
        },
        isMicrosoftParentRecurringEvent: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        isReminderSent: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        eventIdAcrossAllCalendar: {         //unique id for all events across all type of calendar (eg. google, microsoft, etc)
            type: DataTypes.STRING,
        },
        source: {
            type: DataTypes.STRING
        },
        sourceId: {
            type: DataTypes.INTEGER
        }
    }, {
        timestamps: false
    });
 
    return Event;
};