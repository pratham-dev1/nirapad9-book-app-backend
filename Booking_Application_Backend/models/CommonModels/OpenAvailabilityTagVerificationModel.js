module.exports = (sequelize, DataTypes) => {
    const openAvailabilityTagVerification = sequelize.define("open_availability_tag_verification", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        tagId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        datetime: {
            type: DataTypes.STRING
        },
        count: {
            type: DataTypes.INTEGER,
            defaultValue: 0
        },
        email: {
            type: DataTypes.STRING
        },
        parsedDate: {
            type: DataTypes.STRING
        }
    }, {
        timestamps: false
    });
    return openAvailabilityTagVerification;
};
