module.exports = (sequelize, DataTypes) => {
    const PowerBiReport = sequelize.define("powerbi_report", {
        reportId: {
            type: DataTypes.STRING,
        },
        userTypeId: {
            type: DataTypes.INTEGER,
        },
        parameters: {
            type: DataTypes.STRING,
        }
    }, {
        timestamps: false
    });

    return PowerBiReport;
};
