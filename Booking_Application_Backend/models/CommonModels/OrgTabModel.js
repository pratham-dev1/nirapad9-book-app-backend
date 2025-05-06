module.exports = (sequelize, DataTypes) => {
    const OrgTabs = sequelize.define("org_tab_name", {
        tabId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        orgId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },        
        tabNameOrgGiven: {
            type: DataTypes.STRING,
            allowNull: false,
        },
    }, {
        timestamps: false
    });

    return OrgTabs;
};
