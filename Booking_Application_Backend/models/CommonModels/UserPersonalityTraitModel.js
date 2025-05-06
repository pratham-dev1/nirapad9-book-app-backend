module.exports = (sequelize, DataTypes) => {
    const UserPersonalityTrait = sequelize.define("user_personality_trait", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        collaboration:{
            type: DataTypes.INTEGER,
        },
        communication:{
            type: DataTypes.INTEGER,
        },
        criticalThinking:{
            type: DataTypes.INTEGER,
        },
        resilience:{
            type: DataTypes.INTEGER,
        },
        empathy:{
            type: DataTypes.INTEGER,
        },
    },{
      timestamps:false,
    });
  
    return UserPersonalityTrait;
  };
  