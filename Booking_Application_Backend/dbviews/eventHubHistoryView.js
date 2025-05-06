module.exports = (sequelize, DataTypes) => {
    const EventHubHistoryView = sequelize.define("event_hub_history_views", {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            // autoIncremennt: true
        },
        eventId: {
            type: DataTypes.STRING,
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
        meetingLink: {
            type: DataTypes.TEXT
        },
        emailAccount: {
            type: DataTypes.STRING,
        },
        userId: {
            type: DataTypes.INTEGER,
        },
        senderEmail: {
            type: DataTypes.STRING,
        },
        isDeleted: {
            type: DataTypes.BOOLEAN,
        },
        isCancelled: {
            type: DataTypes.BOOLEAN,
        },
        attendees: {
            type: DataTypes.TEXT,
        },
        seriesMasterId: {
            type: DataTypes.STRING,
        },
        creatorFlag: {
            type: DataTypes.BOOLEAN,
        },
        source: {
            type: DataTypes.TEXT,
        },
        sourceId: {
            type: DataTypes.INTEGER,
        },
        senderEmailServiceProvider: {
            type: DataTypes.STRING,
        },
        eventDurationInMinutes: {
            type: DataTypes.INTEGER
        },
        eventTypeId: {
            type: DataTypes.INTEGER
        },
        eventTypeValue: {
            type: DataTypes.STRING
        },
        eventIdAcrossAllCalendar: {         //unique id for all events across all type of calendar (eg. google, microsoft, etc)
            type: DataTypes.STRING,
        },
        isMicrosoftParentRecurringEvent: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        meetType: {
            type: DataTypes.INTEGER
        }
    }, {
        timestamps: false
    });

    return EventHubHistoryView;
};