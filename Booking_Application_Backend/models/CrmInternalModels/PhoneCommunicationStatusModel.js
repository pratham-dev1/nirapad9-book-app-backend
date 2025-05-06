module.exports = (sequelize, DataTypes) => {
    const PhoneCommunicationStatus = sequelize.define("crm_internal_phone_communication_status", {
        status: {
            type: DataTypes.STRING,
            allowNull: false,
        },
    }, {
        timestamps: false,
        freezeTableName: true,
    });

    return PhoneCommunicationStatus;
};
