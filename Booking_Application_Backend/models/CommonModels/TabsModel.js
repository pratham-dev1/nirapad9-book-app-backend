module.exports = (sequelize, DataTypes) => {
    const bookingApplicationTabs = sequelize.define("tabs", {
        tabNumbering: {
            type: DataTypes.INTEGER,
            allowNull: false,
            unique: true, 
          },
          tabName: {
            type: DataTypes.STRING,
            allowNull: false,
          },
          description: {
            type: DataTypes.STRING,
            allowNull: true,
          },
    }, {
        timestamps: false
    });

    return bookingApplicationTabs;
};
