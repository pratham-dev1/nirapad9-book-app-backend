module.exports = (sequelize, DataTypes) => {
    const Timesheet = sequelize.define("timesheet", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        projectId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        weekStartDate: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        weekEndDate: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        totalHours: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        status: {
            type: DataTypes.STRING,
            // allowNull: false,
        },
        remarks: {
            type: DataTypes.STRING,
            // allowNull: false,
        },
    }, {
        timestamps: false
    });

    return Timesheet;
};
