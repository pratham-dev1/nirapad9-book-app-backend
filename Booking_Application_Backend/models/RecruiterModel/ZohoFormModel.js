module.exports = (sequelize, DataTypes) => {
    const ZohoForm = sequelize.define("zoho_forms", {
      formName: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      link: {
        type: DataTypes.STRING,
        allowNull: false,
      },
    },{
      timestamps:false,
    });
  
    return ZohoForm;
  };
  