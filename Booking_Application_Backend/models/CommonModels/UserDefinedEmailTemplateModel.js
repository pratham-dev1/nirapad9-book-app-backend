module.exports = (sequelize, DataTypes) => {
    const UserDefinedEmailTemplate = sequelize.define("user_defined_email_template", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        name: {
            type: DataTypes.STRING
        },
        template: {
            type: DataTypes.TEXT
        },
        type:{
            type: DataTypes.STRING,
        },
        predefinedMeetTypeId:{
            type: DataTypes.INTEGER
        }
    }, {
        timestamps: false
    });

    return UserDefinedEmailTemplate;
};
