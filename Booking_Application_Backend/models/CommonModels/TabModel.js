module.exports = (sequelize, DataTypes) => {
    const Tabs = sequelize.define("tab_name", {
        userTypeId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        tabName: {
            type: DataTypes.STRING,
            allowNull: false,
        },
    }, {
        timestamps: false
    });

    return Tabs;
};
