module.exports = (sequelize, DataTypes) => {
    const Countries = sequelize.define("countries", {
        name: {
            type: DataTypes.STRING,
        },
    }, {
        tableName: 'countries',
        timestamps: false
    });

    return Countries;
};
