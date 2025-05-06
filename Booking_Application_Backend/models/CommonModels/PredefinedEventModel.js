module.exports = (sequelize, DataTypes) => {
    const PredefinedEvent = sequelize.define("predefined_event", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false, 
        },
        title: {
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
        // date: {
        //     type: DataTypes.STRING,
        //     allowNull: false,
        // },
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
        groupId: {
            type: DataTypes.STRING
        },
        count: {
            type: DataTypes.INTEGER,
        },
        predefinedMeetId: {
            type: DataTypes.INTEGER,
        },
        isEmailDeleted: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        }
    }, {
        timestamps: false
    });

    return PredefinedEvent;
};
