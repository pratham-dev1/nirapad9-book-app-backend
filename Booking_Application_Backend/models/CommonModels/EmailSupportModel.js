module.exports = (sequelize, DataTypes) => {
    const EmailSupport = sequelize.define("email_support", {
        userId: {
            type: DataTypes.INTEGER,
        },
        categoryId: {
            type: DataTypes.INTEGER,
        },
        text: {
            type: DataTypes.TEXT,
        }
    }, {
        timestamps: false
    });

    return EmailSupport;
};
