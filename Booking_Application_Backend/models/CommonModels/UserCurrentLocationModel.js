module.exports = (sequelize, DataTypes) => {
    const UserCurrentLoaction = sequelize.define("user_current_location", {
        userId: {
            type: DataTypes.INTEGER,
        },
        currentCityId: {
            type: DataTypes.INTEGER,
        },
        addedTime: {
            type: DataTypes.DATE 
        }
    }, {
        tableName: 'user_current_location',
        timestamps: false, 
    });

    return UserCurrentLoaction;
};
