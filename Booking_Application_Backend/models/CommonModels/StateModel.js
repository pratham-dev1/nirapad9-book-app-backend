module.exports = (sequelize, DataTypes) => {
    const States = sequelize.define("states", {
        name: {
            type: DataTypes.STRING,
        },
        countryId: {
            type: DataTypes.INTEGER,
        }
    }, {
        tableName: 'states',
        timestamps: false
    });

    return States;
};
