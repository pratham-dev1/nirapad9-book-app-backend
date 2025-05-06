module.exports = (sequelize, DataTypes) => {
    const Applications = sequelize.define("application", {
        id: {
            type: DataTypes.STRING,
            primaryKey: true
        },
        name: {
            type: DataTypes.STRING
        }
    }, {
        timestamps: false
    });

    return Applications;
};
