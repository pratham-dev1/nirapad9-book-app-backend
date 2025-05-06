module.exports = (sequelize, DataTypes) => {
    const Otp = sequelize.define("otp", {
        email: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        otp: {
            type: DataTypes.INTEGER
        }
        
    }, {
        timestamps: false
    });

    return Otp;
};
