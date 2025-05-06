module.exports = (sequelize, DataTypes) => {
    const communicationStatus = sequelize.define("crm_internal_communication_status", {
        status: {
            type: DataTypes.STRING,
            allowNull: false,
        },
    }, {
        timestamps: false,
        freezeTableName: true,
    });

    return communicationStatus;
};
