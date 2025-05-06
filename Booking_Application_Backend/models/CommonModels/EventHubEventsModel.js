module.exports = (sequelize, DataTypes) => {
    const EventHubEvents = sequelize.define("event_hub_events", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        startTime: {
            type: DataTypes.STRING,
        },
        endTime: {
            type: DataTypes.STRING,
        },
        title: {
            type: DataTypes.STRING,
        },
        senderEmail: {
            type: DataTypes.STRING,
        },
        attendees: {
            type: DataTypes.TEXT,
        },
        meetingLink: {
            type: DataTypes.TEXT,
        },
        eventId: {
            type: DataTypes.TEXT,
        },
        eventDurationInMinutes: {
            type: DataTypes.INTEGER,
        },
        eventTypeId: {
            type: DataTypes.INTEGER,
        },
        emailTemplate: {
            type: DataTypes.TEXT,
        },
        isCancelled: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        meetType: {
            type: DataTypes.INTEGER,
        },
    }, {
        tableName: 'event_hub_events',
        timestamps: false
    });
 
    return EventHubEvents;
};