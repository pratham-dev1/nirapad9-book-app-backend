module.exports = (sequelize, DataTypes) => {
    const Designation = sequelize.define("designation", {
        designation: {
            type: DataTypes.STRING,
        },
    }, {
        timestamps: false
    });

    return Designation;
};
