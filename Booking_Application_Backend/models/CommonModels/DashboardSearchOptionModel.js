module.exports = (sequelize, DataTypes) => {
  const dashboardSearchOption = sequelize.define("dashboard_search_option", {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
      allowNull: false,
    },
    category: {
      type: DataTypes.STRING,
      allowNull: false
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    path: {
      type: DataTypes.STRING,
      allowNull: false
    }
  }, {
      timestamps: false
  });
  return dashboardSearchOption;
};
