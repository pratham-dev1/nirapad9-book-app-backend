module.exports = (sequelize, DataTypes) => {
    const EventColor = sequelize.define("event_color", {
        color: {
            type: DataTypes.STRING,
        },
        theme: {
            type: DataTypes.STRING,
        },
        email_column: {
            type: DataTypes.STRING
        }
    }, {
        timestamps: false
    });

    return EventColor;
};
