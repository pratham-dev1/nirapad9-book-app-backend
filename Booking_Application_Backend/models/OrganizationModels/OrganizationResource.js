module.exports = (sequelize, DataTypes) => {
  const OrganizationResource = sequelize.define("organization_resources", {
    orgId: {
      type: DataTypes.STRING(9), 
      allowNull: false,
      unique: true, 
      validate: {
        len: [9, 9] 
      }
    },
    apiKey: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: true, 
    },
    resourceId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    orgSecretKey: { 
      type: DataTypes.STRING(255), 
      allowNull: false,
    }
  }, {
    timestamps: false, 
  });

  return OrganizationResource;
};
