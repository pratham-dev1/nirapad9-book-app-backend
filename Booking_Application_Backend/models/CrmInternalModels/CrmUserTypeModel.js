module.exports = (sequelize, DataTypes) => {
    const CrmUserType = sequelize.define("crm_internal_user_type", {
      userType: {
        type: DataTypes.STRING,
        allowNull: false,
      },
    },{
      timestamps:false,
    });
  
    return CrmUserType;
  };
  