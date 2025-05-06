module.exports = (sequelize, DataTypes) => {
    const userIps = sequelize.define("user_ip", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        ip: {
            type: DataTypes.STRING
        },
        loggedTime: {
            type: DataTypes.STRING
        },
        ipLocation: {
            type: DataTypes.STRING
        }
    }, {
        timestamps: false
    });

    return userIps;
};
