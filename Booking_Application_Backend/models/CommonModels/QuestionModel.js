module.exports = (sequelize, DataTypes) => {
    const Question = sequelize.define("question", {
        question: {
            type: DataTypes.STRING,
        },
        userId: {
            type: DataTypes.INTEGER,
        },
        type: {
            type: DataTypes.STRING,
        },
        option1: {
            type: DataTypes.STRING,
        },
        option2: {
            type: DataTypes.STRING,
        },
        option3: {
            type: DataTypes.STRING,
        },
        option4: {
            type: DataTypes.STRING,
        },
        option5: {
            type: DataTypes.STRING,
        },
    }, {
        timestamps: false
    });

    return Question;
};
