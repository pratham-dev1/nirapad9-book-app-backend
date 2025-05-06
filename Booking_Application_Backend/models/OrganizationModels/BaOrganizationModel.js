module.exports = (sequelize, DataTypes) => {
    const BaOrganization = sequelize.define("ba_organization", {
      organizationName: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      organizationLogo: {
        type: DataTypes.STRING,
      },
      isOrgDisabledTagLogo: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
      }
    },{
      timestamps:false,
    });
  
    return BaOrganization;
  };
  