const jwt = require("jsonwebtoken");
const db = require("../../models");
const secretKey = 'yourSecretKey';

const VerifyAccessToken = (req, res, next) => {
    try {
        const token = req.cookies.accessToken;
        if (!token) {
            throw { statusCode: 401, message: "Authorization token is missing" }
        }
        jwt.verify(token, secretKey, async(err, user) => {
            if (err) {
                return res.status(401).json({ error: true, message: "Some Error Occured" });
                // throw { statusCode: 401, message: "Invalid or expired token" }
            }
            const userData = await db.user.findByPk(user.userId);
            if (userData?.isDeleted) {
               return res.status(403).json({ error: true, reason: 'Account Deleted', message: "Some Error Occured or Your account has been deleted. Contact to admin" });
            }
            if (userData?.lastPasswordUpdatedForSecurity != user?.lastPasswordUpdatedForSecurity) {
                return res.status(403).json({ error: true, reason: 'Password Changed For Security', message: "Your password has been updated" });
            }
            if((userData?.freeSubscriptionExpiration && (new Date() > new Date(userData?.freeSubscriptionExpiration)))) {
                userData.freeSubscriptionExpiration = null;
                userData.isFreeTrialOver = true;
                await userData.save();
                return res.status(403).json({ error: true, reason: 'Free Subscription Over', message: "Your 5 days Free trial is over now - Buy a subscription" });
            }
            if(userData?.isCredentialsDisabled) {
               return res.status(403).json({ error: true, reason: 'Credentials Blocked', message: "Your Credentials has been Blocked. Contact to admin" });
            }
            req.user = user;
            next()
        });
    }
    catch (error) {
        return res.status(error.statusCode || 500).json({ error: true, message: error.message || 'Something went wrong' });

    }
}


module.exports = { VerifyAccessToken };