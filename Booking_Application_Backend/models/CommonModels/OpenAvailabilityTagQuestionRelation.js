module.exports = (sequelize, DataTypes) => {
    const openAvailabilityTagQuestion = sequelize.define("open_availability_question", {
        openAvailabilityTagId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        questionId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        required: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        }
    }, {
        timestamps: false
    });
    return openAvailabilityTagQuestion;
};
