module.exports = (sequelize, DataTypes) => {
    const EmailSupportCategory = sequelize.define("email_support_category", {
        name: {
            type: DataTypes.STRING,
        },
    }, {
        timestamps: false
    });

    return EmailSupportCategory;
};
