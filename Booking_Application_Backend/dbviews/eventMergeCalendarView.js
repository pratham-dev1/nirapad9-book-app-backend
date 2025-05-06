module.exports = (sequelize, DataTypes) => {
    const EventMergeCalendarView = sequelize.define("event_merge_calendar_views", {
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
        eventColorId: {
            type: DataTypes.INTEGER,
        },
        eventColor: {
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
        isMicrosoftParentRecurringEvent: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        // isReminderSent: {
        //     type: DataTypes.BOOLEAN,
        // }
    }, {
        timestamps: false
    });

    return EventMergeCalendarView;
};