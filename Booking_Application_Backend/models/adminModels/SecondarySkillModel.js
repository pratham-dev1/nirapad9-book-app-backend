module.exports = (sequelize, DataTypes) => {
    const SecondarySkill = sequelize.define("secondary_skill", {
      secondarySkillName: {
        type: DataTypes.STRING,
        allowNull: false,
      },
    },{
      timestamps:false,
    });
  
    return SecondarySkill;
  };
  