module.exports = (sequelize, DataTypes) => {
    const UserVerification = sequelize.define("user_verification", {
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        email: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        isAccountVerified: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: false
        },
        accountVerifyKey: {
            type: DataTypes.STRING
        }
    }, {
        timestamps: false
    });

    return UserVerification;
};
