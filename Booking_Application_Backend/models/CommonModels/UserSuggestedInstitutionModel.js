module.exports = (sequelize, DataTypes) => {
    const userSuggestedInstitution = sequelize.define("user_suggested_institution", {
        institutionName: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        website: {
            type: DataTypes.STRING,
        },
        cityId: {
            type: DataTypes.INTEGER,
        },
        stateId: {
            type: DataTypes.INTEGER,
        },
        countryId: {
            type: DataTypes.INTEGER,
        },
    }, {
        tableName: 'user_suggested_institution',
        timestamps: false
    });

    return userSuggestedInstitution;
};
