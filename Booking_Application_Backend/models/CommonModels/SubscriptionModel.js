module.exports = (sequelize, DataTypes) => {
    const Subscription = sequelize.define("subscription", {
        type: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        price: {
            type: DataTypes.INTEGER,
        },
        monthlyPriceId: {
            type: DataTypes.STRING,
        },
        yearlyPriceId: {
            type: DataTypes.STRING,
        },
        text: {
            type: DataTypes.STRING,
        }
    }, {
        timestamps: false
    });

    return Subscription;
};