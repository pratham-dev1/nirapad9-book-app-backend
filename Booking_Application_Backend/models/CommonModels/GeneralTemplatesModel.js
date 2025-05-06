module.exports = (sequelize, DataTypes) => {
    const GeneralTemplate = sequelize.define("general_template", {
        name: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        template: {
            type: DataTypes.TEXT,
            allowNull: false,
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

    return GeneralTemplate;
};
