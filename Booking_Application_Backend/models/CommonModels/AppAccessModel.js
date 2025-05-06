module.exports = (sequelize, DataTypes) => {
    const AppAccess = sequelize.define("app_access", {
        userId: {
            type: DataTypes.INTEGER
        },
        applicationId: {
            type: DataTypes.STRING
        }
    }, {
        timestamps: false,
        tableName: 'app_access'
    });

    return AppAccess;
};
