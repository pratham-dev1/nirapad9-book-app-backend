module.exports = (sequelize, DataTypes) => {
    const LinkedInCommunicationStatus = sequelize.define("crm_internal_linkedIn_communication_status", {
        status: {
            type: DataTypes.STRING,
            allowNull: false,
        },
    }, {
        timestamps: false,
        freezeTableName: true,
    });

    return LinkedInCommunicationStatus;
};
