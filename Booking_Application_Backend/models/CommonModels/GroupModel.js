module.exports = (sequelize, DataTypes) => {
    const Group = sequelize.define("group", {
        name: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        createdBy: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        createdAt: {
            type: DataTypes.STRING,
        },
        description: {
            type: DataTypes.STRING,
        },
        adminName: {
            type: DataTypes.STRING,
        },
        addMe: {
            type: DataTypes.BOOLEAN,
            defaultValue: false
        }
    }, {
        timestamps: false
    });

    return Group;
};
