module.exports = (sequelize, DataTypes) => {
    const PasswordVerificationKey = sequelize.define("password_verification_key", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        passwordVerificationKey: {
            type: DataTypes.STRING,
            allowNull: false
        }
    }, {
        timestamps: false
    });

    return PasswordVerificationKey;
};