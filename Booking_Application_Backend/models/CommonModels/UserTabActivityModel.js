module.exports = (sequelize, DataTypes) => {
    const UserTabActivityModel = sequelize.define("user_tab_activities", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        tabId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        startTime: {
            type: DataTypes.STRING, 
            allowNull: false,
        },
        endTime: {
            type: DataTypes.STRING, 
            allowNull: true,
        },
    }, {
        timestamps: false
    });

    return UserTabActivityModel;
};
