module.exports = (sequelize, DataTypes) => {
    const EmailCommunicationStatus = sequelize.define("crm_internal_email_communication_status", {
        status: {
            type: DataTypes.STRING,
            allowNull: false,
        },
    }, {
        timestamps: false,
        freezeTableName: true,
    });

    return EmailCommunicationStatus;
};
