module.exports = (sequelize, DataTypes) => {
    const OpenAvailabilityFeedbackModel = sequelize.define("open_availability_feedback", {
        openAvailabilityId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        question: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        answer: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        type: {
            type: DataTypes.STRING,
        },        
    }, {
        timestamps: false
    });

    return OpenAvailabilityFeedbackModel;
};
