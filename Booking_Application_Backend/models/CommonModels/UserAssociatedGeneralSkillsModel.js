module.exports = (sequelize, DataTypes) => {
    const userAssociatedGeneralSkills = sequelize.define("user_associated_general_skills", {
        skillName: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
          },
    }, {
        timestamps: false
    });

    return userAssociatedGeneralSkills;
};
