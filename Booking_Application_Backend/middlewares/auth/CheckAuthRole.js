const CheckAuthRole = (requiredRoles) => {
    return (req, res, next) => {
        let userRole = req.user.role;
        let isAllowed = requiredRoles.map(allowedRoles => allowedRoles === userRole).find(val => val === true)
        if (isAllowed) {
            next()
        }
        else {
            return res.status(401).send({ error: true, message: "You are not allowed to access" })
        }
    }
};

module.exports = {CheckAuthRole}