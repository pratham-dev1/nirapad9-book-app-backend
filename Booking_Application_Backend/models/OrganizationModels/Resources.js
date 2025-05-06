module.exports = (sequelize, DataTypes) => {
    const Resource = sequelize.define("resources", {
      resourceId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        primaryKey: true, 
        autoIncrement: true 
      },
      resourceName: {
        type: DataTypes.STRING,
        allowNull: false,
      }
    }, {
      timestamps: false, 
    });
  
    return Resource;
  };
  