module.exports = (sequelize, DataTypes) => {
    const UserType = sequelize.define("user_type", {
      userType: {
        type: DataTypes.STRING,
        allowNull: false,
      },
    },{
      timestamps:false,
    });
  
    return UserType;
  };
  