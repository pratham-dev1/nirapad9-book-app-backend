const db = require("../models");

const CheckAppAccess = (APPLICATION) => {
    return async (req, res, next) => {
        let user = await db.user.findByPk(req.user.userId, {
            include: {
                 model: db.applications, as: 'appAccess',attributes: ['id'], through: { attributes: [] }
            },
            attributes: ['id']
        });
        let isAllowed = user.appAccess.map(i => i.id).includes(APPLICATION)
        if (isAllowed) {
            next()
        }
        else {
            return res.status(401).send({ error: true, message: "You are not allowed to access" })
        }
    }
};

module.exports = {CheckAppAccess}