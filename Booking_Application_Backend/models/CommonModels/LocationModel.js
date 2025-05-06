module.exports = (sequelize, DataTypes) => {
    const Location = sequelize.define("location", {
        location: {
            type: DataTypes.STRING,
        },
    }, {
        timestamps: false
    });

    return Location;
};
