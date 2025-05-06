module.exports = (sequelize, DataTypes) => {
    const userSuggestedDesignation = sequelize.define("user_suggested_designation", {
        designation: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
          },
    }, {
        tableName: 'user_suggested_designation',
        timestamps: false
    });

    return userSuggestedDesignation;
};
