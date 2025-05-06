module.exports = (sequelize, DataTypes) => {
    const Institution = sequelize.define("institution", {
        institutionName: {
            type: DataTypes.STRING,
        },
    }, {
        tableName: 'institution',
        timestamps: false
    });

    return Institution;
};
