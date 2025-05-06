module.exports = (sequelize, DataTypes) => {
    const Institution = sequelize.define("industry", {
        name: {
            type: DataTypes.STRING,
        },
    }, {
        timestamps: false
    });

    return Institution;
};
