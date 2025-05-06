module.exports = (sequelize, DataTypes) => {
    const CrmInternalUsers = sequelize.define("crm_internal_users", {
        username: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        fullname: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        email: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        userTypeId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
    }, {
        timestamps: false,
    });

    return CrmInternalUsers;
};
