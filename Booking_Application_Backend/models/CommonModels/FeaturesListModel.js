module.exports = (sequelize, DataTypes) => {
    const FeaturesList = sequelize.define("features_list", {
        featureName: {
            type: DataTypes.STRING,
            allowNull: false,
        }
    }, {
        timestamps: false,
        tableName: 'features_list'
    });

    return FeaturesList;
};