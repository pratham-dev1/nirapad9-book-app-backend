module.exports = (sequelize, DataTypes) => {
    const PredefinedMeet = sequelize.define("predefined_meet", {
        userId: {
            type: DataTypes.INTEGER
        },
        title: {
            type: DataTypes.STRING,
        },
        type: {
            type: DataTypes.INTEGER,
        },
        location: {
            type: DataTypes.INTEGER,
        },
        url: {
            type: DataTypes.STRING,
        },
        address: {
            type: DataTypes.STRING,
        },
        phone: {
            type: DataTypes.STRING,
        },
        passcode: {
            type: DataTypes.STRING,
        },
    }, {
        timestamps: false
    });

    return PredefinedMeet;
};
