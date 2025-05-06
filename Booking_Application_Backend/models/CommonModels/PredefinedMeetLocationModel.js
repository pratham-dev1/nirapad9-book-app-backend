module.exports = (sequelize, DataTypes) => {
    const PredefinedMeetLocation = sequelize.define("predefined_meet_location", {
        value: {
            type: DataTypes.STRING,
            allowNull: false,
        }
        
    }, {
        timestamps: false
    });

    return PredefinedMeetLocation;
};
