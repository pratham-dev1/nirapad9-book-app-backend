module.exports = (sequelize, DataTypes) => {
    const EventTypes = sequelize.define("event_types", {
        value: {
            type: DataTypes.STRING,
        },
    }, {
        tableName: 'event_types',
        timestamps: false
    });

    return EventTypes;
};
