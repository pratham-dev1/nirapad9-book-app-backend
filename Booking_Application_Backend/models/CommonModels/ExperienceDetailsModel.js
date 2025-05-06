module.exports = (sequelize, DataTypes) => {
    const ExperienceDetails = sequelize.define("experience_details", {
        startDate: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        endDate: {
            type: DataTypes.STRING,
            allowNull: true,
        },
        isCurrent: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        organizationId: {
            type: DataTypes.INTEGER,
        },
        designationId: {
            type: DataTypes.INTEGER,
        },
        userSuggestedOrganizationId: {
            type: DataTypes.INTEGER,
        },
        userSuggestedDesignationId: {
            type: DataTypes.INTEGER,
        },
    }, {
        timestamps: false
    });

    return ExperienceDetails;
};
