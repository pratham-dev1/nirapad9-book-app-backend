module.exports = (sequelize, DataTypes) => {
    const Timezone = sequelize.define("timezone", {
        timezone: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        value: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        abbreviation: {
            type: DataTypes.STRING,
            allowNull: false,
        }
        
    }, {
        timestamps: false
    });

    return Timezone;
};
