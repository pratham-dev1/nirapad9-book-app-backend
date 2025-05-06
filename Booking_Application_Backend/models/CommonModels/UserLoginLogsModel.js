module.exports = (sequelize, DataTypes) => {
    const CredentialBlockedLogs = sequelize.define("user_login_log", {
        userId: {
            type: DataTypes.INTEGER,
        },
        createdAt: {
            type: DataTypes.STRING
        },
        isCredentialsDisabled: {
            type: DataTypes.BOOLEAN
        },
        credentialDisabledTimeStamp: {
            type: DataTypes.STRING 
        },
        credentialEnabledTimeStamp: {
            type: DataTypes.STRING
        },
        lastLoginTried: {
            type: DataTypes.STRING
        }
    }, {
        timestamps: false
    });

    return CredentialBlockedLogs;
};
