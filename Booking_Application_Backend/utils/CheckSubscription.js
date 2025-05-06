const CheckSubscription = (subscriptionId) => {
    return {
        IS_BASIC: subscriptionId === 1,
        IS_ADVANCED: subscriptionId === 2,
        IS_PROFESSIONAL: subscriptionId === 3,
        IS_ENTERPRISE: subscriptionId === 4
    }
}

module.exports = { CheckSubscription }