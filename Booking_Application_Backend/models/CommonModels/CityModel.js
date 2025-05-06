module.exports = (sequelize, DataTypes) => {
    const Cities = sequelize.define("cities", {
        name: {
            type: DataTypes.STRING,
        },
        stateId: {
            type: DataTypes.INTEGER,
        }
    }, {
        tableName: 'cities',
        timestamps: false
    });

    return Cities;
};
