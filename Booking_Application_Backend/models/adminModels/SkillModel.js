module.exports = (sequelize, DataTypes) => {
    const Skill = sequelize.define("skill", {
      skillName: {
        type: DataTypes.STRING,
        allowNull: false,
      },
    },{
      timestamps:false,
    });
  
    return Skill;
  };
  