module.exports = (sequelize, DataTypes) => {
    const EventDraft = sequelize.define("event_draft", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false, 
        },
        title: {
            type: DataTypes.STRING,
            allowNull: false, 
        },
        draftName: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        requiredGuests: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        optionalGuests: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        date: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        startTime: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        eventTime: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        senderEmail: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        template: {
            type: DataTypes.TEXT,
            allowNull: false,
        },
        eventTypeId: {
            type: DataTypes.INTEGER
        },
        recurrence: {
            type: DataTypes.STRING,
        },
        recurrenceRepeat: {
            type: DataTypes.STRING,
        },
        recurrenceEndDate: {
            type: DataTypes.STRING,
        },
        recurrenceCount: {
            type: DataTypes.STRING,
        },
        recurrenceNeverEnds: {
            type: DataTypes.BOOLEAN,
        },
        recurrenceDays: {
            type: DataTypes.TEXT,
        },       
        predefinedMeetId: {
            type: DataTypes.INTEGER,
        },
        descriptionCheck: {
            type: DataTypes.BOOLEAN,
            defaultValue: true
        },
        emailCheck: {
            type: DataTypes.BOOLEAN,
            defaultValue: true
        },
        hideGuestList: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        isEmailDeleted: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        }
    }, {
        timestamps: false
    });

    return EventDraft;
};
