module.exports = (sequelize, DataTypes) => {
    const Project = sequelize.define("project", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        projectName: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        startDate: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        endDate: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        defaultHours: {
            type: DataTypes.INTEGER,
        },
    }, {
        timestamps: false
    });

    return Project;
};
