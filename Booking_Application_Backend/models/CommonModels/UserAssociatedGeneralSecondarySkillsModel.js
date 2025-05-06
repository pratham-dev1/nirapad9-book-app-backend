module.exports = (sequelize, DataTypes) => {
    const userAssociatedGeneralSecondarySkills = sequelize.define("user_associated_general_secondary_skills", {
        secondarySkillName: {
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

    return userAssociatedGeneralSecondarySkills;
};
