module.exports = (sequelize, DataTypes) => {
    const Faq = sequelize.define("faq", {
        question: {
            type: DataTypes.TEXT,
            allowNull: false,
        },
        answer: {
            type: DataTypes.TEXT,
            allowNull: false,
        },
        type: {
            type: DataTypes.STRING,
        }
    }, {
        timestamps: false,
        tableName: 'faq'
    });

    return Faq;
};