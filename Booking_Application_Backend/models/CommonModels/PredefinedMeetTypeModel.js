module.exports = (sequelize, DataTypes) => {
    const PredefinedMeetType = sequelize.define("predefined_meet_type", {
        value: {
            type: DataTypes.STRING,
            allowNull: false,
        }
    }, {
        timestamps: false
    });

    return PredefinedMeetType;
};
