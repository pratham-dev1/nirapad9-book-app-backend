module.exports = (sequelize, DataTypes) => {
    const Status = sequelize.define("status", {
        status: {
            type: DataTypes.STRING,
        },
    }, {
        tableName: 'status',
        timestamps: false
    });

    return Status;
};
