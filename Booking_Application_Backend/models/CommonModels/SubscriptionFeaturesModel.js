module.exports = (sequelize, DataTypes) => {
    const SubscriptionFeature = sequelize.define("subscription_features", {
        featureId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        subscriptionId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        availability: {
            type: DataTypes.STRING,
            allowNull: false,
        },
    }, {
        timestamps: false
    });

    return SubscriptionFeature;
};