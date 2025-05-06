module.exports = (sequelize, DataTypes) => {
    const Organization = sequelize.define("organization", {
        organization: {
            type: DataTypes.STRING,
        },
    }, {
        timestamps: false
    });

    return Organization;
};
