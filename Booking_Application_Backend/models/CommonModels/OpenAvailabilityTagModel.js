module.exports = (sequelize, DataTypes) => {
    const openAvailabilityTag = sequelize.define("open_availability_tag", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        tagName: {
            type: DataTypes.STRING,
            allowNull: false
        },
        defaultEmail: {
            type: DataTypes.STRING
        },
        isDeleted: {
            type: DataTypes.BOOLEAN
        },
        openAvailabilityText: {
            type: DataTypes.STRING,
        },
        template: {
            type: DataTypes.TEXT,
        },
        eventDuration: {
            type: DataTypes.INTEGER,
            defaultValue: 30
        },
        eventTypeId: {
            type: DataTypes.INTEGER 
        },
        isAllowedToAddAttendees: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        isEmailDeleted: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        image: {
            type: DataTypes.STRING,
        },
        title: {
            type: DataTypes.STRING,
        },
        showCommentBox: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        isPrimaryEmailTag: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        meetType: {
            type: DataTypes.INTEGER,
            defaultValue: 1                        // video type
        },
        emailVisibility: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
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
        country: {
            type: DataTypes.INTEGER
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
    }, {
        timestamps: false
    });
    return openAvailabilityTag;
};
