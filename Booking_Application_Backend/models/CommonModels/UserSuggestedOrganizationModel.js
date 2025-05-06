module.exports = (sequelize, DataTypes) => {
    const userSuggestedOrganization = sequelize.define("user_suggested_organization", {
        organizationName: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        website:{
            type: DataTypes.STRING,
            allowNull: false,
        },
        linkedinUrl:{
            type: DataTypes.STRING
        },
        cityId : {
            type: DataTypes.INTEGER,
        },
        stateId: {
            type: DataTypes.INTEGER,
        },
        countryId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        }
    }, {
        tableName: 'user_suggested_organization',
        timestamps: false
    });

    return userSuggestedOrganization;
};
